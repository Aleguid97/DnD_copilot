import 'dart:math';

class DiceRollResult {
  final List<int> rolls;
  final int modifier;
  final int total;
  final String formula;

  const DiceRollResult({
    required this.rolls,
    required this.modifier,
    required this.total,
    required this.formula,
  });
}

final Random _random = Random();

/// Parses a string like "1d8 Slashing" or "2d6" and rolls it, adding [modifier].
/// If [isCritical] is true, the number of dice is doubled (2024 critical hit rule),
/// while the modifier is still added only once.
DiceRollResult rollDamage(
  String damageText,
  int modifier, {
  bool isCritical = false,
}) {
  final match = RegExp(r'(\d+)d(\d+)').firstMatch(damageText);
  if (match == null) {
    return DiceRollResult(
      rolls: const [],
      modifier: modifier,
      total: modifier,
      formula: '$modifier',
    );
  }
  final baseCount = int.parse(match.group(1)!);
  final sides = int.parse(match.group(2)!);
  final count = isCritical ? baseCount * 2 : baseCount;
  final rolls = List.generate(count, (_) => 1 + _random.nextInt(sides));
  final total = rolls.fold(0, (a, b) => a + b) + modifier;
  final modText = modifier >= 0 ? '+$modifier' : '$modifier';
  final critLabel = isCritical ? ' (CRITICAL x2 dice)' : '';
  return DiceRollResult(
    rolls: rolls,
    modifier: modifier,
    total: total,
    formula: '${count}d$sides $modText$critLabel',
  );
}

/// Same as [rollDamage], but any individual die result of 1 or [rerollThreshold]
/// or lower is rerolled once and the new result kept (Great Weapon Fighting).
DiceRollResult rollDamageWithReroll(
  String damageText,
  int modifier, {
  int rerollThreshold = 2,
  bool isCritical = false,
}) {
  final match = RegExp(r'(\d+)d(\d+)').firstMatch(damageText);
  if (match == null) {
    return DiceRollResult(
      rolls: const [],
      modifier: modifier,
      total: modifier,
      formula: '$modifier',
    );
  }
  final baseCount = int.parse(match.group(1)!);
  final sides = int.parse(match.group(2)!);
  final count = isCritical ? baseCount * 2 : baseCount;
  final rolls = List.generate(count, (_) {
    var roll = 1 + _random.nextInt(sides);
    if (roll <= rerollThreshold) {
      roll = 1 + _random.nextInt(sides);
    }
    return roll;
  });
  final total = rolls.fold(0, (a, b) => a + b) + modifier;
  final modText = modifier >= 0 ? '+$modifier' : '$modifier';
  final critLabel = isCritical ? ' (CRITICAL x2 dice)' : '';
  return DiceRollResult(
    rolls: rolls,
    modifier: modifier,
    total: total,
    formula: '${count}d$sides $modText$critLabel',
  );
}

/// Rolls a d20 and adds [modifier].
DiceRollResult rollAttack(int modifier) {
  final roll = 1 + _random.nextInt(20);
  final modText = modifier >= 0 ? '+$modifier' : '$modifier';
  return DiceRollResult(
    rolls: [roll],
    modifier: modifier,
    total: roll + modifier,
    formula: 'd20 $modText',
  );
}
