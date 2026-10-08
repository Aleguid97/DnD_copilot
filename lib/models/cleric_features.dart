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

// Cleric Features table (PHB 2024, chapter 3), index 0 = level 1.
const List<int> _clericCantrips = [
  3, 3, 3, 4, 4, 4, 4, 4, 4, 5, //
  5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
];
const List<int> _clericPrepared = [
  4, 5, 6, 7, 9, 10, 11, 12, 14, 15, //
  16, 16, 17, 17, 18, 18, 19, 20, 21, 22,
];

bool clericIsThaumaturge(Character character) =>
    character.characterClass.id == 'cleric' &&
    character.classSelections['cleric_divine_order']?.contains('thaumaturge') ==
        true;

/// Cantrips known: Cleric table, +1 with the Thaumaturge Divine Order.
int clericCantripCount(Character character) =>
    _clericCantrips[(character.level - 1).clamp(0, 19)] +
    (clericIsThaumaturge(character) ? 1 : 0);

int clericPreparedSpellCount(int level) =>
    _clericPrepared[(level - 1).clamp(0, 19)];

/// Channel Divinity uses: 2 from level 2, 3 from 6, 4 from 18. One use comes
/// back on a Short Rest, all on a Long Rest.
int channelDivinityUses(int level) {
  if (level >= 18) return 4;
  if (level >= 6) return 3;
  if (level >= 2) return 2;
  return 0;
}

/// Domain spells by Cleric level (PHB 2024, chapter 3): always prepared, they
/// don't count against the prepared spells.
const Map<String, Map<int, List<String>>> _domainSpells = {
  'life': {
    3: ['Aid', 'Bless', 'Cure Wounds', 'Lesser Restoration'],
    5: ['Mass Healing Word', 'Revivify'],
    7: ['Aura of Life', 'Death Ward'],
    9: ['Greater Restoration', 'Mass Cure Wounds'],
  },
  'light': {
    3: ['Burning Hands', 'Faerie Fire', 'Scorching Ray', 'See Invisibility'],
    5: ['Daylight', 'Fireball'],
    7: ['Arcane Eye', 'Wall of Fire'],
    9: ['Flame Strike', 'Scrying'],
  },
  'trickery': {
    3: ['Charm Person', 'Disguise Self', 'Invisibility', 'Pass without Trace'],
    5: ['Hypnotic Pattern', 'Nondetection'],
    7: ['Confusion', 'Dimension Door'],
    9: ['Dominate Person', 'Modify Memory'],
  },
  'war': {
    3: ['Guiding Bolt', 'Magic Weapon', 'Shield of Faith', 'Spiritual Weapon'],
    5: ["Crusader's Mantle", 'Spirit Guardians'],
    7: ['Fire Shield', 'Freedom of Movement'],
    9: ['Hold Monster', 'Steel Wind Strike'],
  },
};

List<String> clericDomainSpells(Character character) {
  final domain = character.classSelections['cleric_subclass']?.firstOrNull;
  final table = _domainSpells[domain] ?? const {};
  return [
    for (final e in table.entries)
      if (character.level >= e.key) ...e.value,
  ];
}

/// War God's Blessing (War, level 6): spend Channel Divinity to cast one of
/// these without a slot and without Concentration (lasts 1 minute).
const List<String> warGodsBlessingSpells = [
  'shield_of_faith',
  'spiritual_weapon',
];
