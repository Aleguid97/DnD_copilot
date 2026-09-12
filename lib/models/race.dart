import 'choice.dart';
import 'level_feature.dart';

class Race {
  final String id;
  final String name;
  final int speed;
  final String description;
  final List<String> fixedTraits; // always-active traits, from level 1
  final List<Choice> choices; // creation-time choices (lineage, skills, etc.)
  final List<LevelFeature>
  levelFeatures; // ADDITIONAL fixed traits gained at higher levels (no choices — always resolved at summary time)
  final int hpBonusPerLevel; // e.g. Dwarven Toughness: +1 per character level

  const Race({
    required this.id,
    required this.name,
    required this.speed,
    required this.description,
    this.fixedTraits = const [],
    this.choices = const [],
    this.levelFeatures = const [],
    this.hpBonusPerLevel = 0,
  });

  /// Extra fixed traits gained beyond level 1, up to [uptoLevel].
  List<String> additionalFixedTraits(int uptoLevel) {
    return levelFeatures
        .where((f) => f.level <= uptoLevel)
        .expand((f) => f.fixedTraits)
        .toList();
  }
}
