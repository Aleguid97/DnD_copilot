// Fighter features in combat (chapter 3 of the PHB 2024).

import 'package:dnd_prova/models/fighter_features.dart';
import 'package:dnd_prova/models/dice_roller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/combat_harness.dart';

void main() {
  setUp(() => seedDiceRoller(3));

  test('Fighter table: Second Wind and Weapon Mastery counts', () {
    expect([1, 4, 10].map(secondWindUses), [2, 3, 4]);
    expect([1, 4, 10, 16].map(fighterWeaponMasteryCount), [3, 4, 5, 6]);
  });

  test('Champion crit range: 19 at level 3, 18 at level 15', () {
    Map<String, Set<String>> champ() => {
      'fighter_subclass': {'champion'},
    };
    expect(weaponCritThreshold(testCharacter('fighter', 2)), 20);
    expect(
      weaponCritThreshold(testCharacter('fighter', 3, selections: champ())),
      19,
    );
    expect(
      weaponCritThreshold(testCharacter('fighter', 15, selections: champ())),
      18,
    );
  });

  test('Weapon Mastery picks at 4/10/16 add to the level 1 choice', () {
    final c = testCharacter(
      'fighter',
      10,
      selections: {
        'fighter_weapon_mastery': {'longsword', 'longbow', 'dagger'},
        'fighter_weapon_mastery_4': {'greatsword'},
        'fighter_weapon_mastery_10': {'maul'},
      },
    );
    expect(masteredWeaponIds(c), hasLength(5));
  });

  testWidgets('Second Wind heals and has 3 uses at level 4', (tester) async {
    final db = await pumpCombatScreen(tester, testCharacter('fighter', 4));
    await expectInTabs(tester, find.text('Second Wind (3/3)'), findsOneWidget);
    await tapAndSettle(tester, find.text('Use Second Wind'));
    await expectInTabs(tester, find.text('Second Wind (2/3)'), findsOneWidget);
    await expectInTabs(tester, textContaining('Second Wind: '), findsWidgets);
    await disposeCombatScreen(tester, db);
  });

  testWidgets('Mastery only for chosen weapons; Tactical Master swaps it', (
    tester,
  ) async {
    var db = await pumpCombatScreen(tester, testCharacter('wizard', 1));
    await equipItem(tester, db, 'longsword');
    expect(await findInAnyTab(tester, textContaining('Mastery')), isFalse);
    await disposeCombatScreen(tester, db);

    db = await pumpCombatScreen(
      tester,
      testCharacter(
        'fighter',
        9,
        selections: {
          'fighter_weapon_mastery': {'longsword'},
        },
      ),
    );
    await equipItem(tester, db, 'longsword');
    await expectInTabs(
      tester,
      find.text('Mastery (Tactical Master):'),
      findsOneWidget,
    );
    await tapAndSettle(tester, find.widgetWithText(ChoiceChip, 'Push'));
    final push = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, 'Push'),
    );
    expect(push.selected, isTrue);
    await disposeCombatScreen(tester, db);
  });

  testWidgets('Indomitable rerolls the last save with + Fighter level', (
    tester,
  ) async {
    final db = await pumpCombatScreen(tester, testCharacter('fighter', 9));
    await tapAndSettle(tester, find.textContaining('Roll ('));
    await tapAndSettle(tester, find.text('Reroll failed save'));
    await expectInTabs(
      tester,
      textContaining('Indomitable: STR save reroll'),
      findsWidgets,
    );
    await expectInTabs(tester, find.text('Indomitable (0/1)'), findsOneWidget);
    await disposeCombatScreen(tester, db);
  });

  testWidgets('Champion: Heroic Warrior refills Heroic Inspiration', (
    tester,
  ) async {
    final db = await pumpCombatScreen(
      tester,
      testCharacter(
        'fighter',
        10,
        selections: {
          'fighter_subclass': {'champion'},
        },
      ),
    );
    await tapAndSettle(tester, find.text('Start combat'));
    await tapAndSettle(tester, find.text('Next round'));
    await expectInTabs(
      tester,
      textContaining('Heroic Inspiration gained'),
      findsWidgets,
    );
    await expectInTabs(
      tester,
      find.text('Use Heroic Inspiration'),
      findsOneWidget,
    );
    await disposeCombatScreen(tester, db);
  });
}
