import 'ability_scores.dart';

enum AsiAllocationMode { twoInOne, onePlusOne }

class AsiChoice {
  final AsiAllocationMode mode;
  final Ability? plusTwo; // used when mode == twoInOne
  final Ability? firstPlusOne; // used when mode == onePlusOne
  final Ability? secondPlusOne; // used when mode == onePlusOne

  const AsiChoice({
    this.mode = AsiAllocationMode.twoInOne,
    this.plusTwo,
    this.firstPlusOne,
    this.secondPlusOne,
  });

  AsiChoice copyWith({
    AsiAllocationMode? mode,
    Ability? plusTwo,
    Ability? firstPlusOne,
    Ability? secondPlusOne,
    bool clearPlusTwo = false,
    bool clearFirstPlusOne = false,
    bool clearSecondPlusOne = false,
  }) {
    return AsiChoice(
      mode: mode ?? this.mode,
      plusTwo: clearPlusTwo ? null : (plusTwo ?? this.plusTwo),
      firstPlusOne: clearFirstPlusOne
          ? null
          : (firstPlusOne ?? this.firstPlusOne),
      secondPlusOne: clearSecondPlusOne
          ? null
          : (secondPlusOne ?? this.secondPlusOne),
    );
  }

  Map<Ability, int> toBonusMap() {
    if (mode == AsiAllocationMode.twoInOne) {
      return plusTwo != null ? {plusTwo!: 2} : {};
    }
    final map = <Ability, int>{};
    if (firstPlusOne != null)
      map[firstPlusOne!] = (map[firstPlusOne!] ?? 0) + 1;

    if (secondPlusOne != null)
      map[secondPlusOne!] = (map[secondPlusOne!] ?? 0) + 1;

    return map;
  }

  bool get isComplete {
    if (mode == AsiAllocationMode.twoInOne) return plusTwo != null;
    return firstPlusOne != null &&
        secondPlusOne != null &&
        firstPlusOne != secondPlusOne;
  }
}

/// Merges a list of per-event bonus maps into one combined map.
Map<Ability, int> mergeAbilityBonusMaps(List<Map<Ability, int>> maps) {
  final result = <Ability, int>{};
  for (final map in maps) {
    map.forEach((ability, value) {
      result[ability] = (result[ability] ?? 0) + value;
    });
  }
  return result;
}

/// Total value of each ability BEFORE a given ASI event, so the UI can
/// prevent picking an increase that would push the score above 20.
Map<Ability, int> asiCurrentTotals({
  required Map<Ability, int> baseScores,
  required Map<Ability, int> backgroundBonuses,
  required List<AsiChoice> asiChoices,
  required int excludingIndex,
}) {
  final otherAsiBonuses = mergeAbilityBonusMaps([
    for (var i = 0; i < asiChoices.length; i++)
      if (i != excludingIndex) asiChoices[i].toBonusMap(),
  ]);
  final combined = mergeAbilityBonusMaps([backgroundBonuses, otherAsiBonuses]);
  return {
    for (final a in Ability.values)
      a: (baseScores[a] ?? 10) + (combined[a] ?? 0),
  };
}
