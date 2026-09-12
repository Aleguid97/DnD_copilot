import 'dart:io';
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../models/starting_equipment.dart';
import '../models/class_resource.dart';

part 'database.g.dart';

class SavedCharacters extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get raceId => text()();
  TextColumn get classId => text()();
  IntColumn get level => integer()();
  TextColumn get backgroundId => text()();
  TextColumn get imagePath => text().nullable()();
  IntColumn get xp => integer().withDefault(const Constant(0))();
  IntColumn get goldInCopper => integer().withDefault(const Constant(0))();
  TextColumn get dataJson => text()();
  IntColumn get currentHp => integer().nullable()();
  TextColumn get racialCantripOverride => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class CharacterInventoryItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get characterId => integer()();
  TextColumn get itemId => text()();
  IntColumn get quantity => integer().withDefault(const Constant(1))();
  BoolColumn get equipped => boolean().withDefault(const Constant(false))();
}

class CharacterResourceUses extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get characterId => integer()();
  TextColumn get resourceId => text()();
  IntColumn get usesSpent => integer().withDefault(const Constant(0))();
}

class CombatEnemies extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get characterId => integer()();
  TextColumn get name => text()();
  IntColumn get maxHp => integer()();
  IntColumn get currentHp => integer()();
  IntColumn get armorClass => integer().withDefault(const Constant(10))();
  IntColumn get speed => integer().withDefault(const Constant(30))();
  TextColumn get conditionsJson => text().withDefault(const Constant('[]'))();
  BoolColumn get hasAdvantageOnNextAttack =>
      boolean().withDefault(const Constant(false))();
}

class PartyMembers extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get characterId => integer()();
  TextColumn get name => text()();
  IntColumn get maxHp => integer()();
  IntColumn get currentHp => integer()();
}

