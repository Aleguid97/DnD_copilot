// Cleric spellcasting in combat: catalog from the chapter 7 headers, spell
// effects and the Life Domain healing features.

import 'package:dnd_prova/data/spell_effects_data.dart';
import 'package:dnd_prova/data/spells_data.dart';
import 'package:dnd_prova/models/dice_roller.dart';
import 'package:dnd_prova/models/spell_effect.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/combat_harness.dart';

void main() {
  test('Cleric list comes from chapter 7 headers', () {
    final list = classSpellLists['cleric']!;
    expect(list.length, 116);
    for (final id in [
      'sacred_flame',
      'toll_the_dead',
      'word_of_radiance',
      'bless',
      'spiritual_weapon',
      'spirit_guardians',
      'flame_strike',
      'mass_heal',
    ]) {
      expect(list, contains(id));
    }
    expect(allSpells['spirit_guardians']!.concentration, isTrue);
    expect(allSpells['clairvoyance']!.level, 3);
  });

  test('Flame Strike scales both damage types', () {
    final e = spellEffects['flame_strike']!;
    expect(
      scaledDice(e, spellLevel: 5, slotLevel: 7, characterLevel: 9),
      '7d6',
    );
    expect(
      scaledDice(
        e.withDice(e.extraDice, newUpcast: e.extraUpcastDice),
        spellLevel: 5,
        slotLevel: 7,
        characterLevel: 9,
      ),
      '7d6',
    );
  });

  group('combat', () {
    setUp(() => seedDiceRoller(42));

    testWidgets('Sacred Flame: Dex save, no damage on a success', (
      tester,
    ) async {
      final db = await pumpCombatScreen(
        tester,
        testCharacter(
          'cleric',
          1,
          selections: {
            'cleric_cantrips': {'sacred_flame', 'guidance', 'light'},
          },
        ),
      );
      await expectInTabs(tester, find.text('Spellcasting'), findsOneWidget);
      await expectInTabs(tester, find.text('Cantrips (3/3)'), findsOneWidget);
      await addAndTargetGoblin(tester, db);

      await tapAndSettle(
        tester,
        find.widgetWithText(ActionChip, 'Sacred Flame'),
      );
      await tapAndSettle(tester, find.text('Saved'));
      await tapAndSettle(tester, find.text('Apply').last);
      expect((await reloadGoblin(tester, db)).currentHp, 100);

      await tapAndSettle(
        tester,
        find.widgetWithText(ActionChip, 'Sacred Flame'),
      );
      await tapAndSettle(tester, find.text('Apply').last);
      final hp = (await reloadGoblin(tester, db)).currentHp;
      expect(100 - hp, inInclusiveRange(1, 8));
      await disposeCombatScreen(tester, db);
    });

    testWidgets('Toll the Dead uses d12s against a wounded target', (
      tester,
    ) async {
      final db = await pumpCombatScreen(
        tester,
        testCharacter(
          'cleric',
          1,
          selections: {
            'cleric_cantrips': {'toll_the_dead'},
          },
        ),
      );
      await addAndTargetGoblin(tester, db, currentHp: 90);
      await tapAndSettle(
        tester,
        find.widgetWithText(ActionChip, 'Toll the Dead'),
      );
      await tapAndSettle(tester, find.text('Apply').last);
      await expectInTabs(tester, textContaining('= '), findsWidgets);
      final hp = (await reloadGoblin(tester, db)).currentHp;
      expect(90 - hp, inInclusiveRange(1, 12));
      await disposeCombatScreen(tester, db);
    });

    testWidgets('Spirit Guardians damages and can be repeated', (tester) async {
      final db = await pumpCombatScreen(
        tester,
        testCharacter(
          'cleric',
          5,
          selections: {
            'cleric_prepared_spells': {'spirit_guardians'},
          },
        ),
      );
      await addAndTargetGoblin(tester, db);
      await tapAndSettle(tester, castButton('Spirit Guardians'));
      await tapAndSettle(tester, find.text('Level 3 (2/2 left)'));
      await expectInTabs(
        tester,
        find.text('Spirit Guardians: DC 13 Wisdom save'),
        findsOneWidget,
      );
      await tapAndSettle(tester, find.text('Apply').last);
      final first = (await reloadGoblin(tester, db)).currentHp;
      expect(100 - first, inInclusiveRange(3, 24));

      await tapAndSettle(tester, find.text('Repeat effect'));
      await tapAndSettle(tester, find.text('Apply').last);
      expect((await reloadGoblin(tester, db)).currentHp, lessThan(first));
      await disposeCombatScreen(tester, db);
    });

    testWidgets('Life Domain: Disciple of Life adds 2 + slot level', (
      tester,
    ) async {
      final db = await pumpCombatScreen(
        tester,
        testCharacter(
          'cleric',
          3,
          selections: {
            'cleric_subclass': {'life'},
            'cleric_prepared_spells': {'cure_wounds'},
          },
        ),
      );
      await tapAndSettle(tester, castButton('Cure Wounds'));
      await tapAndSettle(tester, find.text('Level 2 (2/2 left)'));
      await expectInTabs(
        tester,
        textContaining('Disciple of Life +4'),
        findsWidgets,
      );
      await expectInTabs(
        tester,
        textContaining('L2 (upcast) Cure Wounds: '),
        findsWidgets,
      );
      await disposeCombatScreen(tester, db);
    });
  });
}
