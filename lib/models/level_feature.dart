import 'choice.dart';

class LevelFeature {
  final int level;
  final List<String> fixedTraits;
  final List<Choice> choices;
  final bool grantsAbilityScoreImprovement;

  const LevelFeature({
    required this.level,
    this.fixedTraits = const [],
    this.choices = const [],
    this.grantsAbilityScoreImprovement = false,
  });
}
