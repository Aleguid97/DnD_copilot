import '../models/ability_scores.dart';

const Map<String, Ability> skillAbilityMap = {
  'Acrobatics': Ability.dexterity,
  'Animal Handling': Ability.wisdom,
  'Arcana': Ability.intelligence,
  'Athletics': Ability.strength,
  'Deception': Ability.charisma,
  'History': Ability.intelligence,
  'Insight': Ability.wisdom,
  'Intimidation': Ability.charisma,
  'Investigation': Ability.intelligence,
  'Medicine': Ability.wisdom,
  'Nature': Ability.intelligence,
  'Perception': Ability.wisdom,
  'Performance': Ability.charisma,
  'Persuasion': Ability.charisma,
  'Religion': Ability.intelligence,
  'Sleight of Hand': Ability.dexterity,
  'Stealth': Ability.dexterity,
  'Survival': Ability.wisdom,
};

List<String> get allSkillNames => skillAbilityMap.keys.toList();

/// Some Choice ids (e.g. race-granted skills) use snake_case ids like
/// 'sleight_of_hand' instead of the display label 'Sleight of Hand'.
/// This normalizes any variant back to the canonical skill name.
String normalizeSkillId(String raw) {
  final cleaned = raw.replaceAll('_', ' ').trim();
  for (final name in allSkillNames) {
    if (name.toLowerCase() == cleaned.toLowerCase()) return name;
  }
  return cleaned;
}
