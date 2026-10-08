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
  String? backgroundId,
  String? raceId,
  Map<String, Set<String>> raceSelections = const {},
}) {
  return Character(
    id: 1,
    basics: const CharacterBasics(name: 'Test'),
    race: raceId == null
        ? allRaces.first
        : allRaces.firstWhere((r) => r.id == raceId),
    raceSelections: raceSelections,
    characterClass: allClasses.firstWhere((c) => c.id == classId),
    level: level,
    classSelections: selections,
    asiChoices: const [],
    background: backgroundId == null
        ? allBackgrounds.first
        : allBackgrounds.firstWhere((b) => b.id == backgroundId),
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

/// Taps the first widget matching [finder] (switching Combat tab if it is on
/// another one) and waits for database writes.
Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) await findInAnyTab(tester, finder);
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

Finder textContaining(String part) =>
    find.byWidgetPredicate((w) => w is Text && (w.data ?? '').contains(part));

/// The "Cast" button of a prepared spell row.
Finder castButton(String spell) => find.descendant(
  of: find.widgetWithText(ListTile, spell),
  matching: find.widgetWithText(OutlinedButton, 'Cast'),
);

/// Runs a database call inside the widget test's clock (drift streams are
/// bound to it), letting it complete while frames are pumped.
Future<T> runDb<T>(WidgetTester tester, Future<T> Function() call) async {
  final future = call();
  await settleDatabase(tester);
  return future;
}

/// Adds a 100 HP, AC 1 "Goblin" enemy and selects it as the target.
Future<void> addAndTargetGoblin(
  WidgetTester tester,
  AppDatabase db, {
  int currentHp = 100,
}) async {
  final id = await runDb(
    tester,
    () => db.addEnemy(1, 'Goblin', 100, armorClass: 1),
  );
  if (currentHp != 100) {
    await runDb(tester, () => db.updateEnemyHp(id, currentHp));
  }
  await tapAndSettle(tester, find.byType(DropdownButton<int?>));
  await tapAndSettle(tester, find.textContaining('Goblin (AC 1').last);
}

Future<CombatEnemy> reloadGoblin(WidgetTester tester, AppDatabase db) =>
    runDb(tester, () => db.select(db.combatEnemies).getSingle());

/// Opens a tab of the Combat screen (Overview, Checks, Attacks, Spells, Class).
Future<void> openTab(WidgetTester tester, String label) async {
  await tester.tap(find.widgetWithText(Tab, label));
  await tester.pumpAndSettle(const Duration(milliseconds: 100));
  await settleDatabase(tester);
}

/// Whether [finder] matches something in any tab; leaves that tab open.
Future<bool> findInAnyTab(WidgetTester tester, Finder finder) async {
  for (final tab in tester.widgetList<Tab>(find.byType(Tab)).toList()) {
    await openTab(tester, tab.text!);
    if (finder.evaluate().isNotEmpty) return true;
  }
  return false;
}

/// Like `expect(finder, matcher)` but first opens the tab that shows it.
Future<void> expectInTabs(
  WidgetTester tester,
  Finder finder,
  Matcher matcher, {
  String? reason,
}) async {
  if (finder.evaluate().isEmpty) await findInAnyTab(tester, finder);
  expect(finder, matcher, reason: reason);
}

/// Adds [itemId] to the test character's inventory and equips it.
Future<void> equipItem(
  WidgetTester tester,
  AppDatabase db,
  String itemId,
) async {
  await runDb(tester, () => db.addInventoryItem(1, itemId));
  final row = await runDb(
    tester,
    () => (db.select(
      db.characterInventoryItems,
    )..where((t) => t.itemId.equals(itemId))).getSingle(),
  );
  await runDb(tester, () => db.toggleEquipped(row.id, true));
}
