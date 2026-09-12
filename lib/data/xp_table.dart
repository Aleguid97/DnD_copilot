const Map<int, int> xpThresholds = {
  1: 0,
  2: 300,
  3: 900,
  4: 2700,
  5: 6500,
  6: 14000,
  7: 23000,
  8: 34000,
  9: 48000,
  10: 64000,
  11: 85000,
  12: 100000,
  13: 120000,
  14: 140000,
  15: 165000,
  16: 195000,
  17: 225000,
  18: 265000,
  19: 305000,
  20: 355000,
};

/// Given a total XP amount, returns the corresponding character level (1-20).
int levelForXp(int xp) {
  int level = 1;
  for (final entry in xpThresholds.entries) {
    if (xp >= entry.value) level = entry.key;
  }
  return level;
}

/// Standard Proficiency Bonus for a given character level.
int proficiencyBonusForLevel(int level) {
  return 2 + ((level - 1) ~/ 4);
}
