import 'level_feature.dart';

class ChoiceOption {
  final String id;
  final String label;
  final String? description;
  final List<Choice> unlockedChoices;
  final Map<int, LevelFeature> levelFeatures;
  final Map<String, int> extraSelectionsForChoice;
  final List<String> extraWeaponProficiencies;
  final List<String> extraArmorProficiencies;

  const ChoiceOption({
    required this.id,
    required this.label,
    this.description,
    this.unlockedChoices = const [],
    this.levelFeatures = const {},
    this.extraSelectionsForChoice = const {},
    this.extraWeaponProficiencies = const [],
    this.extraArmorProficiencies = const [],
  });
}

class Choice {
  final String id;
  final String title;
  final int minSelections;
  final int maxSelections;
  final List<ChoiceOption> options;

  const Choice({
    required this.id,
    required this.title,
    required this.options,
    this.minSelections = 1,
    this.maxSelections = 1,
  });

  bool get isSingleSelect => maxSelections == 1;

  Choice copyWith({int? minSelections, int? maxSelections, String? title}) {
    return Choice(
      id: id,
      title: title ?? this.title,
      options: options,
      minSelections: minSelections ?? this.minSelections,
      maxSelections: maxSelections ?? this.maxSelections,
    );
  }
}
