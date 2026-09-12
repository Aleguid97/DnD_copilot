import 'character.dart';
import 'character_choices.dart';

class SpellSelection {
  final String sourceTitle; // e.g. "Cleric cantrips", "Magic Initiate (Cleric)"
  final List<String> spellNames;

  const SpellSelection({required this.sourceTitle, required this.spellNames});
}

class CharacterSpellbook {
  final List<SpellSelection> cantrips;
  final List<SpellSelection> spells;

  const CharacterSpellbook({required this.cantrips, required this.spells});

  bool get isEmpty => cantrips.isEmpty && spells.isEmpty;
}

CharacterSpellbook characterSpellbook(Character character) {
  final allSelections = <String, Set<String>>{
    ...character.raceSelections,
    ...character.classSelections,
    ...character.backgroundSelections,
  };

  final cantrips = <SpellSelection>[];
  final spells = <SpellSelection>[];

  for (final choice in allActiveChoicesForCharacter(character)) {
    final idLower = choice.id.toLowerCase();
    final titleLower = choice.title.toLowerCase();
    final isSpellRelated =
        idLower.contains('spell') || idLower.contains('cantrip');
    if (!isSpellRelated) continue;

    final selectedIds = allSelections[choice.id] ?? const {};
    final labels = choice.options
        .where((o) => selectedIds.contains(o.id))
        .map((o) => o.label)
        .toList();
    if (labels.isEmpty) continue;

    final entry = SpellSelection(sourceTitle: choice.title, spellNames: labels);
    if (titleLower.contains('cantrip')) {
      cantrips.add(entry);
    } else {
      spells.add(entry);
    }
  }

  return CharacterSpellbook(cantrips: cantrips, spells: spells);
}
