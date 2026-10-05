/// How a spell resolves in combat.
enum SpellEffectKind {
  /// Spell attack roll against the target's AC.
  attack,

  /// Targets make a saving throw against the spell save DC.
  save,

  /// Damage with no roll to hit or save (Heat Metal, Spike Growth, extra
  /// damage riders like Fount of Moonlight).
  automatic,

  /// Restores Hit Points.
  heal,
}

/// Mechanical data for one spell, taken from chapter 7 of the 2024 PHB.
/// Dice scale with the slot ([upcastDice] per level above [upcastAbove]) or,
/// for cantrips, by one die at character levels 5, 11 and 17.
class SpellEffect {
  final SpellEffectKind kind;

  /// Base dice, e.g. '2d8'. Null for condition-only spells.
  final String? dice;
  final String? damageType;

  /// Adds the spellcasting ability modifier to damage or healing.
  final bool addModifier;

  /// Saving throw ability, e.g. 'Dexterity'.
  final String? saveAbility;

  /// Successful save halves the damage (otherwise it negates it).
  final bool halfOnSave;
  final String? upcastDice;

  /// Slot level the upcast bonus counts from (defaults to the spell level).
  final int? upcastAbove;
  final bool cantripScaling;

  /// Flat amount (Heal 70, Regenerate +15) and its per-slot increase.
  final int flat;
  final int upcastFlat;

  /// Condition applied on a failed save or a hit.
  final String? condition;

  /// Can affect several creatures (area or multiple targets).
  final bool multiTarget;

  /// The effect can be triggered again while the spell lasts
  /// (Moonbeam, Flaming Sphere, Call Lightning...).
  final bool repeatable;

  /// Second damage type rolled together with the first (Ice Storm,
  /// Flame Strike), with its own per-slot increase.
  final String? extraDice;
  final String? extraDamageType;
  final String? extraUpcastDice;

  /// Dice used instead when the target is missing Hit Points (Toll the Dead).
  final String? woundedDice;

  /// Melee spell attack (otherwise ranged).
  final bool melee;

  /// Follow-up effect resolved after this one (Ice Knife's explosion).
  final SpellEffect? secondary;

  /// Short reminder of what the dice don't capture.
  final String note;

  const SpellEffect({
    required this.kind,
    this.dice,
    this.damageType,
    this.addModifier = false,
    this.saveAbility,
    this.halfOnSave = true,
    this.upcastDice,
    this.upcastAbove,
    this.cantripScaling = false,
    this.flat = 0,
    this.upcastFlat = 0,
    this.condition,
    this.multiTarget = false,
    this.repeatable = false,
    this.extraDice,
    this.extraDamageType,
    this.extraUpcastDice,
    this.woundedDice,
    this.melee = false,
    this.secondary,
    this.note = '',
  });

  bool get dealsDamage =>
      kind != SpellEffectKind.heal && (dice != null || flat > 0);

  /// Copy used to scale an alternative set of dice with the same rules.
  SpellEffect withDice(String? newDice, {String? newUpcast}) => SpellEffect(
    kind: kind,
    dice: newDice,
    upcastDice: newUpcast ?? upcastDice,
    upcastAbove: upcastAbove,
    cantripScaling: cantripScaling,
  );
}

/// Cantrip damage dice gain one die at levels 5, 11 and 17.
int cantripTier(int characterLevel) {
  if (characterLevel >= 17) return 3;
  if (characterLevel >= 11) return 2;
  if (characterLevel >= 5) return 1;
  return 0;
}

(int, int)? _parseDice(String? text) {
  final m = RegExp(r'(\d+)d(\d+)').firstMatch(text ?? '');
  if (m == null) return null;
  return (int.parse(m.group(1)!), int.parse(m.group(2)!));
}

/// The dice to roll for [effect] cast at [slotLevel] (0 for cantrips) by a
/// character of [characterLevel], e.g. '3d8'. Null if the effect has none.
String? scaledDice(
  SpellEffect effect, {
  required int spellLevel,
  required int slotLevel,
  required int characterLevel,
}) {
  final base = _parseDice(effect.dice);
  if (base == null) return null;
  var (count, sides) = base;
  if (effect.cantripScaling) count += cantripTier(characterLevel);
  final upcast = _parseDice(effect.upcastDice);
  final above = effect.upcastAbove ?? spellLevel;
  if (upcast != null && slotLevel > above) {
    count += upcast.$1 * (slotLevel - above);
  }
  return '${count}d$sides';
}

/// Flat healing/damage at [slotLevel] (Heal: 70 + 10 per level above 6).
int scaledFlat(
  SpellEffect effect, {
  required int spellLevel,
  required int slotLevel,
}) {
  final above = effect.upcastAbove ?? spellLevel;
  return effect.flat +
      (slotLevel > above ? effect.upcastFlat * (slotLevel - above) : 0);
}
