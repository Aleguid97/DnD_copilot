import '../data/items_data.dart';
import 'ability_scores.dart';
import 'character.dart';
import 'item.dart';
import 'character_proficiency_lists.dart';

class ArmorClassResult {
  final int value;
  final String explanation;

  const ArmorClassResult({required this.value, required this.explanation});
}

class WeaponAttackInfo {
  final int attackBonus;
  final int damageModifier;
  final String damageDice; // e.g. "1d8"
  final String damageType; // e.g. "Slashing"

  const WeaponAttackInfo({
    required this.attackBonus,
    required this.damageModifier,
    required this.damageDice,
    required this.damageType,
  });
}

class CombatStats {
  final Character character;
  final List<GameItem> equippedItems;
  bool get hasDangerSense =>
      character.characterClass.id == 'barbarian' && character.level >= 2;
  bool get hasFeralInstinct =>
      character.characterClass.id == 'barbarian' && character.level >= 7;

  const CombatStats({required this.character, required this.equippedItems});

  int get dexModifier => character.abilityScores.modifierFor(
    Ability.dexterity,
    bonuses: character.totalAbilityBonuses,
  );

  GameItem? get _equippedArmor => equippedItems
      .where(
        (i) =>
            i.category == ItemCategory.lightArmor ||
            i.category == ItemCategory.mediumArmor ||
            i.category == ItemCategory.heavyArmor,
      )
      .firstOrNull;

  bool get _hasShield => equippedItems.any((i) => i.isShield);

  bool get _hasFightingStyleDefense {
    final selections = character.classSelections['fighter_fighting_style'];
    return selections?.contains('defense') ?? false;
  }

  String? get _selectedFightingStyle {
    final selections = character.classSelections['fighter_fighting_style'];
    if (selections == null || selections.isEmpty) return null;
    return selections.first;
  }

  ArmorClassResult get armorClass {
    final armor = _equippedArmor;
    final classId = character.characterClass.id;
    final parts = <String>[];
    int total;

    if (armor != null) {
      final cap = armor.dexCap;
      final dexBonus = cap == null
          ? dexModifier
          : (dexModifier > cap ? cap : dexModifier).clamp(
              cap == 0 ? 0 : -20,
              cap ?? 20,
            );
      total = armor.baseAC! + (cap == 0 ? 0 : dexBonus);
      parts.add('${armor.name} (${armor.baseAC})');
      if (cap != 0) {
        parts.add('Dex mod ($dexBonus${cap != null ? ", max $cap" : ""})');
      }
    } else if (classId == 'barbarian' || classId == 'monk') {
      final secondaryAbility = classId == 'barbarian'
          ? Ability.constitution
          : Ability.wisdom;
      final secondaryMod = character.abilityScores.modifierFor(
        secondaryAbility,
        bonuses: character.totalAbilityBonuses,
      );
      total = 10 + dexModifier + secondaryMod;
      final secondaryName = classId == 'barbarian' ? 'CON' : 'WIS';
      parts.add(
        '10 + Dex mod ($dexModifier) + $secondaryName mod ($secondaryMod) — Unarmored Defense',
      );
    } else {
      total = 10 + dexModifier;
      parts.add('10 + Dex mod ($dexModifier) — unarmored');
    }

    if (_hasShield) {
      total += 2;
      parts.add('Shield (+2)');
    }

    if (_hasFightingStyleDefense && armor != null) {
      total += 1;
      parts.add('Defense fighting style (+1)');
    }

    return ArmorClassResult(value: total, explanation: parts.join(' + '));
  }

  int get initiative => dexModifier;

  int totalInitiative(int proficiencyBonus) {
    final alertBonus = character.background.originFeatName == 'Alert'
        ? proficiencyBonus
        : 0;
    return dexModifier + alertBonus;
  }

  Map<Ability, int> savingThrowBonuses(int proficiencyBonus) {
    final result = <Ability, int>{};
    for (final a in Ability.values) {
      final abilityName = _abilityFullName(a);
      final isProficient = character.characterClass.savingThrows.contains(
        abilityName,
      );
      final mod = character.abilityScores.modifierFor(
        a,
        bonuses: character.totalAbilityBonuses,
      );
      result[a] = mod + (isProficient ? proficiencyBonus : 0);
    }
    return result;
  }

  bool _isProficientWith(GameItem weapon) {
    final profs = effectiveWeaponProficiencies(character).join(' ');
    final isSimple =
        weapon.category == ItemCategory.simpleMeleeWeapon ||
        weapon.category == ItemCategory.simpleRangedWeapon;
    final isMartial =
        weapon.category == ItemCategory.martialMeleeWeapon ||
        weapon.category == ItemCategory.martialRangedWeapon;
    if (isSimple && profs.contains('Simple')) return true;
    if (isMartial && profs.contains('Martial')) return true;
    return false;
  }

