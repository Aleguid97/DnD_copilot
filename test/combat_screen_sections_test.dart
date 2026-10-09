// Guards against the "swallowed sections" bug: an unbalanced bracket in one
// class block of the combat screen used to hide every section below it with
// no visible error. This test opens CombatScreen for every class (and every
// implemented subclass) at level 1 and 20 and checks that all sections render.

import 'package:dnd_prova/data/class_resources_data.dart';
import 'package:dnd_prova/data/classes_data.dart';
import 'package:dnd_prova/data/spells_data.dart';
import 'package:dnd_prova/models/character.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/combat_harness.dart';

/// Section titles that every class must show, plus the class-specific ones.
List<String> _expectedSections(Character c) {
  final hasResources = (classResources[c.characterClass.id] ?? []).any(
    (r) => r.availableFromLevel <= c.level,
  );
  return [
    'Saving Throws',
    'Skill Checks',
    'Equipped Weapons',
    'Unarmed Strike',
    if (c.characterClass.id == 'barbarian') 'Barbarian Features',
    if (c.characterClass.id == 'cleric') 'Cleric Features',
    if (c.characterClass.id == 'fighter') 'Fighter Features',
    if (c.characterClass.id == 'druid') 'Druid Features',
    if (hasSpellcastingSupport(c)) 'Spellcasting',
    if (hasResources) 'Class Resources',
  ];
}

const _subclasses = {
  'barbarian': ['berserker', 'wild_heart', 'world_tree', 'zealot'],
  'cleric': ['life', 'light', 'trickery', 'war'],
  'druid': ['land', 'moon', 'sea', 'stars'],
  'fighter': ['battle_master', 'champion', 'eldritch_knight', 'psi_warrior'],
};

void main() {
  final cases = <String, Character>{};
  for (final cls in allClasses) {
    for (final level in [1, 20]) {
      cases['${cls.id} L$level'] = testCharacter(cls.id, level);
    }
    for (final sub in _subclasses[cls.id] ?? const <String>[]) {
      cases['${cls.id}/$sub L20'] = testCharacter(
        cls.id,
        20,
        selections: {
          '${cls.id}_subclass': {sub},
          // Druid choices made at level 3 and 7.
          if (cls.id == 'druid') 'druid_land_type': {'temperate'},
          if (cls.id == 'druid') 'druid_elemental_fury': {'primal_strike'},
        },
      );
    }
  }

  for (final entry in cases.entries) {
    testWidgets('combat screen shows every section: ${entry.key}', (
      tester,
    ) async {
      final db = await pumpCombatScreen(tester, entry.value);

      expect(tester.takeException(), isNull);
      for (final title in _expectedSections(entry.value)) {
        expect(
          await findInAnyTab(tester, find.text(title)),
          isTrue,
          reason: '"$title" missing for ${entry.key}',
        );
        expect(tester.takeException(), isNull, reason: title);
      }

      await disposeCombatScreen(tester, db);
    });
  }
}
