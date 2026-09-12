import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/database.dart';
import 'database_provider.dart';

part 'saved_characters_provider.g.dart';

@riverpod
Stream<List<SavedCharacter>> savedCharacters(SavedCharactersRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchAllCharacters();
}
