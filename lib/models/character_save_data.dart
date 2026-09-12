import 'dart:convert';
import 'ability_scores.dart';
import 'ability_score_improvement.dart';
import 'background_ability_choice.dart';

class CharacterSaveData {
  final String name;
  final int? age;
  final String? height;
  final String? weight;
  final String? imagePath;
  final String raceId;
  final Map<String, List<String>> raceSelections;
  final String classId;
  final int level;
  final Map<String, List<String>> classSelections;
  final List<Map<String, dynamic>> asiChoices; // serialized AsiChoice
  final String backgroundId;
  final Map<String, List<String>> backgroundSelections;
  final String abilityAllocationMode; // AllocationMode.name
  final String? abilityPlusTwo; // Ability.name
  final String? abilityPlusOne; // Ability.name
  final Map<String, int> abilityBaseScores; // Ability.name -> score
  final Map<String, int> hitPointRolls; // level (as string) -> roll

  const CharacterSaveData({
    required this.name,
    this.age,
    this.height,
    this.weight,
    this.imagePath,
    required this.raceId,
    required this.raceSelections,
    required this.classId,
    required this.level,
    required this.classSelections,
    required this.asiChoices,
    required this.backgroundId,
    required this.backgroundSelections,
    required this.abilityAllocationMode,
    this.abilityPlusTwo,
    this.abilityPlusOne,
    required this.abilityBaseScores,
    required this.hitPointRolls,
  });

  CharacterSaveData copyWith({int? level}) {
    return CharacterSaveData(
      name: name,
      age: age,
      height: height,
      weight: weight,
      imagePath: imagePath,
      raceId: raceId,
      raceSelections: raceSelections,
      classId: classId,
      level: level ?? this.level,
      classSelections: classSelections,
      asiChoices: asiChoices,
      backgroundId: backgroundId,
      backgroundSelections: backgroundSelections,
      abilityAllocationMode: abilityAllocationMode,
      abilityPlusTwo: abilityPlusTwo,
      abilityPlusOne: abilityPlusOne,
      abilityBaseScores: abilityBaseScores,
      hitPointRolls: hitPointRolls,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'age': age,
    'height': height,
    'weight': weight,
    'imagePath': imagePath,
    'raceId': raceId,
    'raceSelections': raceSelections,
    'classId': classId,
    'level': level,
    'classSelections': classSelections,
    'asiChoices': asiChoices,
    'backgroundId': backgroundId,
    'backgroundSelections': backgroundSelections,
    'abilityAllocationMode': abilityAllocationMode,
    'abilityPlusTwo': abilityPlusTwo,
    'abilityPlusOne': abilityPlusOne,
    'abilityBaseScores': abilityBaseScores,
    'hitPointRolls': hitPointRolls,
  };

  String toJson() => jsonEncode(toMap());

  static CharacterSaveData fromMap(Map<String, dynamic> map) {
    Map<String, List<String>> parseSelections(dynamic raw) {
      final m = raw as Map<String, dynamic>;
      return m.map((k, v) => MapEntry(k, List<String>.from(v as List)));
    }

    return CharacterSaveData(
      name: map['name'] as String,
      age: map['age'] as int?,
      height: map['height'] as String?,
      weight: map['weight'] as String?,
      imagePath: map['imagePath'] as String?,
      raceId: map['raceId'] as String,
      raceSelections: parseSelections(map['raceSelections']),
      classId: map['classId'] as String,
      level: map['level'] as int,
      classSelections: parseSelections(map['classSelections']),
      asiChoices: List<Map<String, dynamic>>.from(
        (map['asiChoices'] as List).map(
          (e) => Map<String, dynamic>.from(e as Map),
        ),
      ),
      backgroundId: map['backgroundId'] as String,
      backgroundSelections: parseSelections(map['backgroundSelections']),
      abilityAllocationMode: map['abilityAllocationMode'] as String,
      abilityPlusTwo: map['abilityPlusTwo'] as String?,
      abilityPlusOne: map['abilityPlusOne'] as String?,
      abilityBaseScores: Map<String, int>.from(map['abilityBaseScores'] as Map),
      hitPointRolls: Map<String, int>.from(map['hitPointRolls'] as Map),
    );
  }

  static CharacterSaveData fromJson(String json) =>
      fromMap(jsonDecode(json) as Map<String, dynamic>);
}

Map<String, List<String>> selectionsToSerializable(
  Map<String, Set<String>> selections,
) {
  return selections.map((k, v) => MapEntry(k, v.toList()));
}

Map<String, Set<String>> selectionsFromSerializable(
  Map<String, List<String>> raw,
) {
  return raw.map((k, v) => MapEntry(k, v.toSet()));
}

Map<String, dynamic> asiChoiceToMap(AsiChoice a) => {
  'mode': a.mode.name,
  'plusTwo': a.plusTwo?.name,
  'firstPlusOne': a.firstPlusOne?.name,
  'secondPlusOne': a.secondPlusOne?.name,
};

AsiChoice asiChoiceFromMap(Map<String, dynamic> m) {
  Ability? parseAbility(String? s) =>
      s == null ? null : Ability.values.byName(s);
  return AsiChoice(
    mode: AsiAllocationMode.values.byName(m['mode'] as String),
    plusTwo: parseAbility(m['plusTwo'] as String?),
    firstPlusOne: parseAbility(m['firstPlusOne'] as String?),
    secondPlusOne: parseAbility(m['secondPlusOne'] as String?),
  );
}
