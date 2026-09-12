import 'ability_scores.dart';
import 'character.dart';
import 'dice_roller.dart';

/// Divine Spark's d8 dice count scales with Cleric level: 1 (base), 2 (7+), 3 (13+), 4 (18+).
int divineSparkDiceCount(int clericLevel) {
  if (clericLevel >= 18) return 4;
  if (clericLevel >= 13) return 3;
  if (clericLevel >= 7) return 2;
  return 1;
}

int wisdomModifier(Character character) {
  return character.abilityScores.modifierFor(
    Ability.wisdom,
    bonuses: character.totalAbilityBonuses,
  );
}

DiceRollResult rollDivineSpark(Character character) {
  final dice = divineSparkDiceCount(character.level);
  return rollDamage('${dice}d8', wisdomModifier(character));
}

/// Sear Undead: extra Radiant damage roll (d8s = Wisdom modifier, min 1) applied
/// to Undead that fail their Turn Undead save. Available from Cleric level 5.
DiceRollResult rollSearUndead(Character character) {
  final dice = wisdomModifier(character).clamp(1, 20);
  return rollDamage('${dice}d8', 0);
}

/// War Domain's Guided Strike: adds a flat +10 to a roll that already happened.
int applyGuidedStrike(int originalRollTotal) => originalRollTotal + 10;

/// Life Domain — Preserve Life: total HP pool = 5 × Cleric level, capped per
/// target at half their max HP.
int preserveLifePool(int clericLevel) => 5 * clericLevel;

/// Life Domain — Disciple of Life: extra HP added whenever a healing spell
/// restores HP via a spell slot (2 + slot level). We don't track spell slots
/// mechanically, so this returns the flat "at least 2" baseline the player
/// can adjust for slot level.
int discipleOfLifeBonus({int spellSlotLevel = 1}) => 2 + spellSlotLevel;

/// Light Domain — Radiance of the Dawn: 2d10 + Cleric level, Radiant.
DiceRollResult rollRadianceOfTheDawn(Character character) {
  return rollDamage('2d10', character.level);
}

/// Light Domain — Warding Flare uses: Wisdom modifier, minimum 1.
int wardingFlareUses(Character character) =>
    wisdomModifier(character).clamp(1, 20);

/// Blessed Healer (Life, level 6): when you heal another creature with a
/// spell slot, you also regain HP equal to 2 + the slot's level.
int blessedHealerSelfHeal({int spellSlotLevel = 1}) => 2 + spellSlotLevel;

/// Supreme Healing (Life, level 17): healing dice always roll their maximum.
int maxHealingRoll(String diceText) {
  final match = RegExp(r'(\d+)d(\d+)').firstMatch(diceText);
  if (match == null) return 0;
  final count = int.parse(match.group(1)!);
  final sides = int.parse(match.group(2)!);
  return count * sides;
}
