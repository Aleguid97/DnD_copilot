import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/database.dart';
import 'database_provider.dart';

part 'resource_uses_provider.g.dart';

@riverpod
Stream<List<CharacterResourceUse>> characterResourceUses(
  CharacterResourceUsesRef ref,
  int characterId,
) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchResourceUses(characterId);
}
