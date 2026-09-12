import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/background.dart';
import '../models/background_ability_choice.dart';
import '../models/ability_scores.dart';
import '../models/choice.dart';

part 'background_selection_provider.g.dart';

class BackgroundSelectionState {
  final Background? selectedBackground;
  final BackgroundAbilityChoice abilityChoice;
  final Map<String, Set<String>> selections;

  const BackgroundSelectionState({
    this.selectedBackground,
    this.abilityChoice = const BackgroundAbilityChoice(),
    this.selections = const {},
  });

  BackgroundSelectionState copyWith({
    Background? selectedBackground,
    BackgroundAbilityChoice? abilityChoice,
    Map<String, Set<String>>? selections,
  }) {
    return BackgroundSelectionState(
      selectedBackground: selectedBackground ?? this.selectedBackground,
      abilityChoice: abilityChoice ?? this.abilityChoice,
      selections: selections ?? this.selections,
    );
  }

  Map<Ability, int> get abilityBonuses {
    if (selectedBackground == null) return {};
    return abilityChoice.toBonusMap(selectedBackground!.abilityScoreOptions);
  }

  List<Choice> get activeChoices => selectedBackground?.choices ?? [];

  bool get isComplete {
    if (selectedBackground == null) return false;
    if (!abilityChoice.isComplete) return false;
    for (final choice in activeChoices) {
      final selected = selections[choice.id] ?? const {};
      if (selected.length < choice.minSelections) return false;
    }
    return true;
  }
}

@riverpod
class BackgroundSelectionNotifier extends _$BackgroundSelectionNotifier {
  @override
  BackgroundSelectionState build() => const BackgroundSelectionState();

  void selectBackground(Background background) {
    state = BackgroundSelectionState(selectedBackground: background);
  }

  void setMode(AllocationMode mode) {
    state = state.copyWith(abilityChoice: BackgroundAbilityChoice(mode: mode));
  }

  void setPlusTwo(Ability ability) {
    final current = state.abilityChoice;
    final newPlusOne = current.plusOne == ability ? null : current.plusOne;
    state = state.copyWith(
      abilityChoice: current.copyWith(
        plusTwo: ability,
        plusOne: newPlusOne,
        clearPlusOne: newPlusOne == null,
      ),
    );
  }

  void setPlusOne(Ability ability) {
    final current = state.abilityChoice;
    if (current.plusTwo == ability) return;
    state = state.copyWith(abilityChoice: current.copyWith(plusOne: ability));
  }

  void selectSingle(Choice choice, String optionId) {
    final updated = Map<String, Set<String>>.from(state.selections);
    updated[choice.id] = {optionId};
    state = state.copyWith(selections: updated);
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
  }
}
