import 'character.dart';

List<String> effectiveWeaponProficiencies(Character character) {
  final result = <String>{...character.characterClass.weaponProficiencies};
  for (final choice in character.characterClass.levelFeatures.expand(
    (f) => f.choices,
  )) {
    final selectedIds = character.classSelections[choice.id] ?? const {};
    for (final option in choice.options) {
      if (selectedIds.contains(option.id)) {
        result.addAll(option.extraWeaponProficiencies);
      }
    }
  }
  return result.toList();
}

List<String> effectiveArmorProficiencies(Character character) {
  final result = <String>{...character.characterClass.armorProficiencies};
  for (final choice in character.characterClass.levelFeatures.expand(
    (f) => f.choices,
  )) {
    final selectedIds = character.classSelections[choice.id] ?? const {};
    for (final option in choice.options) {
      if (selectedIds.contains(option.id)) {
        result.addAll(option.extraArmorProficiencies);
      }
    }
  }
  return result.toList();
}
