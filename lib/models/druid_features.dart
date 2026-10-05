import 'ability_scores.dart';
import 'character.dart';

// Druid rules from the 2024 Player's Handbook (chapter 3, Druid).

int druidWisdomModifier(Character character) => character.abilityScores
    .modifierFor(Ability.wisdom, bonuses: character.totalAbilityBonuses);

/// "Wisdom modifier (minimum of once)" uses: Moonlight Step, Cosmic Omen,
/// Star Map's free Guiding Bolt.
int druidWisdomUses(Character character) =>
    druidWisdomModifier(character).clamp(1, 20);

int druidSpellSaveDc(Character character, int profBonus) =>
    8 + profBonus + druidWisdomModifier(character);

int druidSpellAttackBonus(Character character, int profBonus) =>
    profBonus + druidWisdomModifier(character);

String? druidSubclass(Character character) =>
    character.classSelections['druid_subclass']?.firstOrNull;

String? druidLandType(Character character) =>
    character.classSelections['druid_land_type']?.firstOrNull;

String? druidElementalFury(Character character) =>
    character.classSelections['druid_elemental_fury']?.firstOrNull;

bool druidIsMagician(Character character) =>
    character.characterClass.id == 'druid' &&
    character.classSelections['druid_primal_order']?.contains('magician') ==
        true;

/// Primal Order — Magician: bonus to Intelligence (Arcana or Nature) checks
/// equal to Wisdom modifier (minimum +1).
int magicianLoreBonus(Character character) =>
    druidWisdomModifier(character).clamp(1, 20);

/// Wild Shape uses (Druid Features table): 2 at level 2, 3 at 6, 4 at 17.
int wildShapeUses(int level) {
  if (level >= 17) return 4;
  if (level >= 6) return 3;
  if (level >= 2) return 2;
  return 0;
}

class BeastShapeLimits {
  final int knownForms;
  final String maxCr;
  final bool flySpeed;

  const BeastShapeLimits(this.knownForms, this.maxCr, this.flySpeed);
}

/// Beast Shapes table. Circle of the Moon replaces the max CR with
/// Druid level / 3 (round down) from level 3 (Circle Forms).
BeastShapeLimits beastShapeLimits(int level, {bool circleOfTheMoon = false}) {
  final known = level >= 8 ? 8 : (level >= 4 ? 6 : 4);
  var maxCr = level >= 8 ? '1' : (level >= 4 ? '1/2' : '1/4');
  // level / 3 is always at least the base table's value from level 3 on.
  if (circleOfTheMoon && level >= 3) maxCr = '${level ~/ 3}';
  return BeastShapeLimits(known, maxCr, level >= 8);
}

/// Temporary Hit Points gained when assuming a Wild Shape form:
/// Druid level, or 3 × Druid level with Circle Forms (Moon).
int wildShapeTempHp(int level, {bool circleOfTheMoon = false}) =>
    circleOfTheMoon && level >= 3 ? 3 * level : level;

/// Circle Forms (Moon): AC = 13 + Wisdom modifier if higher than the Beast's.
int circleFormsArmorClass(Character character) =>
    13 + druidWisdomModifier(character);

/// Elemental Fury — Primal Strike: 1d8, 2d8 from level 15.
String primalStrikeDice(int level) => level >= 15 ? '2d8' : '1d8';

/// Circle of the Land — Land's Aid: 2d6, 3d6 at 10, 4d6 at 14.
String landsAidDice(int level) {
  if (level >= 14) return '4d6';
  if (level >= 10) return '3d6';
  return '2d6';
}

/// Natural Recovery: combined slot levels ≤ half Druid level (round up),
/// none of level 6+.
int naturalRecoveryBudget(int level) => (level + 1) ~/ 2;

/// Starry Form Archer/Chalice die: 1d8, 2d8 from level 10.
String starryFormDice(int level) => level >= 10 ? '2d8' : '1d8';

/// Wrath of the Sea: d6s equal to Wisdom modifier (minimum one die).
String wrathOfTheSeaDice(Character character) =>
    '${druidWisdomModifier(character).clamp(1, 20)}d6';

const landTypeNames = {
  'arid': 'Arid',
  'polar': 'Polar',
  'temperate': 'Temperate',
  'tropical': 'Tropical',
};

/// Nature's Ward resistance per land type.
const natureWardResistance = {
  'arid': 'Fire',
  'polar': 'Cold',
  'temperate': 'Lightning',
  'tropical': 'Poison',
};

/// Circle spells (always prepared), keyed by the Druid level they unlock at.
const landCircleSpells = {
  'arid': {
    3: ['Blur', 'Burning Hands', 'Fire Bolt'],
    5: ['Fireball'],
    7: ['Blight'],
    9: ['Wall of Stone'],
  },
  'polar': {
    3: ['Fog Cloud', 'Hold Person', 'Ray of Frost'],
    5: ['Sleet Storm'],
    7: ['Ice Storm'],
    9: ['Cone of Cold'],
  },
  'temperate': {
    3: ['Misty Step', 'Shocking Grasp', 'Sleep'],
    5: ['Lightning Bolt'],
    7: ['Freedom of Movement'],
    9: ['Tree Stride'],
  },
  'tropical': {
    3: ['Acid Splash', 'Ray of Sickness', 'Web'],
    5: ['Stinking Cloud'],
    7: ['Polymorph'],
    9: ['Insect Plague'],
  },
};

const moonCircleSpells = {
  3: ['Cure Wounds', 'Moonbeam', 'Starry Wisp'],
  5: ['Conjure Animals'],
  7: ['Fount of Moonlight'],
  9: ['Mass Cure Wounds'],
};

const seaCircleSpells = {
  3: ['Fog Cloud', 'Gust of Wind', 'Ray of Frost', 'Shatter', 'Thunderwave'],
  5: ['Lightning Bolt', 'Water Breathing'],
  7: ['Control Water', 'Ice Storm'],
  9: ['Conjure Elemental', 'Hold Monster'],
};

/// Always-prepared spells from the Druid's subclass at the given level.
List<String> druidCircleSpells(Character character) {
  final Map<int, List<String>>? table = switch (druidSubclass(character)) {
    'land' => landCircleSpells[druidLandType(character)],
    'moon' => moonCircleSpells,
    'sea' => seaCircleSpells,
    'stars' => const {
      3: ['Guidance', 'Guiding Bolt'],
    },
    _ => null,
  };
  if (table == null) return const [];
  return [
    for (final e in table.entries)
      if (e.key <= character.level) ...e.value,
  ];
}

/// Prepared Spells column of the Druid Features table (levels 1-20).
const _druidPreparedSpells = [
  4, 5, 6, 7, 9, 10, 11, 12, 14, 15, //
  16, 16, 17, 17, 18, 18, 19, 20, 21, 22,
];

int druidPreparedSpellCount(int level) =>
    _druidPreparedSpells[(level - 1).clamp(0, 19)];

/// Cantrips column of the Druid Features table (+1 for the Magician order).
int druidCantripCount(Character character) {
  final level = character.level;
  final base = level >= 10 ? 4 : (level >= 4 ? 3 : 2);
  return base + (druidIsMagician(character) ? 1 : 0);
}

/// Spells the Druid always has prepared (they don't count against the
/// prepared-spell limit): Speak with Animals (Druidic) and Circle spells.
List<String> druidAlwaysPreparedNames(Character character) => [
  'Speak with Animals',
  ...druidCircleSpells(character),
];
