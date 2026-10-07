// Round tracker: Next round ages Concentration and Rage durations.

import 'package:dnd_prova/data/spell_durations_data.dart';
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
    await expectInTabs(tester, find.text('Not in combat'), findsOneWidget);
    await tapAndSettle(tester, find.text('Initiative'));
    await expectInTabs(tester, find.text('Round 1'), findsOneWidget);
    await tapAndSettle(tester, find.text('Next round'));
    await expectInTabs(tester, find.text('Round 2'), findsOneWidget);
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
    await expectInTabs(
      tester,
      find.text('Faerie Fire: 10 rds'),
      findsOneWidget,
    );

    for (var i = 0; i < 9; i++) {
      await tapAndSettle(tester, find.text('Next round'));
    }
    await expectInTabs(tester, find.text('Faerie Fire: 1 rds'), findsOneWidget);
    await expectInTabs(
      tester,
      find.text('Concentrating on Faerie Fire'),
      findsOneWidget,
    );

    await tapAndSettle(tester, find.text('Next round'));
    expect(find.text('Concentrating on Faerie Fire'), findsNothing);
    await expectInTabs(
      tester,
      textContaining('Faerie Fire expired'),
      findsWidgets,
    );
    await disposeCombatScreen(tester, db);
  });

  testWidgets('Rage ends when you do not extend it', (tester) async {
    final db = await pumpCombatScreen(tester, testCharacter('barbarian', 1));
    await tapAndSettle(tester, find.text('Activate Rage'));
    await tapAndSettle(tester, find.text('Start combat'));
    await expectInTabs(tester, find.text('Rage: 100 rds'), findsOneWidget);

    await tapAndSettle(tester, find.text('Next round'));
    await tapAndSettle(tester, find.text('Yes, extend it'));
    await expectInTabs(tester, find.text('Rage: 99 rds'), findsOneWidget);

    await tapAndSettle(tester, find.text('Next round'));
    await tapAndSettle(tester, find.text('No, Rage ends'));
    await expectInTabs(tester, find.text('Activate Rage'), findsOneWidget);
    await expectInTabs(tester, textContaining('Rage ended'), findsWidgets);
    await disposeCombatScreen(tester, db);
  });
}
