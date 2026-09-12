import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/database.dart';
import 'database_provider.dart';

part 'racial_cantrip_provider.g.dart';

@riverpod
Stream<String?> racialCantripOverride(
  RacialCantripOverrideRef ref,
  int characterId,
) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchAllCharacters().map((all) {
    final match = all.where((c) => c.id == characterId).firstOrNull;
    return match?.racialCantripOverride;
  });
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