@DriftDatabase(
  tables: [
    SavedCharacters,
    CharacterInventoryItems,
    CharacterResourceUses,
    CombatEnemies,
    PartyMembers,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(characterInventoryItems);
      }
      if (from < 3) {
        await m.addColumn(savedCharacters, savedCharacters.goldInCopper);
      }
      if (from < 4) {
        await m.createTable(characterResourceUses);
      }
      if (from < 5) {
        await m.addColumn(savedCharacters, savedCharacters.currentHp);
      }
      if (from < 6) {
        await m.createTable(combatEnemies);
      }
      if (from < 7) {
        await m.addColumn(
          savedCharacters,
          savedCharacters.racialCantripOverride,
        );
      }
      if (from < 8) {
        await m.createTable(partyMembers);
      }
    },
  );

  Future<List<SavedCharacter>> getAllCharacters() =>
      select(savedCharacters).get();

  Stream<List<SavedCharacter>> watchAllCharacters() =>
      select(savedCharacters).watch();

  Future<int> insertCharacter(SavedCharactersCompanion entry) =>
      into(savedCharacters).insert(entry);

  Future<bool> updateCharacter(SavedCharacter entry) =>
      update(savedCharacters).replace(entry);

  Future<int> deleteCharacter(int id) =>
      (delete(savedCharacters)..where((tbl) => tbl.id.equals(id))).go();

  Future<void> updateXp(int id, int newXp, int newLevel) async {
    await (update(savedCharacters)..where((t) => t.id.equals(id))).write(
      SavedCharactersCompanion(
        xp: Value(newXp),
        level: Value(newLevel),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> updateCharacterData(
    int id, {
    required int level,
    required String dataJson,
  }) async {
    await (update(savedCharacters)..where((t) => t.id.equals(id))).write(
      SavedCharactersCompanion(
        level: Value(level),
        dataJson: Value(dataJson),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<SavedCharacter> getCharacterById(int id) =>
      (select(savedCharacters)..where((t) => t.id.equals(id))).getSingle();

  Future<void> updateXpOnly(int id, int newXp) async {
    await (update(savedCharacters)..where((t) => t.id.equals(id))).write(
      SavedCharactersCompanion(
        xp: Value(newXp),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> setGold(int id, int goldInCopper) async {
    await (update(savedCharacters)..where((t) => t.id.equals(id))).write(
      SavedCharactersCompanion(goldInCopper: Value(goldInCopper)),
    );
  }

  Future<void> setCurrentHp(int id, int currentHp) async {
    await (update(savedCharacters)..where((t) => t.id.equals(id))).write(
      SavedCharactersCompanion(currentHp: Value(currentHp)),
    );
  }

  Future<void> setRacialCantripOverride(int id, String? cantripId) async {
    await (update(savedCharacters)..where((t) => t.id.equals(id))).write(
      SavedCharactersCompanion(racialCantripOverride: Value(cantripId)),
    );
  }

  Stream<List<CharacterInventoryItem>> watchInventory(int characterId) =>
      (select(
        characterInventoryItems,
      )..where((t) => t.characterId.equals(characterId))).watch();

  Future<void> addInventoryItem(
    int characterId,
    String itemId, {
    int quantity = 1,
  }) async {
    final existing =
        await (select(characterInventoryItems)..where(
              (t) =>
                  t.characterId.equals(characterId) & t.itemId.equals(itemId),
            ))
            .getSingleOrNull();
    if (existing != null) {
      await (update(
        characterInventoryItems,
      )..where((t) => t.id.equals(existing.id))).write(
        CharacterInventoryItemsCompanion(
          quantity: Value(existing.quantity + quantity),
        ),
      );
    } else {
      await into(characterInventoryItems).insert(
        CharacterInventoryItemsCompanion.insert(
          characterId: characterId,
          itemId: itemId,
          quantity: Value(quantity),
        ),
      );
    }
  }

  Future<void> setInventoryQuantity(int rowId, int quantity) async {
    if (quantity <= 0) {
      await (delete(
        characterInventoryItems,
      )..where((t) => t.id.equals(rowId))).go();
    } else {
      await (update(characterInventoryItems)..where((t) => t.id.equals(rowId)))
          .write(CharacterInventoryItemsCompanion(quantity: Value(quantity)));
    }
  }

  Future<void> toggleEquipped(int rowId, bool equipped) async {
    await (update(characterInventoryItems)..where((t) => t.id.equals(rowId)))
        .write(CharacterInventoryItemsCompanion(equipped: Value(equipped)));
  }

  Future<void> removeInventoryItem(int rowId) async {
    await (delete(
      characterInventoryItems,
    )..where((t) => t.id.equals(rowId))).go();
  }

  Stream<List<CharacterResourceUse>> watchResourceUses(int characterId) =>
      (select(
        characterResourceUses,
      )..where((t) => t.characterId.equals(characterId))).watch();

  Future<void> useResource(
    int characterId,
    String resourceId,
    int maxUses,
  ) async {
    final existing =
        await (select(characterResourceUses)..where(
              (t) =>
                  t.characterId.equals(characterId) &
                  t.resourceId.equals(resourceId),
            ))
            .getSingleOrNull();
    if (existing != null) {
      final newSpent = (existing.usesSpent + 1).clamp(0, maxUses);
      await (update(characterResourceUses)
            ..where((t) => t.id.equals(existing.id)))
          .write(CharacterResourceUsesCompanion(usesSpent: Value(newSpent)));
    } else {
      await into(characterResourceUses).insert(
        CharacterResourceUsesCompanion.insert(
          characterId: characterId,
          resourceId: resourceId,
          usesSpent: Value(1.clamp(0, maxUses)),
        ),
      );
    }
  }

  Future<void> applyRest(
    int characterId,
    RestType restType,
    List<ClassResource> resources,
  ) async {
    for (final resource in resources) {
      final existing =
          await (select(characterResourceUses)..where(
                (t) =>
                    t.characterId.equals(characterId) &
                    t.resourceId.equals(resource.id),
              ))
              .getSingleOrNull();
      if (existing == null) continue;

      int newSpent = existing.usesSpent;
      if (restType == RestType.long) {
        newSpent = 0;
      } else if (restType == RestType.short) {
        if (resource.fullRecoveryOn == RestType.short) {
          newSpent = 0;
        } else if (resource.shortRestPartialRecovery > 0) {
          newSpent = (existing.usesSpent - resource.shortRestPartialRecovery)
              .clamp(0, 999);
        }
      }
      await (update(characterResourceUses)
            ..where((t) => t.id.equals(existing.id)))
          .write(CharacterResourceUsesCompanion(usesSpent: Value(newSpent)));
    }
  }

  Stream<List<CombatEnemy>> watchEnemies(int characterId) => (select(
    combatEnemies,
  )..where((t) => t.characterId.equals(characterId))).watch();

  Future<int> addEnemy(
    int characterId,
    String name,
    int maxHp, {
    int armorClass = 10,
  }) {
    return into(combatEnemies).insert(
      CombatEnemiesCompanion.insert(
        characterId: characterId,
        name: name,
        maxHp: maxHp,
        currentHp: maxHp,
        armorClass: Value(armorClass),
      ),
    );
  }

  Future<void> updateEnemyHp(int enemyId, int newHp) async {
    await (update(combatEnemies)..where((t) => t.id.equals(enemyId))).write(
      CombatEnemiesCompanion(currentHp: Value(newHp)),
    );
  }

  Future<void> updateEnemySpeed(int enemyId, int newSpeed) async {
    await (update(combatEnemies)..where((t) => t.id.equals(enemyId))).write(
      CombatEnemiesCompanion(speed: Value(newSpeed)),
    );
  }

  Future<void> updateEnemyConditions(
    int enemyId,
    List<String> conditions,
  ) async {
    await (update(combatEnemies)..where((t) => t.id.equals(enemyId))).write(
      CombatEnemiesCompanion(conditionsJson: Value(jsonEncode(conditions))),
    );
  }

  Future<void> setEnemyAdvantageFlag(int enemyId, bool value) async {
    await (update(combatEnemies)..where((t) => t.id.equals(enemyId))).write(
      CombatEnemiesCompanion(hasAdvantageOnNextAttack: Value(value)),
    );
  }

  Future<void> removeEnemy(int enemyId) async {
    await (delete(combatEnemies)..where((t) => t.id.equals(enemyId))).go();
  }

  Future<void> clearAllEnemies(int characterId) async {
    await (delete(
      combatEnemies,
    )..where((t) => t.characterId.equals(characterId))).go();
  }

  Stream<List<PartyMember>> watchPartyMembers(int characterId) => (select(
    partyMembers,
  )..where((t) => t.characterId.equals(characterId))).watch();

  Future<int> addPartyMember(int characterId, String name, int maxHp) {
    return into(partyMembers).insert(
      PartyMembersCompanion.insert(
        characterId: characterId,
        name: name,
        maxHp: maxHp,
        currentHp: maxHp,
      ),
    );
  }

  Future<void> updatePartyMemberHp(int memberId, int newHp) async {
    await (update(partyMembers)..where((t) => t.id.equals(memberId))).write(
      PartyMembersCompanion(currentHp: Value(newHp)),
    );
  }

  Future<void> removePartyMember(int memberId) async {
    await (delete(partyMembers)..where((t) => t.id.equals(memberId))).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'dnd_prova.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
