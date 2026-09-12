class Enemy {
  final String id; // local, generated at creation time
  final String name;
  final int maxHp;
  final int currentHp;
  final int armorClass;
  final int speed;
  final List<String> conditions; // e.g. "Prone", "Slowed", "Poisoned"
  final bool hasAdvantageOnNextAttack; // e.g. from Sap against the player

  const Enemy({
    required this.id,
    required this.name,
    required this.maxHp,
    required this.currentHp,
    this.armorClass = 10,
    this.speed = 30,
    this.conditions = const [],
    this.hasAdvantageOnNextAttack = false,
  });

  Enemy copyWith({
    String? name,
    int? maxHp,
    int? currentHp,
    int? armorClass,
    int? speed,
    List<String>? conditions,
    bool? hasAdvantageOnNextAttack,
  }) {
    return Enemy(
      id: id,
      name: name ?? this.name,
      maxHp: maxHp ?? this.maxHp,
      currentHp: currentHp ?? this.currentHp,
      armorClass: armorClass ?? this.armorClass,
      speed: speed ?? this.speed,
      conditions: conditions ?? this.conditions,
      hasAdvantageOnNextAttack:
          hasAdvantageOnNextAttack ?? this.hasAdvantageOnNextAttack,
    );
  }
}
