// Cleric spellcasting in combat: catalog from the chapter 7 headers, spell
// effects and the Life Domain healing features.

import 'package:dnd_prova/data/spell_effects_data.dart';
import 'package:dnd_prova/data/spells_data.dart';
import 'package:dnd_prova/models/cleric_features.dart';
import 'package:dnd_prova/models/dice_roller.dart';
import 'package:dnd_prova/models/spell_effect.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/combat_harness.dart';

void main() {
  test('Cleric list matches chapter 3 (117 spells)', () {
    final list = classSpellLists['cleric']!;
    expect(list.length, 117);
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

  test('Cleric table: cantrips, prepared spells, Channel Divinity', () {
    expect(clericCantripCount(testCharacter('cleric', 3)), 3);
    expect(clericCantripCount(testCharacter('cleric', 4)), 4);
    expect(clericCantripCount(testCharacter('cleric', 10)), 5);
    expect(
      clericCantripCount(
        testCharacter(
          'cleric',
          10,
          selections: {
            'cleric_divine_order': {'thaumaturge'},
          },
        ),
      ),
      6,
    );
    expect(clericPreparedSpellCount(1), 4);
    expect(clericPreparedSpellCount(5), 9);
    expect(clericPreparedSpellCount(12), 16);
    expect(clericPreparedSpellCount(20), 22);
    expect(channelDivinityUses(1), 0);
    expect(channelDivinityUses(5), 2);
    expect(channelDivinityUses(6), 3);
    expect(channelDivinityUses(18), 4);
  });

  test('Domain spells are all in the catalog', () {
    for (final domain in ['life', 'light', 'trickery', 'war']) {
      final spells = clericDomainSpells(
        testCharacter(
          'cleric',
          9,
          selections: {
            'cleric_subclass': {domain},
          },
        ),
      );
      expect(spells, hasLength(10), reason: domain);
      for (final name in spells) {
        expect(spellByName(name), isNotNull, reason: '$domain: $name');
      }
    }
  });

  test('War Domain spells unlock at Cleric levels 3, 5, 7 and 9', () {
    final war = {
      'cleric_subclass': {'war'},
    };
    expect(clericDomainSpells(testCharacter('cleric', 3, selections: war)), [
      'Guiding Bolt',
      'Magic Weapon',
      'Shield of Faith',
      'Spiritual Weapon',
    ]);
    final all = clericDomainSpells(testCharacter('cleric', 9, selections: war));
    expect(all, hasLength(10));
    for (final name in all) {
      expect(spellByName(name), isNotNull, reason: name);
    }
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
    testWidgets('War domain spells are always prepared and do not count', (
      tester,
    ) async {
      final db = await pumpCombatScreen(
        tester,
        testCharacter(
          'cleric',
          9,
          selections: {
            'cleric_subclass': {'war'},
          },
        ),
      );
      await expectInTabs(
        tester,
        find.text('Prepared Spells (0/14 + always prepared)'),
        findsOneWidget,
      );
      await expectInTabs(tester, find.text('Steel Wind Strike'), findsWidgets);
      await disposeCombatScreen(tester, db);
    });

    testWidgets("War God's Blessing: Channel Divinity, no slot, no "
        'Concentration', (tester) async {
      final db = await pumpCombatScreen(
        tester,
        testCharacter(
          'cleric',
          6,
          selections: {
            'cleric_subclass': {'war'},
          },
        ),
      );
      await addAndTargetGoblin(tester, db);
      await tapAndSettle(
        tester,
        find.widgetWithText(OutlinedButton, 'Spiritual Weapon'),
      );
      await expectInTabs(
        tester,
        textContaining("War God's Blessing, no slot"),
        findsWidgets,
      );
      expect(find.textContaining('Concentrating on'), findsNothing);
      await expectInTabs(tester, textContaining('(2/3 left)'), findsOneWidget);
      await expectInTabs(
        tester,
        find.text('Spiritual Weapon: attack again'),
        findsOneWidget,
      );
      await tapAndSettle(tester, find.text('Start combat'));
      await expectInTabs(
        tester,
        find.text('Spiritual Weapon: 10 rds'),
        findsOneWidget,
      );
      await disposeCombatScreen(tester, db);
    });

    testWidgets('Divine Intervention casts a spell without a slot', (
      tester,
    ) async {
      final db = await pumpCombatScreen(tester, testCharacter('cleric', 10));
      await addAndTargetGoblin(tester, db);
      await tapAndSettle(tester, find.text('Call on your deity'));
      await tester.scrollUntilVisible(
        find.text('Flame Strike'),
        300,
        scrollable: find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(Scrollable),
        ),
      );
      await tapAndSettle(tester, find.text('Flame Strike'));
      await tapAndSettle(tester, find.text('Apply').last);
      await expectInTabs(
        tester,
        textContaining('Divine Intervention, no slot'),
        findsWidgets,
      );
      expect((await reloadGoblin(tester, db)).currentHp, lessThan(100));
      await expectInTabs(
        tester,
        textContaining('0/1 (Long Rest)'),
        findsOneWidget,
      );
      await disposeCombatScreen(tester, db);
    });
  });
}
