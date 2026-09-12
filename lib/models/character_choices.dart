import 'character.dart';
import 'choice.dart';
import 'choice_utils.dart';

List<Choice> allActiveChoicesForCharacter(Character character) {
  final raceChoices = flattenChoicesWithUnlocked(
    character.race.choices,
    character.raceSelections,
  );

  final classBase = character.characterClass.levelFeatures
      .where((f) => f.level <= character.level)
      .expand((f) => f.choices)
      .toList();
  final classBaseFlattened = flattenChoicesWithUnlocked(
    classBase,
    character.classSelections,
  );

  final classSubclass = <Choice>[];
  for (final choice in classBase) {
    final selectedIds = character.classSelections[choice.id] ?? const {};
    for (final option in choice.options) {
      if (!selectedIds.contains(option.id)) continue;
      option.levelFeatures.forEach((level, feature) {
        if (level <= character.level) {
          classSubclass.addAll(
            flattenChoicesWithUnlocked(
              feature.choices,
              character.classSelections,
            ),
          );
        }
      });
    }
  }

  final backgroundChoices = flattenChoicesWithUnlocked(
    character.background.choices,
    character.backgroundSelections,
  );

  return [
    ...raceChoices,
    ...classBaseFlattened,
    ...classSubclass,
    ...backgroundChoices,
  ];
}
