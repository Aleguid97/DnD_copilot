// Eldritch Knight: Wizard spell list, slots and Eldritch Strike (chapter 3).

import 'package:dnd_prova/data/spell_slots_data.dart';
import 'package:dnd_prova/data/spells_data.dart';
import 'package:dnd_prova/models/dice_roller.dart';
import 'package:dnd_prova/models/fighter_features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/combat_harness.dart';

Map<String, Set<String>> _ek([Map<String, Set<String>> more = const {}]) => {
  'fighter_subclass': {'eldritch_knight'},
  ...more,
};

void main() {
  setUp(() => seedDiceRoller(11));

  test('Wizard spell list from chapter 3 (242 spells)', () {
    final list = classSpellLists['wizard']!;
    expect(list, hasLength(242));
    expect(list.where((id) => allSpells[id]!.isCantrip), hasLength(20));
    expect(allSpells['magic_missile']!.level, 1);
    expect(allSpells['gentle_repose']!.material, isTrue);
    expect(allSpells['steel_wind_strike']!.material, isTrue);
    expect(allSpells['wish']!.level, 9);
  });

  test('Eldritch Knight table: prepared spells, cantrips and slots', () {
    expect([3, 7, 10, 19, 20].map(eldritchKnightPrepared), [3, 5, 7, 12, 13]);
    expect(eldritchKnightCantrips(9), 2);
    expect(eldritchKnightCantrips(10), 3);
    expect(eldritchKnightSlots(3, 1), 2);
    expect(eldritchKnightSlots(7, 2), 2);
    expect(eldritchKnightSlots(13, 3), 2);
    expect(eldritchKnightSlots(19, 4), 1);
    expect(eldritchKnightSlots(18, 4), 0);
  });

  test('Only Eldritch Knights among Fighters cast spells', () {
    expect(spellListIdFor(testCharacter('fighter', 3)), isNull);
    expect(
      spellListIdFor(testCharacter('fighter', 3, selections: _ek())),
      'wizard',
    );
  });

  testWidgets('Magic Missile: 3d4 + 3 Force with a level 1 slot', (
    tester,
  ) async {
    final db = await pumpCombatScreen(
      tester,
      testCharacter(
        'fighter',
        3,
        selections: _ek({
          'fighter_cantrips': {'fire_bolt'},
          'fighter_prepared_spells': {'magic_missile'},
        }),
      ),
    );
    await expectInTabs(tester, find.text('Cantrips (1/2)'), findsOneWidget);
    await addAndTargetGoblin(tester, db);
    await tapAndSettle(tester, castButton('Magic Missile'));
    await tapAndSettle(tester, find.text('Level 1 (2/2 left)'));
    final hp = (await reloadGoblin(tester, db)).currentHp;
    expect(100 - hp, inInclusiveRange(6, 15));
    await disposeCombatScreen(tester, db);
  });

  testWidgets('Eldritch Strike marks the target; a spell save uses it up', (
    tester,
  ) async {
    final db = await pumpCombatScreen(
      tester,
      testCharacter(
        'fighter',
        10,
        selections: _ek({
          'fighter_cantrips': {'mind_sliver'},
        }),
      ),
    );
    await equipItem(tester, db, 'longsword');
    await addAndTargetGoblin(tester, db);
    await tapAndSettle(tester, find.textContaining('Roll to Hit'));
    expect(
      (await reloadGoblin(tester, db)).conditionsJson,
      contains('Eldritch Strike'),
    );
    await tapAndSettle(tester, find.widgetWithText(ActionChip, 'Mind Sliver'));
    await tapAndSettle(tester, find.text('Apply').last);
    expect(
      (await reloadGoblin(tester, db)).conditionsJson,
      isNot(contains('Eldritch Strike')),
    );
    await disposeCombatScreen(tester, db);
  });
}
