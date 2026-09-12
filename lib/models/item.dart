enum ItemCategory {
  simpleMeleeWeapon,
  simpleRangedWeapon,
  martialMeleeWeapon,
  martialRangedWeapon,
  lightArmor,
  mediumArmor,
  heavyArmor,
  shield,
  adventuringGear,
}

class GameItem {
  final String id;
  final String name;
  final ItemCategory category;
  final int costInCopper;
  final double weightLbs;
  final String? damage;
  final List<String> properties;
  final String? armorClass; // display text, e.g. "11 + Dex modifier"
  final int? baseAC; // structured: armor base AC, or shield's flat bonus
  final int?
  dexCap; // null = unlimited Dex bonus (light); 2 = medium; 0 = heavy (no Dex)
  final bool isShield;
  final int? strengthRequirement;
  final bool stealthDisadvantage;
  final String? ammunitionItemId; // e.g. 'arrow', 'crossbow_bolt'

  const GameItem({
    required this.id,
    required this.name,
    required this.category,
    required this.costInCopper,
    required this.weightLbs,
    this.damage,
    this.properties = const [],
    this.armorClass,
    this.baseAC,
    this.dexCap,
    this.isShield = false,
    this.strengthRequirement,
    this.stealthDisadvantage = false,
    this.ammunitionItemId,
  });

  int get handsRequired {
    if (isShield) return 1;
    final isWeapon =
        category == ItemCategory.simpleMeleeWeapon ||
        category == ItemCategory.simpleRangedWeapon ||
        category == ItemCategory.martialMeleeWeapon ||
        category == ItemCategory.martialRangedWeapon;
    if (isWeapon) {
      final isTwoHanded = properties.any(
        (p) => p.toLowerCase().contains('two-handed'),
      );
      return isTwoHanded ? 2 : 1;
    }
    if (id == 'arcane_focus' || id == 'druidic_focus' || id == 'holy_symbol')
      return 1;
    return 0; // armor and everything else doesn't occupy a hand
  }

  String get costDisplay {
    if (costInCopper % 100 == 0) return '${costInCopper ~/ 100} GP';
    if (costInCopper % 10 == 0) return '${costInCopper ~/ 10} SP';
    return '$costInCopper CP';
  }
}
