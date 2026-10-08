// Cleric features in combat: Channel Divinity uses and options, domain
// features (chapter 3 of the PHB 2024).

import 'package:dnd_prova/models/dice_roller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/combat_harness.dart';

void main() {
  setUp(() => seedDiceRoller(7));

  testWidgets('Channel Divinity: 2 uses at level 2, 3 at level 6', (
    tester,
  ) async {
    var db = await pumpCombatScreen(tester, testCharacter('cleric', 2));
    await expectInTabs(
      tester,
      find.text('Channel Divinity (2/2)'),
      findsOneWidget,
    );
    await disposeCombatScreen(tester, db);

    db = await pumpCombatScreen(tester, testCharacter('cleric', 6));
    await expectInTabs(
      tester,
      find.text('Channel Divinity (3/3)'),
      findsOneWidget,
    );
    await disposeCombatScreen(tester, db);
  });

  testWidgets('Divine Spark damage spends a use and hurts the target', (
    tester,
  ) async {
    final db = await pumpCombatScreen(tester, testCharacter('cleric', 2));
    await addAndTargetGoblin(tester, db);
    await tapAndSettle(tester, find.text('Divine Spark: damage'));
    await tapAndSettle(tester, find.text('Apply').last);
    expect((await reloadGoblin(tester, db)).currentHp, lessThan(100));
    await expectInTabs(
      tester,
      find.text('Channel Divinity (1/2)'),
      findsOneWidget,
    );
    await disposeCombatScreen(tester, db);
  });

  testWidgets('Turn Undead with Sear Undead: condition and Radiant damage', (
    tester,
  ) async {
    final db = await pumpCombatScreen(tester, testCharacter('cleric', 5));
    await addAndTargetGoblin(tester, db);
    await tapAndSettle(tester, find.text('Turn Undead'));
    await tapAndSettle(tester, find.text('Apply').last);
    final goblin = await reloadGoblin(tester, db);
    expect(goblin.currentHp, lessThan(100));
    expect(goblin.conditionsJson, contains('Turn Undead'));
    await disposeCombatScreen(tester, db);
  });

  testWidgets('Radiance of the Dawn: 2d10 + level, half on a save', (
    tester,
  ) async {
    final db = await pumpCombatScreen(
      tester,
      testCharacter(
        'cleric',
        3,
        selections: {
          'cleric_subclass': {'light'},
        },
      ),
    );
    await addAndTargetGoblin(tester, db);
    await tapAndSettle(tester, find.text('Radiance of the Dawn'));
    await tapAndSettle(tester, find.text('Saved'));
    await tapAndSettle(tester, find.text('Apply').last);
    // 2d10 + 3 = 5..23, halved on the save.
    expect(
      100 - (await reloadGoblin(tester, db)).currentHp,
      inInclusiveRange(2, 11),
    );
    await expectInTabs(
      tester,
      find.text('Warding Flare (2/2)'),
      findsOneWidget,
    );
    await tapAndSettle(tester, find.text('Use Warding Flare'));
    await expectInTabs(
      tester,
      find.text('Warding Flare (1/2)'),
      findsOneWidget,
    );
    await disposeCombatScreen(tester, db);
  });

  testWidgets('Preserve Life heals Bloodied allies up to half their HP', (
    tester,
  ) async {
    final db = await pumpCombatScreen(
      tester,
      testCharacter(
        'cleric',
        3,
        selections: {
          'cleric_subclass': {'life'},
        },
      ),
    );
    final ally = await runDb(tester, () => db.addPartyMember(1, 'Ally', 40));
    await runDb(tester, () => db.updatePartyMemberHp(ally, 10));
    await tapAndSettle(tester, find.text('Preserve Life'));
    await tapAndSettle(tester, find.text('Max'));
    await tapAndSettle(tester, find.text('Heal'));
    final member = await runDb(
      tester,
      () => db.select(db.partyMembers).getSingle(),
    );
    expect(member.currentHp, 20);
    await expectInTabs(
      tester,
      find.text('Channel Divinity (1/2)'),
      findsOneWidget,
    );
    await disposeCombatScreen(tester, db);
  });

  testWidgets('Avatar of Battle halves Bludgeoning/Piercing/Slashing damage', (
    tester,
  ) async {
    var db = await pumpCombatScreen(tester, testCharacter('cleric', 17));
    expect(textContaining('Avatar of Battle'), findsNothing);
    await disposeCombatScreen(tester, db);

    db = await pumpCombatScreen(
      tester,
      testCharacter(
        'cleric',
        17,
        selections: {
          'cleric_subclass': {'war'},
        },
      ),
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Amount (+heal / -damage)'),
      '-11',
    );
    await tapAndSettle(tester, find.widgetWithText(ElevatedButton, 'Apply'));
    await expectInTabs(
      tester,
      textContaining('Resistance (Avatar of Battle): damage halved to 5'),
      findsWidgets,
    );
    await disposeCombatScreen(tester, db);
  });

  testWidgets('Resources show when they come back; spells have tooltips', (
    tester,
  ) async {
    final db = await pumpCombatScreen(
      tester,
      testCharacter(
        'cleric',
        5,
        selections: {
          'cleric_cantrips': {'sacred_flame'},
          'cleric_prepared_spells': {'bless'},
        },
      ),
    );
    await expectInTabs(
      tester,
      textContaining('1 back on a Short Rest, all on a Long Rest'),
      findsWidgets,
    );
    await openTab(tester, 'Spells');
    final chip = tester.widget<ActionChip>(
      find.widgetWithText(ActionChip, 'Sacred Flame'),
    );
    expect(chip.tooltip, contains('Cantrip'));
    expect(chip.tooltip, contains('Dex save'));
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is Tooltip &&
            (w.message?.contains('Concentration, up to 1 min') ?? false),
      ),
      findsOneWidget,
    );
    await disposeCombatScreen(tester, db);
  });
}
