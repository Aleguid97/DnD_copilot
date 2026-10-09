import 'character.dart';

// Fighter rules from chapter 3 of the PHB 2024.

String? fighterSubclass(Character c) => c.characterClass.id == 'fighter'
    ? c.classSelections['fighter_subclass']?.firstOrNull
    : null;

/// Second Wind uses (Fighter Features table): 2, 3 from level 4, 4 from 10.
int secondWindUses(int level) => level >= 10 ? 4 : (level >= 4 ? 3 : 2);

/// Weapon Mastery kinds (Fighter Features table): 3, 4 from level 4, 5 from
/// 10, 6 from 16.
int fighterWeaponMasteryCount(int level) =>
    level >= 16 ? 6 : (level >= 10 ? 5 : (level >= 4 ? 4 : 3));

/// Weapon kinds whose mastery property the character can use, from every
/// `<class>_weapon_mastery*` selection (the extra Fighter picks at levels 4,
/// 10 and 16 have their own keys).
Set<String> masteredWeaponIds(Character c) => {
  for (final e in c.classSelections.entries)
    if (e.key.startsWith('${c.characterClass.id}_weapon_mastery')) ...e.value,
};

/// Lowest natural d20 that scores a Critical Hit with weapons and Unarmed
/// Strikes: Champion Improved Critical (19) and Superior Critical (18).
int weaponCritThreshold(Character c) {
  if (fighterSubclass(c) != 'champion') return 20;
  if (c.level >= 15) return 18;
  if (c.level >= 3) return 19;
  return 20;
}

/// Champion Remarkable Athlete: Advantage on Initiative and Athletics.
bool hasRemarkableAthlete(Character c) =>
    fighterSubclass(c) == 'champion' && c.level >= 3;

// ---------------------------------------------------------------------------
// Battle Master

/// Superiority Dice: 4, 5 from level 7, 6 from 15.
int superiorityDiceCount(int level) => level >= 15 ? 6 : (level >= 7 ? 5 : 4);

/// d8, d10 from level 10 (Improved), d12 from 18 (Ultimate).
String superiorityDie(int level) =>
    level >= 18 ? 'd12' : (level >= 10 ? 'd10' : 'd8');

/// Maneuvers known: 3, +2 at levels 7, 10 and 15.
int maneuversKnown(int level) =>
    3 + (level >= 7 ? 2 : 0) + (level >= 10 ? 2 : 0) + (level >= 15 ? 2 : 0);

/// What the rolled Superiority Die does, so the combat screen can apply it.
enum ManeuverUse {
  /// Added to the damage of a hit; may force a save on the target.
  damage,

  /// Added to an attack roll that missed (Precision Attack).
  attackRoll,

  /// Added to an ability check or Initiative.
  check,

  /// Bonus to AC until the start of your next turn.
  armorClass,

  /// Reduces damage you take (Parry).
  reduceDamage,

  /// Temporary Hit Points for an ally (Rally).
  tempHp,

  /// Damage to a second creature (Sweeping Attack).
  otherCreature,
}

class Maneuver {
  final String id;
  final String name;
  final ManeuverUse use;
  final String summary;

  /// Saving throw the target makes (DC 8 + Str or Dex + Proficiency).
  final String? save;

  /// Condition on a failed save, if any.
  final String? condition;

  const Maneuver(
    this.id,
    this.name,
    this.use,
    this.summary, {
    this.save,
    this.condition,
  });
}

