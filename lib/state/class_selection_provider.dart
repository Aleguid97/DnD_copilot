import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/ability_scores.dart';
import '../models/ability_score_improvement.dart';
import '../models/character_class.dart';
import '../models/choice.dart';
import '../models/choice_utils.dart';

part 'class_selection_provider.g.dart';

class ClassSelectionState {
  final CharacterClass? selectedClass;
  final int targetLevel;
  final Map<String, Set<String>> selections;
  final List<AsiChoice> asiChoices;
  final String? startingEquipmentOptionId;

  const ClassSelectionState({
    this.selectedClass,
    this.targetLevel = 1,
    this.selections = const {},
    this.asiChoices = const [],
    this.startingEquipmentOptionId,
  });

  ClassSelectionState copyWith({
    CharacterClass? selectedClass,
    int? targetLevel,
    Map<String, Set<String>>? selections,
    List<AsiChoice>? asiChoices,
    String? startingEquipmentOptionId,
  }) {
    return ClassSelectionState(
      selectedClass: selectedClass ?? this.selectedClass,
      targetLevel: targetLevel ?? this.targetLevel,
      selections: selections ?? this.selections,
      asiChoices: asiChoices ?? this.asiChoices,
      startingEquipmentOptionId:
          startingEquipmentOptionId ?? this.startingEquipmentOptionId,
    );
  }

  int get maxSelectableLevel => selectedClass?.maxDefinedLevel ?? 1;

  int get asiEventCount {
    if (selectedClass == null) return 0;
    return selectedClass!.levelFeatures
        .where((f) => f.level <= targetLevel && f.grantsAbilityScoreImprovement)
        .length;
  }

  List<Choice> get _allClassChoices {
    if (selectedClass == null) return [];
    return selectedClass!.levelFeatures.expand((f) => f.choices).toList();
  }

  List<ChoiceOption> get _selectedSubclassOptions {
    final result = <ChoiceOption>[];
    for (final choice in _allClassChoices) {
      final selectedIds = selections[choice.id] ?? const {};
      for (final option in choice.options) {
        if (selectedIds.contains(option.id)) result.add(option);
      }
    }
    return result;
  }

  /// Applies any +N adjustments to Choice selection counts granted by the
  /// currently selected subclass options (e.g. Thaumaturge/Magician granting
  /// +1 cantrip on top of the base class cantrip Choice).
  List<Choice> _applyChoiceCountAdjustments(List<Choice> choices) {
    final adjustments = <String, int>{};
    for (final option in _selectedSubclassOptions) {
      option.extraSelectionsForChoice.forEach((choiceId, extra) {
        adjustments[choiceId] = (adjustments[choiceId] ?? 0) + extra;
      });
    }
    if (adjustments.isEmpty) return choices;
    return choices.map((c) {
      final extra = adjustments[c.id];
      if (extra == null) return c;
      final newMax = c.maxSelections + extra;
      final newMin = c.minSelections + extra;
      final newTitle = c.title.replaceFirst(RegExp(r'\d+'), '$newMax');
      return c.copyWith(
        minSelections: newMin,
        maxSelections: newMax,
        title: newTitle,
      );
    }).toList();
  }

  List<String> get cumulativeFixedTraits {
    if (selectedClass == null) return [];
    final base = selectedClass!.cumulativeFixedTraits(targetLevel);
    final subclassTraits = <String>[];
    for (final option in _selectedSubclassOptions) {
      option.levelFeatures.forEach((level, feature) {
        if (level <= targetLevel) subclassTraits.addAll(feature.fixedTraits);
      });
    }
    return [...base, ...subclassTraits];
  }

  /// Flattened (includes nested unlockedChoices resolved) — used for
  /// validation (isComplete) and anywhere that needs the full choice set.
  List<Choice> get activeChoices {
    if (selectedClass == null) return [];
    final base = _applyChoiceCountAdjustments(
      flattenChoicesWithUnlocked(
        selectedClass!.levelFeatures
            .where((f) => f.level <= targetLevel)
            .expand((f) => f.choices)
            .toList(),
        selections,
      ),
    );
    final subclassChoices = <Choice>[];
    for (final option in _selectedSubclassOptions) {
      option.levelFeatures.forEach((level, feature) {
        if (level <= targetLevel) {
          subclassChoices.addAll(
            flattenChoicesWithUnlocked(feature.choices, selections),
          );
        }
      });
    }
    return [...base, ...subclassChoices];
  }

  /// NOT flattened — feed this directly into ChoiceTree, which already
  /// walks unlockedChoices recursively on its own. Using the flattened
  /// version here would show nested choices twice.
  List<Choice> get topLevelActiveChoices {
    if (selectedClass == null) return [];
    final base = _applyChoiceCountAdjustments(
      selectedClass!.levelFeatures
          .where((f) => f.level <= targetLevel)
          .expand((f) => f.choices)
          .toList(),
    );
    final subclassChoices = <Choice>[];
    for (final option in _selectedSubclassOptions) {
      option.levelFeatures.forEach((level, feature) {
        if (level <= targetLevel) subclassChoices.addAll(feature.choices);
      });
    }
    return [...base, ...subclassChoices];
  }

