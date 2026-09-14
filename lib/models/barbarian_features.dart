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
