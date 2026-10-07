/// Origin feats a character has, as lowercase ids ('tough', 'lucky',
/// 'magic_initiate_cleric', ...). Sources: the background's origin feat and,
/// for Humans, the extra feat chosen with Versatile.

/// 'Magic Initiate (Cleric)' -> 'magic_initiate_cleric', 'Tough' -> 'tough'.
String featIdFromName(String name) => name
    .toLowerCase()
    .replaceAll(RegExp(r'[()]'), '')
    .trim()
    .replaceAll(RegExp(r'\s+'), '_');

Set<String> featIdsFor({
  required String originFeatName,
  required Map<String, Set<String>> raceSelections,
}) {
  final ids = <String>{};
  if (originFeatName.trim().isNotEmpty) {
    ids.add(featIdFromName(originFeatName));
  }
  ids.addAll(raceSelections['human_versatile'] ?? const <String>{});
  return ids;
}
