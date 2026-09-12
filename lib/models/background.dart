import 'ability_scores.dart';
import 'choice.dart';
import 'starting_equipment.dart';

class Background {
  final String id;
  final String name;
  final String description;
  final List<Ability> abilityScoreOptions; // esattamente 3 caratteristiche
  final String originFeatName;
  final String originFeatDescription;
  final List<String> skillProficiencies;
  final String toolProficiency;
  final List<Choice> choices;
  final List<StartingEquipmentOption> startingEquipmentOptions;

  const Background({
    required this.id,
    required this.name,
    required this.description,
    required this.abilityScoreOptions,
    required this.originFeatName,
    required this.originFeatDescription,
    required this.skillProficiencies,
    required this.toolProficiency,
    this.startingEquipmentOptions = const [],
    this.choices = const [],
  });
}
