import '../models/character.dart';
import '../models/class_resource.dart';

/// Spell slots per spell level (index 0 = level 1) for full casters, from the
/// Druid Features table of the 2024 Player's Handbook (shared by every full
/// caster: Bard, Cleric, Druid, Sorcerer, Wizard).
const List<List<int>> fullCasterSpellSlots = [
  [2],
  [3],
  [4, 2],
  [4, 3],
  [4, 3, 2],
  [4, 3, 3],
  [4, 3, 3, 1],
  [4, 3, 3, 2],
  [4, 3, 3, 3, 1],
  [4, 3, 3, 3, 2],
  [4, 3, 3, 3, 2, 1],
  [4, 3, 3, 3, 2, 1],
  [4, 3, 3, 3, 2, 1, 1],
  [4, 3, 3, 3, 2, 1, 1],
  [4, 3, 3, 3, 2, 1, 1, 1],
  [4, 3, 3, 3, 2, 1, 1, 1],
  [4, 3, 3, 3, 2, 1, 1, 1, 1],
  [4, 3, 3, 3, 3, 1, 1, 1, 1],
  [4, 3, 3, 3, 3, 2, 1, 1, 1],
  [4, 3, 3, 3, 3, 2, 2, 1, 1],
];

int fullCasterSlots(int characterLevel, int spellLevel) {
  final row = fullCasterSpellSlots[(characterLevel - 1).clamp(0, 19)];
  return spellLevel <= row.length ? row[spellLevel - 1] : 0;
}

String spellSlotResourceId(int spellLevel) => 'spell_slot_$spellLevel';

bool isSpellSlotResource(String resourceId) =>
    resourceId.startsWith('spell_slot_');

/// Eldritch Knight Spellcasting table (Fighter levels 3-20, chapter 3).
const List<List<int>> eldritchKnightSpellSlots = [
  [], [], [2], [3], [3], [3], [4, 2], [4, 2], [4, 2], [4, 3], //
  [4, 3], [4, 3], [4, 3, 2], [4, 3, 2], [4, 3, 2], [4, 3, 3], [4, 3, 3],
  [4, 3, 3], [4, 3, 3, 1], [4, 3, 3, 1],
];

int eldritchKnightSlots(int fighterLevel, int spellLevel) {
  final row = eldritchKnightSpellSlots[(fighterLevel - 1).clamp(0, 19)];
  return spellLevel <= row.length ? row[spellLevel - 1] : 0;
}

/// Spell slots of [character] for [spellLevel]: the full caster table, or
/// the Eldritch Knight's for a Fighter.
int spellSlotsFor(Character character, int spellLevel) =>
    character.characterClass.id == 'fighter'
    ? eldritchKnightSlots(character.level, spellLevel)
    : fullCasterSlots(character.level, spellLevel);

/// One tracked resource per spell level; all slots return on a Long Rest.
List<ClassResource> slotResources(
  int Function(int level, int spellLevel) table,
) => [
  for (var spellLevel = 1; spellLevel <= 9; spellLevel++)
    ClassResource(
      id: spellSlotResourceId(spellLevel),
      name: 'Level $spellLevel spell slots',
      maxUses: (level) => table(level, spellLevel),
      availableFromLevel: 1,
      fullRecoveryOn: RestType.long,
    ),
];

final List<ClassResource> fullCasterSlotResources = slotResources(
  fullCasterSlots,
);
