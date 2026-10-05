// Exercises the Druid combat section: Wild Shape, spell slots, Wild
// Resurgence and each circle's active features (character has 14 in every
// ability, so every modifier is +2).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/combat_harness.dart';

Finder _textContaining(String part) =>
    find.byWidgetPredicate((w) => w is Text && (w.data ?? '').contains(part));

Finder _skillRollButton(String skill) => find.descendant(
  of: find.widgetWithText(ListTile, skill),
  matching: find.byType(OutlinedButton),
);

void main() {
  testWidgets('Wild Shape spends a use and grants Temp HP = Druid level', (
    tester,
  ) async {
    final db = await pumpCombatScreen(tester, testCharacter('druid', 2));
    expect(_textContaining('2/2 uses'), findsOneWidget);

    await tapAndSettle(tester, find.text('Shape-shift (spend use)'));

    expect(find.text('Leave form'), findsOneWidget);
    expect(_textContaining('1/2 uses'), findsOneWidget);
    expect(find.text('+ 2 Temporary HP (Wild Shape)'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await disposeCombatScreen(tester, db);
  });

  testWidgets('Circle of the Moon: 3× level Temp HP and +Wis to Con saves', (
    tester,
  ) async {
    final db = await pumpCombatScreen(
      tester,
      testCharacter(
        'druid',
        6,
        selections: {
          'druid_subclass': {'moon'},
        },
      ),
    );
    await tapAndSettle(tester, find.text('Saving Throws'));
    final conSave = find.descendant(
      of: find.widgetWithText(ListTile, 'CON Save'),
      matching: find.byType(OutlinedButton),
    );
    expect(
      find.descendant(of: conSave, matching: find.text('Roll (+2)')),
      findsOneWidget,
    );

    await tapAndSettle(tester, find.text('Shape-shift (spend use)'));

    expect(find.text('+ 18 Temporary HP (Wild Shape)'), findsOneWidget);
    expect(
      find.descendant(of: conSave, matching: find.text('Roll (+4)')),
      findsOneWidget,
    );
    expect(_textContaining('max CR 2'), findsOneWidget);
    await disposeCombatScreen(tester, db);
  });

  testWidgets('spell slots and Wild Resurgence (use → level 1 slot)', (
    tester,
  ) async {
    final db = await pumpCombatScreen(tester, testCharacter('druid', 5));
    expect(find.text('L1  4/4'), findsOneWidget);
    expect(find.text('L3  2/2'), findsOneWidget);

    await tapAndSettle(tester, find.byTooltip('Expend a level 1 slot'));
    expect(find.text('L1  3/4'), findsOneWidget);

    await tapAndSettle(tester, find.text('Resurgence: use → L1 slot (1/1)'));
    expect(find.text('L1  4/4'), findsOneWidget);
    expect(_textContaining('1/2 uses'), findsOneWidget);
    expect(find.text('Resurgence: use → L1 slot (0/1)'), findsOneWidget);
    await disposeCombatScreen(tester, db);
  });

  testWidgets('Magician adds Wisdom modifier to Arcana and Nature', (
    tester,
  ) async {
    final db = await pumpCombatScreen(
      tester,
      testCharacter(
        'druid',
        1,
        selections: {
          'druid_primal_order': {'magician'},
        },
      ),
    );
    await tapAndSettle(tester, find.text('Skill Checks'));
    for (final skill in ['Arcana', 'Nature']) {
      final label = tester
          .widget<Text>(
            find.descendant(
              of: _skillRollButton(skill),
              matching: find.byType(Text),
            ),
          )
          .data!;
      // +2 Int, +2 Magician, +2 proficiency only if the background grants it.
      expect(label, anyOf('Roll (+4)', 'Roll (+6)'), reason: skill);
    }
    await disposeCombatScreen(tester, db);
  });

  testWidgets('Circle of the Stars: Starry Form Archer attack', (tester) async {
    final db = await pumpCombatScreen(
      tester,
      testCharacter(
        'druid',
        10,
        selections: {
          'druid_subclass': {'stars'},
        },
      ),
    );
    await tapAndSettle(tester, find.widgetWithText(ElevatedButton, 'Archer'));
    expect(find.text('Starry Form (active)'), findsOneWidget);

    await tapAndSettle(tester, find.text('Archer attack'));
    expect(_textContaining('Archer: '), findsWidgets);

    await tapAndSettle(tester, find.text('End form'));
    expect(find.text('Starry Form'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await disposeCombatScreen(tester, db);
  });

  testWidgets('Circle of the Sea: Wrath of the Sea manifest and dismiss', (
    tester,
  ) async {
    final db = await pumpCombatScreen(
      tester,
      testCharacter(
        'druid',
        10,
        selections: {
          'druid_subclass': {'sea'},
        },
      ),
    );
    await tapAndSettle(tester, find.text('Manifest (spend Wild Shape)'));
    expect(find.text('Wrath of the Sea (active)'), findsOneWidget);
    expect(_textContaining('Stormborn'), findsOneWidget);

    await tapAndSettle(tester, find.text('Dismiss'));
    expect(find.text('Wrath of the Sea'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await disposeCombatScreen(tester, db);
  });

  testWidgets('Circle of the Land: Land\'s Aid and Natural Recovery', (
    tester,
  ) async {
    final db = await pumpCombatScreen(
      tester,
      testCharacter(
        'druid',
        14,
        selections: {
          'druid_subclass': {'land'},
          'druid_land_type': {'polar'},
        },
      ),
    );
    expect(_textContaining('Cone of Cold'), findsWidgets);
    expect(_textContaining('Resistance to Cold'), findsOneWidget);

    await tapAndSettle(tester, find.text('Use (spend Wild Shape)'));
    expect(find.text('Heal myself'), findsOneWidget);
    await tapAndSettle(tester, find.text('Heal myself'));

    // Spend two level 2 slots, then recover them with Natural Recovery.
    await tapAndSettle(tester, find.byTooltip('Expend a level 2 slot'));
    await tapAndSettle(tester, find.byTooltip('Expend a level 2 slot'));
    expect(find.text('L2  1/3'), findsOneWidget);
    await tapAndSettle(tester, find.text('Recover slots'));
    final addLevel2 = find.descendant(
      of: find.widgetWithText(Row, 'Level 2 (2 spent)'),
      matching: find.byIcon(Icons.add),
    );
    await tapAndSettle(tester, addLevel2);
    await tapAndSettle(tester, addLevel2);
    await tapAndSettle(tester, find.text('Recover'));
    expect(find.text('L2  3/3'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await disposeCombatScreen(tester, db);
  });

  testWidgets('Archdruid: Nature Magician converts uses into a slot', (
    tester,
  ) async {
    final db = await pumpCombatScreen(tester, testCharacter('druid', 20));
    await tapAndSettle(tester, find.byTooltip('Expend a level 4 slot'));
    expect(find.text('L4  2/3'), findsOneWidget);

    await tapAndSettle(tester, find.text('Nature Magician (1/1)'));
    await tapAndSettle(tester, find.text('2 uses → level 4 slot'));

    expect(find.text('L4  3/3'), findsOneWidget);
    expect(_textContaining('2/4 uses'), findsOneWidget);
    await disposeCombatScreen(tester, db);
  });

  testWidgets('saving throws and skill checks start collapsed', (tester) async {
    final db = await pumpCombatScreen(tester, testCharacter('druid', 1));
    expect(find.text('CON Save'), findsNothing);
    expect(find.text('Arcana'), findsNothing);
    await tapAndSettle(tester, find.text('Saving Throws'));
    expect(find.text('CON Save'), findsOneWidget);
    await disposeCombatScreen(tester, db);
  });

  testWidgets('casting a prepared spell expends a slot, upcasting allowed', (
    tester,
  ) async {
    final db = await pumpCombatScreen(
      tester,
      testCharacter(
        'druid',
        5,
        selections: {
          'druid_cantrips': {'guidance', 'produce_flame'},
          'druid_prepared_spells': {'cure_wounds', 'faerie_fire', 'moonbeam'},
        },
      ),
    );
    expect(find.text('Spellcasting'), findsOneWidget);
    expect(find.text('Cantrips (2/3)'), findsOneWidget);
    expect(_textContaining('Prepared Spells (3/9'), findsOneWidget);

    Finder castButton(String spell) => find.descendant(
      of: find.widgetWithText(ListTile, spell),
      matching: find.widgetWithText(OutlinedButton, 'Cast'),
    );

    // Cure Wounds (level 1) cast with a level 2 slot.
    await tapAndSettle(tester, castButton('Cure Wounds'));
    await tapAndSettle(tester, find.text('Level 2 (3/3 left)'));
    expect(find.text('L2  2/3'), findsOneWidget);
    expect(find.text('L1  4/4'), findsOneWidget);
    expect(_textContaining('L2 (upcast) Cure Wounds: '), findsOneWidget);

    // Moonbeam (level 2, Concentration): level 1 slots are not offered.
    await tapAndSettle(tester, castButton('Moonbeam'));
    expect(find.text('Level 1 (4/4 left)'), findsNothing);
    await tapAndSettle(tester, find.text('Level 2 (2/3 left)'));
    expect(find.text('Concentrating on Moonbeam'), findsOneWidget);

    // Another Concentration spell replaces it.
    await tapAndSettle(tester, castButton('Faerie Fire'));
    await tapAndSettle(tester, find.text('Level 1 (4/4 left)'));
    expect(find.text('Concentrating on Faerie Fire'), findsOneWidget);
    expect(_textContaining('Concentration on Moonbeam ended'), findsOneWidget);

    // Cantrips cost nothing.
    await tapAndSettle(
      tester,
      find.widgetWithText(ActionChip, 'Produce Flame'),
    );
    expect(find.text('L1  3/4'), findsOneWidget);

    // Speak with Animals is always prepared (Druidic).
    expect(find.widgetWithText(ListTile, 'Speak with Animals'), findsOneWidget);
    await disposeCombatScreen(tester, db);
  });

  testWidgets('no spellcasting in Wild Shape before Beast Spells', (
    tester,
  ) async {
    final db = await pumpCombatScreen(
      tester,
      testCharacter(
        'druid',
        5,
        selections: {
          'druid_prepared_spells': {'cure_wounds'},
        },
      ),
    );
    await tapAndSettle(tester, find.text('Shape-shift (spend use)'));
    expect(
      find.descendant(
        of: find.widgetWithText(ListTile, 'Cure Wounds'),
        matching: find.text('Not in Wild Shape'),
      ),
      findsOneWidget,
    );
    await disposeCombatScreen(tester, db);
  });

  testWidgets('changing prepared spells respects the table limit', (
    tester,
  ) async {
    final db = await pumpCombatScreen(tester, testCharacter('druid', 1));
    await tapAndSettle(
      tester,
      find.descendant(
        of: find.ancestor(
          of: _textContaining('Prepared Spells'),
          matching: find.byType(Row),
        ),
        matching: find.text('Change'),
      ),
    );
    for (final s in [
      'Animal Friendship',
      'Charm Person',
      'Create or Destroy Water',
      'Cure Wounds',
    ]) {
      await tapAndSettle(tester, find.widgetWithText(CheckboxListTile, s));
    }
    // Limit (4 at level 1) reached: other boxes are disabled.
    final detectMagic = tester.widget<CheckboxListTile>(
      find.widgetWithText(CheckboxListTile, 'Detect Magic'),
    );
    expect(detectMagic.onChanged, isNull);
    await tapAndSettle(tester, find.text('Save'));
    expect(_textContaining('Prepared Spells (4/4'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Charm Person'), findsOneWidget);
    await disposeCombatScreen(tester, db);
  });
}
