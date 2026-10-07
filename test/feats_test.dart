// Origin feats from backgrounds and the Human's Versatile choice.

import 'package:dnd_prova/models/combat_stats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/combat_harness.dart';

void main() {
  test('Tough adds 2 Hit Points per level', () {
    final plain = testCharacter('fighter', 5, backgroundId: 'acolyte');
    final tough = testCharacter('fighter', 5, backgroundId: 'farmer');
    expect(tough.hasFeat('tough'), isTrue);
    expect(tough.totalHitPoints - plain.totalHitPoints, 10);
  });

  test(
    'Alert from the Human Versatile feat adds Proficiency to Initiative',
    () {
      final human = testCharacter(
        'fighter',
        5,
        backgroundId: 'farmer',
        raceId: 'human',
        raceSelections: {
          'human_versatile': {'alert'},
        },
      );
      final stats = CombatStats(character: human, equippedItems: const []);
      // Dex 14 (+2) + Proficiency 3.
      expect(stats.totalInitiative(3), 5);
    },
  );

  test('Tavern Brawler makes the Unarmed Strike 1d4', () {
    final sailor = testCharacter('fighter', 1, backgroundId: 'sailor');
    final info = CombatStats(
      character: sailor,
      equippedItems: const [],
    ).unarmedStrikeInfo(2);
    expect(info.damageDice, '1d4');
  });

  testWidgets('Lucky: Luck Points equal Proficiency, spent one at a time', (
    tester,
  ) async {
    final db = await pumpCombatScreen(
      tester,
      testCharacter('fighter', 5, backgroundId: 'merchant'),
    );
    expect(find.text('Feats'), findsOneWidget);
    expect(textContaining('Luck Points: 3/3'), findsOneWidget);
    await tapAndSettle(tester, find.text('Advantage (spend 1)'));
    expect(textContaining('Luck Points: 2/3'), findsOneWidget);
    await disposeCombatScreen(tester, db);
  });

  testWidgets('Savage Attacker arms and shows in the Feats section', (
    tester,
  ) async {
    final db = await pumpCombatScreen(
      tester,
      testCharacter('fighter', 1, backgroundId: 'soldier'),
    );
    await tapAndSettle(tester, find.text('Arm for the next weapon hit'));
    expect(
      textContaining('Armed: next weapon damage rolls twice'),
      findsOneWidget,
    );
    expect(find.byType(OutlinedButton), findsWidgets);
    await disposeCombatScreen(tester, db);
  });
}
