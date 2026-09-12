class RacialCantripSwapInfo {
  final String defaultCantripId;
  final String defaultCantripLabel;
  final Map<String, String> availableCantrips; // id -> label

  const RacialCantripSwapInfo({
    required this.defaultCantripId,
    required this.defaultCantripLabel,
    required this.availableCantrips,
  });
}

/// Keyed by "raceId:lineageOptionId" (the elf_lineage choice option selected).
const Map<String, RacialCantripSwapInfo> racialCantripSwaps = {
  'elf:high_elf': RacialCantripSwapInfo(
    defaultCantripId: 'prestidigitation',
    defaultCantripLabel: 'Prestidigitation',
    availableCantrips: {
      'prestidigitation': 'Prestidigitation',
      'fire_bolt': 'Fire Bolt',
      'mage_hand': 'Mage Hand',
      'minor_illusion': 'Minor Illusion',
      'light': 'Light',
      'ray_of_frost': 'Ray of Frost',
    },
  ),
  'elf:wood_elf': RacialCantripSwapInfo(
    defaultCantripId: 'druidcraft',
    defaultCantripLabel: 'Druidcraft',
    availableCantrips: {
      'druidcraft': 'Druidcraft',
      'produce_flame': 'Produce Flame',
      'guidance': 'Guidance',
      'thorn_whip': 'Thorn Whip',
    },
  ),
};

/// Returns the swap info for this character's race+lineage, or null if not applicable (e.g. Drow, or non-Elf).
RacialCantripSwapInfo? swapInfoFor(
  String raceId,
  Map<String, Set<String>> raceSelections,
) {
  final lineageSelection = raceSelections['elf_lineage'];
  if (lineageSelection == null || lineageSelection.isEmpty) return null;
  final key = '$raceId:${lineageSelection.first}';
  return racialCantripSwaps[key];
}
