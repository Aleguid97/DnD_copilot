import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/database.dart';
import 'database_provider.dart';

part 'enemies_provider.g.dart';

@riverpod
Stream<List<CombatEnemy>> combatEnemies(CombatEnemiesRef ref, int characterId) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchEnemies(characterId);
}
