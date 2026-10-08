import '../data/skills_data.dart';
import 'character.dart';

/// Gathers every skill the character is proficient in, from all sources:
/// Background (fixed list AND any Choice-based picks like Skilled),
/// Class (the chosen skill Choice), and Race (any selection whose id
/// happens to match a skill name, e.g. Human's Skillful or Elf's Keen Senses).
Set<String> proficientSkills(Character character) {
  final result = <String>{};

  result.addAll(character.background.skillProficiencies);

  final classSkillChoiceId = '${character.characterClass.id}_skills';
  final classSelected = character.classSelections[classSkillChoiceId] ?? {};
  result.addAll(classSelected.map(normalizeSkillId));
  // Subclass skill picks, e.g. the Battle Master's Student of War.
  for (final e in character.classSelections.entries) {
    if (e.key.endsWith('_extra_skill')) {
      result.addAll(e.value.map(normalizeSkillId));
    }
  }

  for (final selectedIds in character.raceSelections.values) {
    for (final id in selectedIds) {
      final normalized = normalizeSkillId(id);
      if (skillAbilityMap.containsKey(normalized)) {
        result.add(normalized);
      }
    }
  }

  for (final selectedIds in character.backgroundSelections.values) {
    for (final id in selectedIds) {
      final normalized = normalizeSkillId(id);
      if (skillAbilityMap.containsKey(normalized)) {
        result.add(normalized);
      }
    }
  }

  return result;
}
