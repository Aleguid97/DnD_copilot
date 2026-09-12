import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/database.dart';
import 'database_provider.dart';

part 'inventory_provider.g.dart';

@riverpod
Stream<List<CharacterInventoryItem>> characterInventory(
  CharacterInventoryRef ref,
  int characterId,
) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchInventory(characterId);
}
