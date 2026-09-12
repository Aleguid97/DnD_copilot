import 'ability_scores.dart';

enum AllocationMode { twoPlusOne, onePlusOnePlusOne }

class BackgroundAbilityChoice {
  final AllocationMode mode;
  final Ability? plusTwo; // usato solo in modalità twoPlusOne
  final Ability? plusOne; // usato solo in modalità twoPlusOne

  const BackgroundAbilityChoice({
    this.mode = AllocationMode.onePlusOnePlusOne,
    this.plusTwo,
    this.plusOne,
  });

  BackgroundAbilityChoice copyWith({
    AllocationMode? mode,
    Ability? plusTwo,
    Ability? plusOne,
    bool clearPlusTwo = false,
    bool clearPlusOne = false,
  }) {
    return BackgroundAbilityChoice(
      mode: mode ?? this.mode,
      plusTwo: clearPlusTwo ? null : (plusTwo ?? this.plusTwo),
      plusOne: clearPlusOne ? null : (plusOne ?? this.plusOne),
    );
  }

  /// Calcola la mappa dei bonus finali, date le 3 caratteristiche ammesse dal background.
  Map<Ability, int> toBonusMap(List<Ability> options) {
    if (mode == AllocationMode.onePlusOnePlusOne) {
      return {for (final a in options) a: 1};
    }
    final map = <Ability, int>{};
    if (plusTwo != null) map[plusTwo!] = 2;
    if (plusOne != null) map[plusOne!] = 1;
    return map;
  }

  bool get isComplete {
    if (mode == AllocationMode.onePlusOnePlusOne) return true;
    return plusTwo != null && plusOne != null && plusTwo != plusOne;
  }
}