  Map<Ability, int> get asiBonuses =>
      mergeAbilityBonusMaps(asiChoices.map((c) => c.toBonusMap()).toList());

  bool get isComplete {
    if (selectedClass == null) return false;
    for (final choice in activeChoices) {
      final selected = selections[choice.id] ?? const {};
      if (selected.length < choice.minSelections) return false;
    }
    final skillsSelected =
        selections['${selectedClass!.id}_skills'] ?? const {};
    if (skillsSelected.length < selectedClass!.skillChoiceCount) return false;
    if (asiChoices.length < asiEventCount) return false;
    for (final asi in asiChoices) {
      if (!asi.isComplete) return false;
    }
    if (targetLevel == 1 &&
        selectedClass!.startingEquipmentOptions.isNotEmpty &&
        startingEquipmentOptionId == null) {
      return false;
    }
    return true;
  }
}

@riverpod
class ClassSelectionNotifier extends _$ClassSelectionNotifier {
  @override
  ClassSelectionState build() => const ClassSelectionState();

  void selectClass(CharacterClass charClass) {
    state = ClassSelectionState(
      selectedClass: charClass,
      targetLevel: 1,
      selections: {},
    );
  }

  void setTargetLevel(int level) {
    final maxLevel = state.maxSelectableLevel;
    final clamped = level.clamp(1, maxLevel);
    final newState = state.copyWith(targetLevel: clamped);
    state = _syncAsiChoices(newState);
  }

  void loadForLevelUp({
    required CharacterClass charClass,
    required int targetLevel,
    required Map<String, Set<String>> existingSelections,
    required List<AsiChoice> existingAsiChoices,
  }) {
    final loaded = ClassSelectionState(
      selectedClass: charClass,
      targetLevel: targetLevel,
      selections: existingSelections,
      asiChoices: existingAsiChoices,
    );
    state = _syncAsiChoices(loaded);
  }

  ClassSelectionState _syncAsiChoices(ClassSelectionState s) {
    final needed = s.asiEventCount;
    final current = List<AsiChoice>.from(s.asiChoices);
    if (current.length > needed) {
      current.removeRange(needed, current.length);
    } else {
      while (current.length < needed) {
        current.add(const AsiChoice());
      }
    }
    return s.copyWith(asiChoices: current);
  }

  void setAsiMode(int index, AsiAllocationMode mode) {
    final updated = List<AsiChoice>.from(state.asiChoices);
    updated[index] = AsiChoice(mode: mode);
    state = state.copyWith(asiChoices: updated);
  }

  void setAsiPlusTwo(int index, Ability ability) {
    final updated = List<AsiChoice>.from(state.asiChoices);
    updated[index] = updated[index].copyWith(plusTwo: ability);
    state = state.copyWith(asiChoices: updated);
  }

  void setAsiFirstPlusOne(int index, Ability ability) {
    final updated = List<AsiChoice>.from(state.asiChoices);
    final current = updated[index];
    final clearSecond = current.secondPlusOne == ability;
    updated[index] = current.copyWith(
      firstPlusOne: ability,
      clearSecondPlusOne: clearSecond,
    );
    state = state.copyWith(asiChoices: updated);
  }

  void setAsiSecondPlusOne(int index, Ability ability) {
    final updated = List<AsiChoice>.from(state.asiChoices);
    final current = updated[index];
    if (current.firstPlusOne == ability) return;
    updated[index] = current.copyWith(secondPlusOne: ability);
    state = state.copyWith(asiChoices: updated);
  }

  void setStartingEquipmentOption(String optionId) {
    state = state.copyWith(startingEquipmentOptionId: optionId);
  }

  void selectSingle(Choice choice, String optionId) {
    final updated = Map<String, Set<String>>.from(state.selections);
    updated[choice.id] = {optionId};
    state = state.copyWith(selections: updated);
    _trimOversizedSelections();
  }

  /// After a subclass/order choice changes, some Choice selection limits
  /// may shrink back down (e.g. Thaumaturge -> Protector: 4 cantrips -> 3).
  /// Trim any now-oversized selections so they don't linger as invalid state.
  void _trimOversizedSelections() {
    final activeChoicesNow = state.activeChoices;
    final updated = Map<String, Set<String>>.from(state.selections);
    var changed = false;
    for (final choice in activeChoicesNow) {
      final selected = updated[choice.id];
      if (selected != null && selected.length > choice.maxSelections) {
        updated[choice.id] = selected.take(choice.maxSelections).toSet();
        changed = true;
      }
    }
    if (changed) {
      state = state.copyWith(selections: updated);
    }
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
