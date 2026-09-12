import 'ability_score_improvement.dart';
import 'ability_scores.dart';
import 'background_ability_choice.dart';
import 'character.dart';
import 'character_basics.dart';
import 'character_save_data.dart';
import 'hit_points.dart';
import '../data/races_data.dart';
import '../data/classes_data.dart';
import '../data/backgrounds_data.dart';

Character characterFromSaveData(CharacterSaveData data, {int? id}) {
  final race = allRaces.firstWhere((r) => r.id == data.raceId);
  final characterClass = allClasses.firstWhere((c) => c.id == data.classId);
  final background = allBackgrounds.firstWhere(
    (b) => b.id == data.backgroundId,
  );

  final basics = CharacterBasics(
    name: data.name,
    age: data.age,
    height: data.height,
    weight: data.weight,
    imagePath: data.imagePath,
  );

  final abilityScores = AbilityScores(
    baseScores: data.abilityBaseScores.map(
      (k, v) => MapEntry(Ability.values.byName(k), v),
    ),
  );

  final backgroundAbilityChoice = BackgroundAbilityChoice(
    mode: AllocationMode.values.byName(data.abilityAllocationMode),
    plusTwo: data.abilityPlusTwo != null
        ? Ability.values.byName(data.abilityPlusTwo!)
        : null,
    plusOne: data.abilityPlusOne != null
        ? Ability.values.byName(data.abilityPlusOne!)
        : null,
  );

  final asiChoices = data.asiChoices.map(asiChoiceFromMap).toList();

  final hitPoints = HitPointsState(
    rolls: data.hitPointRolls.map((k, v) => MapEntry(int.parse(k), v)),
  );

  return Character(
    id: id,
    basics: basics,
    race: race,
    raceSelections: selectionsFromSerializable(data.raceSelections),
    characterClass: characterClass,
    level: data.level,
    classSelections: selectionsFromSerializable(data.classSelections),
    asiChoices: asiChoices,
    background: background,
    backgroundAbilityChoice: backgroundAbilityChoice,
    backgroundSelections: selectionsFromSerializable(data.backgroundSelections),
    abilityScores: abilityScores,
    hitPoints: hitPoints,
  );
}
