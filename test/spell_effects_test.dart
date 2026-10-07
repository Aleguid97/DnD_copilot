// Spell effect data and dice scaling (2024 PHB chapter 7), plus the combat
// engine applying damage, conditions and healing.

import 'dart:convert';

import 'package:dnd_prova/data/spell_effects_data.dart';
import 'package:dnd_prova/data/spells_data.dart';
import 'package:dnd_prova/models/dice_roller.dart';
import 'package:dnd_prova/models/druid_features.dart';
import 'package:dnd_prova/models/spell_effect.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/combat_harness.dart';

String? _dice(String id, int slot, {int characterLevel = 1}) => scaledDice(
  spellEffects[id]!,
  spellLevel: allSpells[id]!.level,
  slotLevel: slot,
  characterLevel: characterLevel,
);

void main() {
  group('data', () {
    test('every spell with an effect is in the catalog', () {
      for (final id in spellEffects.keys) {
        expect(allSpells.containsKey(id), isTrue, reason: id);
      }
    });

    test('every Druid circle spell is catalogued', () {
      for (final table in [
        ...landCircleSpells.values,
        moonCircleSpells,
        seaCircleSpells,
      ]) {
        for (final names in table.values) {
          for (final n in names) {
            expect(spellByName(n), isNotNull, reason: n);
          }
        }
      }
    });

    test('upcasting adds dice per slot level above the spell level', () {
      expect(_dice('moonbeam', 2), '2d10');
      expect(_dice('moonbeam', 4), '4d10');
      expect(_dice('cure_wounds', 3), '6d8');
      expect(_dice('thunderwave', 1), '2d8');
      // Conjure Woodland Beings counts from slot 5 as printed.
      expect(_dice('conjure_woodland_beings', 5), '5d8');
      expect(_dice('conjure_woodland_beings', 6), '6d8');
      expect(
        scaledFlat(spellEffects['heal']!, spellLevel: 6, slotLevel: 8),
        90,
      );
    });

    test('cantrips gain a die at levels 5, 11 and 17', () {
      expect(_dice('produce_flame', 0, characterLevel: 4), '1d8');
      expect(_dice('produce_flame', 0, characterLevel: 5), '2d8');
      expect(_dice('produce_flame', 0, characterLevel: 11), '3d8');
      expect(_dice('poison_spray', 0, characterLevel: 17), '4d12');
    });
  });

  group('combat', () {
    setUp(() => seedDiceRoller(42));

    testWidgets('spell attack hits the target and lowers its HP', (
      tester,
    ) async {
      final db = await pumpCombatScreen(
        tester,
        testCharacter(
          'druid',
          5,
          selections: {
            'druid_cantrips': {'produce_flame'},
          },
        ),
      );
      await addAndTargetGoblin(tester, db);

      await tapAndSettle(
        tester,
        find.widgetWithText(ActionChip, 'Produce Flame'),
      );

      final goblin = await reloadGoblin(tester, db);
      expect(goblin.currentHp, lessThan(100));
      await expectInTabs(
        tester,
        textContaining('ranged spell attack'),
        findsWidgets,
      );
      await expectInTabs(tester, textContaining('Fire'), findsWidgets);
      await disposeCombatScreen(tester, db);
    });

    testWidgets('save spell: failed save takes damage, can be repeated', (
      tester,
    ) async {
      final db = await pumpCombatScreen(
        tester,
        testCharacter(
          'druid',
          5,
          selections: {
            'druid_prepared_spells': {'moonbeam'},
          },
        ),
      );
      await addAndTargetGoblin(tester, db);

      await tapAndSettle(tester, castButton('Moonbeam'));
      await tapAndSettle(tester, find.text('Level 3 (2/2 left)'));
      // Target preselected as "Failed".
      await expectInTabs(
        tester,
        find.text('Moonbeam: DC 13 Constitution save'),
        findsOneWidget,
      );
      await tapAndSettle(tester, find.text('Apply').last);

      final afterFirst = (await reloadGoblin(tester, db)).currentHp;
      // 3d10 at slot 3: between 3 and 30 damage.
      expect(100 - afterFirst, inInclusiveRange(3, 30));
      await expectInTabs(
        tester,
        find.text('Concentrating on Moonbeam'),
        findsOneWidget,
      );

      await tapAndSettle(tester, find.text('Repeat effect'));
      await tapAndSettle(tester, find.text('Saved'));
      await tapAndSettle(tester, find.text('Apply').last);
      final afterSecond = (await reloadGoblin(tester, db)).currentHp;
      // Half damage on a save.
      expect(afterFirst - afterSecond, inInclusiveRange(1, 15));
      await disposeCombatScreen(tester, db);
    });

    testWidgets('Entangle restrains; ending Concentration removes it', (
      tester,
    ) async {
      final db = await pumpCombatScreen(
        tester,
        testCharacter(
          'druid',
          1,
          selections: {
            'druid_prepared_spells': {'entangle'},
          },
        ),
      );
      await addAndTargetGoblin(tester, db);

      await tapAndSettle(tester, castButton('Entangle'));
      await tapAndSettle(tester, find.text('Level 1 (2/2 left)'));
      await tapAndSettle(tester, find.text('Apply').last);
      expect(
        jsonDecode((await reloadGoblin(tester, db)).conditionsJson),
        contains('Restrained (Entangle)'),
      );

      await tapAndSettle(tester, find.widgetWithText(OutlinedButton, 'End'));
      expect(
        jsonDecode((await reloadGoblin(tester, db)).conditionsJson),
        isEmpty,
      );
      expect(find.text('Concentrating on Entangle'), findsNothing);
      await disposeCombatScreen(tester, db);
    });

    testWidgets('Faerie Fire outline gives Advantage to spell attacks', (
      tester,
    ) async {
      final db = await pumpCombatScreen(
        tester,
        testCharacter(
          'druid',
          1,
          selections: {
            'druid_cantrips': {'starry_wisp'},
            'druid_prepared_spells': {'faerie_fire'},
          },
        ),
      );
      await addAndTargetGoblin(tester, db);
      await tapAndSettle(tester, castButton('Faerie Fire'));
      await tapAndSettle(tester, find.text('Level 1 (2/2 left)'));
      await tapAndSettle(tester, find.text('Apply').last);

      await tapAndSettle(
        tester,
        find.widgetWithText(ActionChip, 'Starry Wisp'),
      );
      await expectInTabs(tester, textContaining('(Advantage '), findsWidgets);
      await disposeCombatScreen(tester, db);
    });

    testWidgets('healing spells restore your Hit Points', (tester) async {
      final db = await pumpCombatScreen(
        tester,
        testCharacter(
          'druid',
          1,
          selections: {
            'druid_prepared_spells': {'cure_wounds'},
          },
        ),
      );
      await tapAndSettle(tester, castButton('Cure Wounds'));
      await tapAndSettle(tester, find.text('Level 1 (2/2 left)'));

      await expectInTabs(tester, textContaining('Cure Wounds: '), findsWidgets);
      await expectInTabs(tester, textContaining('→ you: '), findsWidgets);
      await disposeCombatScreen(tester, db);
    });
  });
}
