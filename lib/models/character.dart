import 'character_basics.dart';
import 'race.dart';
import 'character_class.dart';
import 'background.dart';
import 'ability_scores.dart';
import 'background_ability_choice.dart';
import 'ability_score_improvement.dart';
import 'hit_points.dart';

class Character {
  final int? id; // database row id; null while still in the creation wizard
  final CharacterBasics basics;
  final Race race;
  final Map<String, Set<String>> raceSelections;
  final CharacterClass characterClass;
  final int level;
  final Map<String, Set<String>> classSelections;
  final List<AsiChoice> asiChoices;
  final Background background;
  final BackgroundAbilityChoice backgroundAbilityChoice;
  final Map<String, Set<String>> backgroundSelections;
  final AbilityScores abilityScores;
  final HitPointsState hitPoints;

  const Character({
    this.id,
    required this.basics,
    required this.race,
    required this.raceSelections,
    required this.characterClass,
    required this.level,
    required this.classSelections,
    required this.asiChoices,
    required this.background,
    required this.backgroundAbilityChoice,
    required this.backgroundSelections,
    required this.abilityScores,
    required this.hitPoints,
  });
  Map<Ability, int> get totalAbilityBonuses {
    final bgBonuses = backgroundAbilityChoice.toBonusMap(
      background.abilityScoreOptions,
    );
    final asiBonuses = mergeAbilityBonusMaps(
      asiChoices.map((c) => c.toBonusMap()).toList(),
    );
    final baseMerged = mergeAbilityBonusMaps([bgBonuses, asiBonuses]);
    if (characterClass.id == 'barbarian' && level >= 20) {
      final currentStr =
          abilityScores.baseScores[Ability.strength]! +
          (baseMerged[Ability.strength] ?? 0);
      final currentCon =
          abilityScores.baseScores[Ability.constitution]! +
          (baseMerged[Ability.constitution] ?? 0);
      final champBonus = <Ability, int>{
        Ability.strength: (25 - currentStr).clamp(0, 4),
        Ability.constitution: (25 - currentCon).clamp(0, 4),
      };
      return mergeAbilityBonusMaps([baseMerged, champBonus]);
    }
    return baseMerged;
  }

  Map<Ability, int> get racialAndClassBonuses {
    final result = <Ability, int>{};
    if (characterClass.id == 'barbarian' && level >= 20) {
      final currentStr =
          abilityScores.baseScores[Ability.strength]! +
          (totalAbilityBonuses[Ability.strength] ?? 0);
      final currentCon =
          abilityScores.baseScores[Ability.constitution]! +
          (totalAbilityBonuses[Ability.constitution] ?? 0);
      result[Ability.strength] = (25 - currentStr).clamp(0, 4);
      result[Ability.constitution] = (25 - currentCon).clamp(0, 4);
    }
    return result;
  }

  int get conModifier => abilityScores.modifierFor(
    Ability.constitution,
    bonuses: totalAbilityBonuses,
  );

  int get totalHitPoints {
    final base = hitPoints.totalHitPoints(
      hitDie: characterClass.hitDie,
      targetLevel: level,
      conModifier: conModifier,
    );
    return base + (race.hpBonusPerLevel * level);
  }
}
