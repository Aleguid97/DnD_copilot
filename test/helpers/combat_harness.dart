import 'dart:async';

import 'package:dnd_prova/data/backgrounds_data.dart';
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

/// A saved character (id 1) with 14 in every ability.
Character testCharacter(
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

/// Opens [CombatScreen] on a tall surface (so the lazy ListView builds every
/// section) backed by an in-memory database. Pair with [disposeCombatScreen].
Future<AppDatabase> pumpCombatScreen(
  WidgetTester tester,
  Character character,
) async {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  tester.view.physicalSize = const Size(1200, 60000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final db = AppDatabase.forTesting(NativeDatabase.memory());
  await tester.pumpWidget(
    ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: MaterialApp(home: CombatScreen(character: character)),
    ),
  );
  await settleDatabase(tester);
  return db;
}

/// Drift queries need real async time; let them resolve, then rebuild.
Future<void> settleDatabase(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump();
  }
}

/// Taps the first widget matching [finder] and waits for database writes.
Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
  await tester.tap(finder.first);
  await settleDatabase(tester);
}

/// Disposes the tree so drift stream timers are cancelled before teardown.
/// Closing must not be awaited: drift's shutdown relies on timers that only
/// fire when the fake clock is pumped.
Future<void> disposeCombatScreen(WidgetTester tester, AppDatabase db) async {
  await tester.pumpWidget(const SizedBox.shrink());
  unawaited(db.close());
  await tester.pump(const Duration(seconds: 1));
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 20)),
  );
  await tester.pump(const Duration(seconds: 1));
}
