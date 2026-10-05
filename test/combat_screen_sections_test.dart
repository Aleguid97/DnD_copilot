// Guards against the "swallowed sections" bug: an unbalanced bracket in one
// class block of the combat screen used to hide every section below it with
// no visible error. This test opens CombatScreen for every class (and every
// implemented subclass) at level 1 and 20 and checks that all sections render.

import 'dart:async';

import 'package:dnd_prova/data/backgrounds_data.dart';
import 'package:dnd_prova/data/class_resources_data.dart';
import 'package:dnd_prova/data/classes_data.dart';
import 'package:dnd_prova/data/database.dart';
import 'package:dnd_prova/data/races_data.dart';
import 'package:dnd_prova/models/ability_scores.dart';
import 'package:dnd_prova/models/background_ability_choice.dart';
import 'package:dnd_prova/models/character.dart';
import 'package:dnd_prova/models/character_basics.dart';
import 'package:dnd_prova/models/hit_points.dart';
import 'package:dnd_prova/state/database_provider.dart';
import 'package:dnd_prova/ui/screens/combat_screen.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Character _character(
  String classId,
  int level, {
  Map<String, Set<String>> selections = const {},
}) {
  return Character(
    id: 1,
    basics: const CharacterBasics(name: 'Test'),
    race: allRaces.first,
    raceSelections: const {},
    characterClass: allClasses.firstWhere((c) => c.id == classId),
    level: level,
    classSelections: selections,
    asiChoices: const [],
    background: allBackgrounds.first,
    backgroundAbilityChoice: const BackgroundAbilityChoice(),
    backgroundSelections: const {},
    abilityScores: AbilityScores(
      baseScores: {for (final a in Ability.values) a: 14},
    ),
    hitPoints: const HitPointsState(),
  );
}

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
    if (hasResources) 'Class Resources',
  ];
}

const _subclasses = {
  'barbarian': ['berserker', 'wild_heart', 'world_tree', 'zealot'],
  'cleric': ['life', 'light', 'trickery', 'war'],
  'fighter': ['battle_master', 'champion'],
};

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  final cases = <String, Character>{};
  for (final cls in allClasses) {
    for (final level in [1, 20]) {
      cases['${cls.id} L$level'] = _character(cls.id, level);
    }
    for (final sub in _subclasses[cls.id] ?? const <String>[]) {
      cases['${cls.id}/$sub L20'] = _character(
        cls.id,
        20,
        selections: {
          '${cls.id}_subclass': {sub},
        },
      );
    }
  }

  for (final entry in cases.entries) {
    testWidgets('combat screen shows every section: ${entry.key}', (
      tester,
    ) async {
      // Tall surface so the lazy ListView builds every section.
      tester.view.physicalSize = const Size(1200, 60000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final db = AppDatabase.forTesting(NativeDatabase.memory());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [appDatabaseProvider.overrideWithValue(db)],
          child: MaterialApp(home: CombatScreen(character: entry.value)),
        ),
      );
      // Drift queries need real async time; let them resolve, then rebuild.
      for (var i = 0; i < 5; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pump();
      }

      expect(tester.takeException(), isNull);
      for (final title in _expectedSections(entry.value)) {
        expect(
          find.text(title),
          findsOneWidget,
          reason: '"$title" missing for ${entry.key}',
        );
      }

      // Dispose the tree so drift stream timers are cancelled before teardown.
      // Closing must not be awaited: drift's shutdown relies on timers that
      // only fire when the fake clock is pumped.
      await tester.pumpWidget(const SizedBox.shrink());
      unawaited(db.close());
      await tester.pump(const Duration(seconds: 1));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(seconds: 1));
    });
  }
}
