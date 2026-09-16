/// Rage Damage bonus scales with Barbarian level: +2 (1-8), +3 (9-15), +4 (16-20).
int rageDamageBonus(int barbarianLevel) {
  if (barbarianLevel >= 16) return 4;
  if (barbarianLevel >= 9) return 3;
  return 2;
}

/// Relentless Rage: DC starts at 10, +5 each additional use since the last rest.
int relentlessRageDc(int usesSinceRest) => 10 + (usesSinceRest * 5);

/// Frenzy (Berserker): extra d6s equal to Rage Damage bonus, once per turn on Reckless Attack hit.
String frenzyExtraDice(int barbarianLevel) =>
    '${rageDamageBonus(barbarianLevel)}d6';

/// Divine Fury (Zealot): 1d6 + half Barbarian level (rounded down).
String divineFuryExtraDice() => '1d6';
int divineFuryFlatBonus(int barbarianLevel) => barbarianLevel ~/ 2;

/// Warrior of the Gods (Zealot): d12 healing pool size scales with level.
int warriorOfTheGodsPoolSize(int barbarianLevel) {
  if (barbarianLevel >= 17) return 7;
  if (barbarianLevel >= 12) return 6;
  if (barbarianLevel >= 6) return 5;
  return 4;
}

/// Life-Giving Force (World Tree): d6s equal to Rage Damage bonus.
String lifeGivingForceDice(int barbarianLevel) =>
    '${rageDamageBonus(barbarianLevel)}d6';
