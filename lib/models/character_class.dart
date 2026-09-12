import 'choice.dart';
import 'level_feature.dart';
import 'starting_equipment.dart';

class CharacterClass {
  final String id;
  final String name;
  final int hitDie;
  final List<String> savingThrows;
  final List<String> armorProficiencies;
  final List<String> weaponProficiencies;
  final int skillChoiceCount;
  final List<String> skillOptions;
  final bool isSpellcaster;
  final String? spellcastingAbility;
  final List<LevelFeature> levelFeatures;
  final List<StartingEquipmentOption> startingEquipmentOptions;

  const CharacterClass({
    required this.id,
    required this.name,
    required this.hitDie,
    required this.savingThrows,
    required this.armorProficiencies,
    required this.weaponProficiencies,
    required this.skillChoiceCount,
    required this.skillOptions,
    required this.levelFeatures,
    this.isSpellcaster = false,
    this.spellcastingAbility,
    this.startingEquipmentOptions = const [],
  });

  LevelFeature featureAt(int level) {
    return levelFeatures.firstWhere(
      (f) => f.level == level,
      orElse: () => LevelFeature(level: level),
    );
  }

  List<String> cumulativeFixedTraits(int uptoLevel) {
    return levelFeatures
        .where((f) => f.level <= uptoLevel)
        .expand((f) => f.fixedTraits)
        .toList();
  }

  int get maxDefinedLevel =>
      levelFeatures.map((f) => f.level).reduce((a, b) => a > b ? a : b);

  List<String> get level1FixedTraits => featureAt(1).fixedTraits;
  List<Choice> get level1Choices => featureAt(1).choices;
}