/// Maneuver Options (Battle Master, chapter 3), in the book's order.
const List<Maneuver> battleMasterManeuvers = [
  Maneuver(
    'ambush',
    'Ambush',
    ManeuverUse.check,
    'Add the die to a Dexterity (Stealth) check or an Initiative roll.',
  ),
  Maneuver(
    'bait_and_switch',
    'Bait and Switch',
    ManeuverUse.armorClass,
    'Swap places with a willing creature within 5 ft; you or it gains the '
        'die to AC until the start of your next turn.',
  ),
  Maneuver(
    'commanders_strike',
    "Commander's Strike",
    ManeuverUse.damage,
    'Replace one of your attacks: an ally uses its Reaction to attack, adding '
        'the die to its damage.',
  ),
  Maneuver(
    'commanding_presence',
    'Commanding Presence',
    ManeuverUse.check,
    'Add the die to a Charisma (Intimidation, Performance, or Persuasion) '
        'check.',
  ),
  Maneuver(
    'disarming_attack',
    'Disarming Attack',
    ManeuverUse.damage,
    'On a hit, add the die to damage; the target drops an object on a failed '
        'Strength save.',
    save: 'Strength',
    condition: 'Disarmed',
  ),
  Maneuver(
    'distracting_strike',
    'Distracting Strike',
    ManeuverUse.damage,
    'On a hit, add the die to damage; the next attack against the target by '
        'someone else has Advantage before your next turn.',
    condition: 'Distracted',
  ),
  Maneuver(
    'evasive_footwork',
    'Evasive Footwork',
    ManeuverUse.armorClass,
    'Bonus Action: Disengage and add the die to your AC until the start of '
        'your next turn.',
  ),
  Maneuver(
    'feinting_attack',
    'Feinting Attack',
    ManeuverUse.damage,
    'Bonus Action: Advantage on your next attack against a creature within '
        '5 ft this turn; on a hit add the die to damage.',
  ),
  Maneuver(
    'goading_attack',
    'Goading Attack',
    ManeuverUse.damage,
    'On a hit, add the die to damage; on a failed Wisdom save the target has '
        'Disadvantage on attacks against others until the end of your next '
        'turn.',
    save: 'Wisdom',
    condition: 'Goaded',
  ),
  Maneuver(
    'lunging_attack',
    'Lunging Attack',
    ManeuverUse.damage,
    'Bonus Action: Dash; if you move 5+ ft in a straight line before a melee '
        'hit this turn, add the die to its damage.',
  ),
  Maneuver(
    'maneuvering_attack',
    'Maneuvering Attack',
    ManeuverUse.damage,
    'On a hit, add the die to damage; an ally can use its Reaction to move '
        'half its Speed without provoking from the target.',
  ),
  Maneuver(
    'menacing_attack',
    'Menacing Attack',
    ManeuverUse.damage,
    'On a hit, add the die to damage; Frightened until the end of your next '
        'turn on a failed Wisdom save.',
    save: 'Wisdom',
    condition: 'Frightened',
  ),
  Maneuver(
    'parry',
    'Parry',
    ManeuverUse.reduceDamage,
    'Reaction when a melee attack damages you: reduce the damage by the die '
        '+ Strength or Dexterity modifier.',
  ),
  Maneuver(
    'precision_attack',
    'Precision Attack',
    ManeuverUse.attackRoll,
    'When you miss with an attack roll, add the die to it.',
  ),
  Maneuver(
    'pushing_attack',
    'Pushing Attack',
    ManeuverUse.damage,
    'On a weapon or Unarmed Strike hit, add the die to damage; a Large or '
        'smaller target is pushed up to 15 ft on a failed Strength save.',
    save: 'Strength',
    condition: 'Pushed 15 ft',
  ),
  Maneuver(
    'rally',
    'Rally',
    ManeuverUse.tempHp,
    'Bonus Action: an ally within 30 ft gains Temporary HP equal to the die '
        '+ half your Fighter level.',
  ),
  Maneuver(
    'riposte',
    'Riposte',
    ManeuverUse.damage,
    'Reaction when a creature misses you with a melee attack: make a melee '
        'attack against it, adding the die to damage on a hit.',
  ),
  Maneuver(
    'sweeping_attack',
    'Sweeping Attack',
    ManeuverUse.otherCreature,
    'On a melee hit, another creature within 5 ft of the target and your reach '
        'takes the die as damage if your attack roll would hit it.',
  ),
  Maneuver(
    'tactical_assessment',
    'Tactical Assessment',
    ManeuverUse.check,
    'Add the die to an Intelligence (History or Investigation) or Wisdom '
        '(Insight) check.',
  ),
  Maneuver(
    'trip_attack',
    'Trip Attack',
    ManeuverUse.damage,
    'On a weapon or Unarmed Strike hit, add the die to damage; a Large or '
        'smaller target has the Prone condition on a failed Strength save.',
    save: 'Strength',
    condition: 'Prone',
  ),
];

/// Maneuvers the character knows (level 3 pick plus those at 7, 10, 15).
List<Maneuver> knownManeuvers(Character c) {
  final ids = {
    for (final e in c.classSelections.entries)
      if (e.key.startsWith('battle_master_maneuvers')) ...e.value,
  };
  return [
    for (final m in battleMasterManeuvers)
      if (ids.contains(m.id)) m,
  ];
}

// ---------------------------------------------------------------------------
// Psi Warrior

/// Psionic Energy Dice (Psi Warrior Energy Dice table): (die, number).
(String, int) psionicEnergyDice(int level) {
  if (level >= 17) return ('d12', 12);
  if (level >= 13) return ('d10', 10);
  if (level >= 11) return ('d10', 8);
  if (level >= 9) return ('d8', 8);
  if (level >= 5) return ('d8', 6);
  return ('d6', 4);
}

// ---------------------------------------------------------------------------
// Eldritch Knight

/// Wizard cantrips known: 2, 3 from Fighter level 10.
int eldritchKnightCantrips(int level) => level >= 10 ? 3 : 2;

/// Prepared spells (Eldritch Knight Spellcasting table), Fighter levels 3-20.
int eldritchKnightPrepared(int level) => const [
  0, 0, 3, 4, 4, 4, 5, 6, 6, 7, 8, 8, 9, 10, 10, 11, 11, 11, 12, 13, //
][(level - 1).clamp(0, 19)];