  WeaponAttackInfo weaponAttackInfo(GameItem weapon, int proficiencyBonus) {
    final isFinesse = weapon.properties.any(
      (p) => p.toLowerCase().contains('finesse'),
    );
    final isRanged =
        weapon.category == ItemCategory.simpleRangedWeapon ||
        weapon.category == ItemCategory.martialRangedWeapon;
    final isTwoHanded = weapon.properties.any(
      (p) => p.toLowerCase().contains('two-handed'),
    );

    final strMod = character.abilityScores.modifierFor(
      Ability.strength,
      bonuses: character.totalAbilityBonuses,
    );
    final dexMod = character.abilityScores.modifierFor(
      Ability.dexterity,
      bonuses: character.totalAbilityBonuses,
    );

    final abilityMod = isFinesse
        ? (strMod > dexMod ? strMod : dexMod)
        : (isRanged ? dexMod : strMod);

    final proficient = _isProficientWith(weapon);
    var attackBonus = abilityMod + (proficient ? proficiencyBonus : 0);
    var damageModifier = abilityMod;

    final style = _selectedFightingStyle;
    if (style == 'archery' && isRanged) {
      attackBonus += 2;
    } else if (style == 'dueling' && !isRanged && !isTwoHanded) {
      final equippedWeaponCount = equippedItems
          .where(
            (i) =>
                i.category == ItemCategory.simpleMeleeWeapon ||
                i.category == ItemCategory.simpleRangedWeapon ||
                i.category == ItemCategory.martialMeleeWeapon ||
                i.category == ItemCategory.martialRangedWeapon,
          )
          .length;
      if (equippedWeaponCount == 1) {
        damageModifier += 2;
      }
    }

    final damageParts = (weapon.damage ?? '0 Bludgeoning').split(' ');
    final dice = damageParts.isNotEmpty ? damageParts[0] : '0';
    final type = damageParts.length > 1 ? damageParts.sublist(1).join(' ') : '';

    return WeaponAttackInfo(
      attackBonus: attackBonus,
      damageModifier: damageModifier,
      damageDice: dice,
      damageType: type,
    );
  }

  bool weaponUsesGreatWeaponFighting(GameItem weapon) {
    final isTwoHanded = weapon.properties.any(
      (p) => p.toLowerCase().contains('two-handed'),
    );
    return _selectedFightingStyle == 'great_weapon_fighting' && isTwoHanded;
  }

  bool get _hasUnarmedFightingStyle =>
      _selectedFightingStyle == 'unarmed_fighting';
  bool get _hasTwoWeaponFightingStyle =>
      _selectedFightingStyle == 'two_weapon_fighting';

  bool get _hasWeaponOrShieldEquipped {
    final hasWeapon = equippedItems.any(
      (i) =>
          i.category == ItemCategory.simpleMeleeWeapon ||
          i.category == ItemCategory.simpleRangedWeapon ||
          i.category == ItemCategory.martialMeleeWeapon ||
          i.category == ItemCategory.martialRangedWeapon,
    );
    return hasWeapon || _hasShield;
  }

  /// Unarmed Strike is always available, regardless of equipped items.
  WeaponAttackInfo unarmedStrikeInfo(int proficiencyBonus) {
    final strMod = character.abilityScores.modifierFor(
      Ability.strength,
      bonuses: character.totalAbilityBonuses,
    );
    // Everyone is proficient with their own Unarmed Strikes.
    final attackBonus = strMod + proficiencyBonus;

    String dice;
    if (!_hasUnarmedFightingStyle) {
      dice = '1d1'; // flat 1 damage before modifier (no Unarmed Fighting style)
    } else if (!_hasWeaponOrShieldEquipped) {
      dice = '1d6'; // Unarmed Fighting, both hands free
    } else {
      dice = '1d4'; // Unarmed Fighting, holding a weapon or shield
    }

    return WeaponAttackInfo(
      attackBonus: attackBonus,
      damageModifier: strMod,
      damageDice: dice,
      damageType: 'Bludgeoning',
    );
  }

  List<GameItem> get _equippedLightMeleeWeapons => equippedItems
      .where(
        (i) =>
            (i.category == ItemCategory.simpleMeleeWeapon ||
                i.category == ItemCategory.martialMeleeWeapon) &&
            i.properties.any((p) => p.toLowerCase().contains('light')),
      )
      .toList();

  /// The off-hand weapon for a Two-Weapon Fighting attack, if the character
  /// has two Light melee weapons equipped. Returns null otherwise.
  GameItem? get offHandWeapon {
    final lightWeapons = _equippedLightMeleeWeapons;
    return lightWeapons.length >= 2 ? lightWeapons[1] : null;
  }

  WeaponAttackInfo? offHandAttackInfo(int proficiencyBonus) {
    final weapon = offHandWeapon;
    if (weapon == null) return null;

    final strMod = character.abilityScores.modifierFor(
      Ability.strength,
      bonuses: character.totalAbilityBonuses,
    );
    final dexMod = character.abilityScores.modifierFor(
      Ability.dexterity,
      bonuses: character.totalAbilityBonuses,
    );
    final isFinesse = weapon.properties.any(
      (p) => p.toLowerCase().contains('finesse'),
    );
    final abilityMod = isFinesse ? (strMod > dexMod ? strMod : dexMod) : strMod;

    final proficient = _isProficientWith(weapon);
    final attackBonus = abilityMod + (proficient ? proficiencyBonus : 0);
    // Without the Two-Weapon Fighting style, the off-hand attack deals no
    // ability modifier to damage at all — only with the style is it added.
    final damageModifier = _hasTwoWeaponFightingStyle ? abilityMod : 0;

    final damageParts = (weapon.damage ?? '0 Bludgeoning').split(' ');
    final dice = damageParts.isNotEmpty ? damageParts[0] : '0';
    final type = damageParts.length > 1 ? damageParts.sublist(1).join(' ') : '';

    return WeaponAttackInfo(
      attackBonus: attackBonus,
      damageModifier: damageModifier,
      damageDice: dice,
      damageType: type,
    );
  }

  String _abilityFullName(Ability a) {
    switch (a) {
      case Ability.strength:
        return 'Strength';
      case Ability.dexterity:
        return 'Dexterity';
      case Ability.constitution:
        return 'Constitution';
      case Ability.intelligence:
        return 'Intelligence';
      case Ability.wisdom:
        return 'Wisdom';
      case Ability.charisma:
        return 'Charisma';
    }
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
