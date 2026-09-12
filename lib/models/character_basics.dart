class CharacterBasics {
  final String name;
  final int? age;
  final String? height;
  final String? weight;
  final String? imagePath; // placeholder for the future profile picture upload

  const CharacterBasics({
    this.name = '',
    this.age,
    this.height,
    this.weight,
    this.imagePath,
  });

  CharacterBasics copyWith({
    String? name,
    int? age,
    String? height,
    String? weight,
    String? imagePath,
  }) {
    return CharacterBasics(
      name: name ?? this.name,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  bool get isComplete => name.trim().isNotEmpty;
}
