import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/database.dart';
import 'database_provider.dart';

part 'party_provider.g.dart';

@riverpod
Stream<List<PartyMember>> partyMembers(PartyMembersRef ref, int characterId) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchPartyMembers(characterId);
}
