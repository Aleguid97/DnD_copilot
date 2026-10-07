// Round tracker: Next round ages Concentration and Rage durations.

import 'package:dnd_prova/data/spell_durations_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/combat_harness.dart';

void main() {
  test(
    'Concentration durations come from chapter 7 (1 minute = 10 rounds)',
    () {
      expect(concentrationRounds['moonbeam'], 10);
      expect(concentrationRounds['spirit_guardians'], 100);
      expect(concentrationRounds['web'], 600);
    },
  );

  testWidgets('rolling Initiative starts combat at round 1', (tester) async {
    final db = await pumpCombatScreen(tester, testCharacter('fighter', 1));
    expect(find.text('Not in combat'), findsOneWidget);
    await tapAndSettle(tester, find.text('Initiative'));
    expect(find.text('Round 1'), findsOneWidget);
    await tapAndSettle(tester, find.text('Next round'));
    expect(find.text('Round 2'), findsOneWidget);
    await disposeCombatScreen(tester, db);
  });

  testWidgets('a 1-minute Concentration spell ends after 10 rounds', (
    tester,
  ) async {
    final db = await pumpCombatScreen(
      tester,
      testCharacter(
        'druid',
        1,
        selections: {
          'druid_prepared_spells': {'faerie_fire'},
        },
      ),
    );
    await tapAndSettle(tester, find.text('Start combat'));
    await tapAndSettle(tester, castButton('Faerie Fire'));
    await tapAndSettle(tester, find.text('Level 1 (2/2 left)'));
    expect(find.text('Faerie Fire: 10 rds'), findsOneWidget);

    for (var i = 0; i < 9; i++) {
      await tapAndSettle(tester, find.text('Next round'));
    }
    expect(find.text('Faerie Fire: 1 rds'), findsOneWidget);
    expect(find.text('Concentrating on Faerie Fire'), findsOneWidget);

    await tapAndSettle(tester, find.text('Next round'));
    expect(find.text('Concentrating on Faerie Fire'), findsNothing);
    expect(textContaining('Faerie Fire expired'), findsWidgets);
    await disposeCombatScreen(tester, db);
  });

  testWidgets('Rage ends when you do not extend it', (tester) async {
    final db = await pumpCombatScreen(tester, testCharacter('barbarian', 1));
    await tapAndSettle(tester, find.text('Activate Rage'));
    await tapAndSettle(tester, find.text('Start combat'));
    expect(find.text('Rage: 100 rds'), findsOneWidget);

    await tapAndSettle(tester, find.text('Next round'));
    await tapAndSettle(tester, find.text('Yes, extend it'));
    expect(find.text('Rage: 99 rds'), findsOneWidget);

    await tapAndSettle(tester, find.text('Next round'));
    await tapAndSettle(tester, find.text('No, Rage ends'));
    expect(find.text('Activate Rage'), findsOneWidget);
    expect(textContaining('Rage ended'), findsWidgets);
    await disposeCombatScreen(tester, db);
  });
}
