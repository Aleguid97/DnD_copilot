import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/database.dart';
import 'database_provider.dart';

part 'gold_provider.g.dart';

@riverpod
Stream<int> characterGold(CharacterGoldRef ref, int characterId) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchAllCharacters().map((all) {
    final match = all.where((c) => c.id == characterId).firstOrNull;
    return match?.goldInCopper ?? 0;
  });
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
