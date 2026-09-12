import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/race.dart';
import '../models/choice.dart';

part 'race_selection_provider.g.dart';

class RaceSelectionState {
  final Race? selectedRace;
  final Map<String, Set<String>> selections; // choiceId -> optionId selezionati

  const RaceSelectionState({this.selectedRace, this.selections = const {}});

  RaceSelectionState copyWith({
    Race? selectedRace,
    Map<String, Set<String>>? selections,
  }) {
    return RaceSelectionState(
      selectedRace: selectedRace ?? this.selectedRace,
      selections: selections ?? this.selections,
    );
  }

  /// Tutte le scelte attualmente "attive", comprese quelle sbloccate
  /// ricorsivamente da opzioni già selezionate.
  List<Choice> get activeChoices {
    final result = <Choice>[];
    if (selectedRace == null) return result;

    void walk(List<Choice> choices) {
      for (final choice in choices) {
        result.add(choice);
        final selected = selections[choice.id] ?? const {};
        for (final option in choice.options) {
          if (selected.contains(option.id)) {
            walk(option.unlockedChoices);
          }
        }
      }
    }

    walk(selectedRace!.choices);
    return result;
  }

  bool get isComplete {
    if (selectedRace == null) return false;
    for (final choice in activeChoices) {
      final selected = selections[choice.id] ?? const {};
      if (selected.length < choice.minSelections) return false;
    }
    return true;
  }
}

@riverpod
class RaceSelectionNotifier extends _$RaceSelectionNotifier {
  @override
  RaceSelectionState build() => const RaceSelectionState();

  void selectRace(Race race) {
    // Cambiare razza azzera tutte le scelte fatte finora.
    state = RaceSelectionState(selectedRace: race, selections: {});
  }

  void selectSingle(Choice choice, String optionId) {
    final updated = Map<String, Set<String>>.from(state.selections);
    updated[choice.id] = {optionId};
    state = state.copyWith(selections: updated);
    _pruneStaleSelections();
  }

  void toggleMulti(Choice choice, String optionId) {
    final updated = Map<String, Set<String>>.from(state.selections);
    final current = Set<String>.from(updated[choice.id] ?? {});
    if (current.contains(optionId)) {
      current.remove(optionId);
    } else if (current.length < choice.maxSelections) {
      current.add(optionId);
    }
    updated[choice.id] = current;
    state = state.copyWith(selections: updated);
    _pruneStaleSelections();
  }

  /// Rimuove le selezioni per scelte non più attive
  /// (es. cambi stirpe elfica -> il cantrip scelto prima va cancellato).
  void _pruneStaleSelections() {
    final activeIds = state.activeChoices.map((c) => c.id).toSet();
    final updated = Map<String, Set<String>>.from(state.selections)
      ..removeWhere((key, _) => !activeIds.contains(key));
    state = state.copyWith(selections: updated);
  }
}