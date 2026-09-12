enum Ability { strength, dexterity, constitution, intelligence, wisdom, charisma }

/// Rappresenta il costo in punti "point buy" per ogni punteggio da 8 a 15.
const Map<int, int> pointBuyCost = {
  8: 0,
  9: 1,
  10: 2,
  11: 3,
  12: 4,
  13: 5,
  14: 7,
  15: 9,
};

const int pointBuyBudget = 27;
const int pointBuyMin = 8;
const int pointBuyMax = 15;

/// Contiene i punteggi "grezzi" scelti tramite point buy (senza bonus di background).
class AbilityScores {
  final Map<Ability, int> baseScores;

  AbilityScores({Map<Ability, int>? baseScores})
      : baseScores = baseScores ??
            {
              for (final a in Ability.values) a: pointBuyMin,
            };

  /// Punti spesi finora nel point buy.
  int get pointsSpent =>
      baseScores.values.fold(0, (sum, score) => sum + (pointBuyCost[score] ?? 0));

  /// Punti ancora disponibili.
  int get pointsRemaining => pointBuyBudget - pointsSpent;

  /// Verifica se si può aumentare un punteggio di 1.
  bool canIncrease(Ability ability) {
    final current = baseScores[ability]!;
    if (current >= pointBuyMax) return false;
    final nextCost = pointBuyCost[current + 1]!;
    final currentCost = pointBuyCost[current]!;
    return pointsRemaining >= (nextCost - currentCost);
  }

  /// Verifica se si può diminuire un punteggio di 1.
  bool canDecrease(Ability ability) {
    return baseScores[ability]! > pointBuyMin;
  }

  /// Restituisce una nuova istanza con il punteggio aumentato di 1.
  AbilityScores increase(Ability ability) {
    if (!canIncrease(ability)) return this;
    final updated = Map<Ability, int>.from(baseScores);
    updated[ability] = updated[ability]! + 1;
    return AbilityScores(baseScores: updated);
  }

  /// Restituisce una nuova istanza con il punteggio diminuito di 1.
  AbilityScores decrease(Ability ability) {
    if (!canDecrease(ability)) return this;
    final updated = Map<Ability, int>.from(baseScores);
    updated[ability] = updated[ability]! - 1;
    return AbilityScores(baseScores: updated);
  }

  /// Calcola il modificatore D&D standard: (punteggio - 10) / 2 arrotondato per difetto.
  int modifierFor(Ability ability, {Map<Ability, int> bonuses = const {}}) {
    final total = baseScores[ability]! + (bonuses[ability] ?? 0);
    return ((total - 10) / 2).floor();
  }

  bool get isComplete => pointsRemaining == 0;
}