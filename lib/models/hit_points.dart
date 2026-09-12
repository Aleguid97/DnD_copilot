class HitPointsState {
  final Map<int, int> rolls; // level (2+) -> raw die roll result

  const HitPointsState({this.rolls = const {}});

  HitPointsState copyWith({Map<int, int>? rolls}) {
    return HitPointsState(rolls: rolls ?? this.rolls);
  }

  bool isCompleteFor(int targetLevel) {
    for (int lvl = 2; lvl <= targetLevel; lvl++) {
      if (!rolls.containsKey(lvl)) return false;
    }
    return true;
  }

  int totalHitPoints({
    required int hitDie,
    required int targetLevel,
    required int conModifier,
  }) {
    int total =
        hitDie + conModifier; // level 1 always gets max Hit Die + CON mod
    for (int lvl = 2; lvl <= targetLevel; lvl++) {
      final roll = rolls[lvl] ?? 0;
      final gain = (roll + conModifier) < 1 ? 1 : (roll + conModifier);
      total += gain;
    }
    return total;
  }
}
