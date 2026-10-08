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
