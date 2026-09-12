class CurrencyDisplay {
  final int gold;
  final int silver;
  final int copper;

  const CurrencyDisplay({
    required this.gold,
    required this.silver,
    required this.copper,
  });

  static CurrencyDisplay fromCopper(int totalCopper) {
    final gold = totalCopper ~/ 100;
    final remainder = totalCopper % 100;
    final silver = remainder ~/ 10;
    final copper = remainder % 10;
    return CurrencyDisplay(gold: gold, silver: silver, copper: copper);
  }

  @override
  String toString() {
    final parts = <String>[];
    if (gold > 0) parts.add('$gold GP');
    if (silver > 0) parts.add('$silver SP');
    if (copper > 0 || parts.isEmpty) parts.add('$copper CP');
    return parts.join(', ');
  }
}
