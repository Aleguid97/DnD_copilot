// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SavedCharactersTable extends SavedCharacters
    with TableInfo<$SavedCharactersTable, SavedCharacter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedCharactersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _raceIdMeta = const VerificationMeta('raceId');
  @override
  late final GeneratedColumn<String> raceId = GeneratedColumn<String>(
      'race_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _classIdMeta =
      const VerificationMeta('classId');
  @override
  late final GeneratedColumn<String> classId = GeneratedColumn<String>(
      'class_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
      'level', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _backgroundIdMeta =
      const VerificationMeta('backgroundId');
  @override
  late final GeneratedColumn<String> backgroundId = GeneratedColumn<String>(
      'background_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _imagePathMeta =
      const VerificationMeta('imagePath');
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
      'image_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _xpMeta = const VerificationMeta('xp');
  @override
  late final GeneratedColumn<int> xp = GeneratedColumn<int>(
      'xp', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _goldInCopperMeta =
      const VerificationMeta('goldInCopper');
  @override
  late final GeneratedColumn<int> goldInCopper = GeneratedColumn<int>(
      'gold_in_copper', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _dataJsonMeta =
      const VerificationMeta('dataJson');
  @override
  late final GeneratedColumn<String> dataJson = GeneratedColumn<String>(
      'data_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _currentHpMeta =
      const VerificationMeta('currentHp');
  @override
  late final GeneratedColumn<int> currentHp = GeneratedColumn<int>(
      'current_hp', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _racialCantripOverrideMeta =
      const VerificationMeta('racialCantripOverride');
  @override
  late final GeneratedColumn<String> racialCantripOverride =
      GeneratedColumn<String>('racial_cantrip_override', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        raceId,
        classId,
        level,
        backgroundId,
        imagePath,
        xp,
        goldInCopper,
        dataJson,
        currentHp,
        racialCantripOverride,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_characters';
  @override
  VerificationContext validateIntegrity(Insertable<SavedCharacter> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('race_id')) {
      context.handle(_raceIdMeta,
          raceId.isAcceptableOrUnknown(data['race_id']!, _raceIdMeta));
    } else if (isInserting) {
      context.missing(_raceIdMeta);
    }
    if (data.containsKey('class_id')) {
      context.handle(_classIdMeta,
          classId.isAcceptableOrUnknown(data['class_id']!, _classIdMeta));
    } else if (isInserting) {
      context.missing(_classIdMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
          _levelMeta, level.isAcceptableOrUnknown(data['level']!, _levelMeta));
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('background_id')) {
      context.handle(
          _backgroundIdMeta,
          backgroundId.isAcceptableOrUnknown(
              data['background_id']!, _backgroundIdMeta));
    } else if (isInserting) {
      context.missing(_backgroundIdMeta);
    }
    if (data.containsKey('image_path')) {
      context.handle(_imagePathMeta,
          imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta));
    }
    if (data.containsKey('xp')) {
      context.handle(_xpMeta, xp.isAcceptableOrUnknown(data['xp']!, _xpMeta));
    }
    if (data.containsKey('gold_in_copper')) {
      context.handle(
          _goldInCopperMeta,
          goldInCopper.isAcceptableOrUnknown(
              data['gold_in_copper']!, _goldInCopperMeta));
    }
    if (data.containsKey('data_json')) {
      context.handle(_dataJsonMeta,
          dataJson.isAcceptableOrUnknown(data['data_json']!, _dataJsonMeta));
    } else if (isInserting) {
      context.missing(_dataJsonMeta);
    }
    if (data.containsKey('current_hp')) {
      context.handle(_currentHpMeta,
          currentHp.isAcceptableOrUnknown(data['current_hp']!, _currentHpMeta));
    }
    if (data.containsKey('racial_cantrip_override')) {
      context.handle(
          _racialCantripOverrideMeta,
          racialCantripOverride.isAcceptableOrUnknown(
              data['racial_cantrip_override']!, _racialCantripOverrideMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavedCharacter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedCharacter(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      raceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}race_id'])!,
      classId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}class_id'])!,
      level: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}level'])!,
      backgroundId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}background_id'])!,
      imagePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_path']),
      xp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}xp'])!,
      goldInCopper: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}gold_in_copper'])!,
      dataJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}data_json'])!,
      currentHp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}current_hp']),
      racialCantripOverride: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}racial_cantrip_override']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $SavedCharactersTable createAlias(String alias) {
    return $SavedCharactersTable(attachedDatabase, alias);
  }
}

class SavedCharacter extends DataClass implements Insertable<SavedCharacter> {
  final int id;
  final String name;
  final String raceId;
  final String classId;
  final int level;
  final String backgroundId;
  final String? imagePath;
  final int xp;
  final int goldInCopper;
  final String dataJson;
  final int? currentHp;
  final String? racialCantripOverride;
  final DateTime createdAt;
  final DateTime updatedAt;
  const SavedCharacter(
      {required this.id,
      required this.name,
      required this.raceId,
      required this.classId,
      required this.level,
      required this.backgroundId,
      this.imagePath,
      required this.xp,
      required this.goldInCopper,
      required this.dataJson,
      this.currentHp,
      this.racialCantripOverride,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['race_id'] = Variable<String>(raceId);
    map['class_id'] = Variable<String>(classId);
    map['level'] = Variable<int>(level);
    map['background_id'] = Variable<String>(backgroundId);
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    map['xp'] = Variable<int>(xp);
    map['gold_in_copper'] = Variable<int>(goldInCopper);
    map['data_json'] = Variable<String>(dataJson);
    if (!nullToAbsent || currentHp != null) {
      map['current_hp'] = Variable<int>(currentHp);
    }
    if (!nullToAbsent || racialCantripOverride != null) {
      map['racial_cantrip_override'] = Variable<String>(racialCantripOverride);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SavedCharactersCompanion toCompanion(bool nullToAbsent) {
    return SavedCharactersCompanion(
      id: Value(id),
      name: Value(name),
      raceId: Value(raceId),
      classId: Value(classId),
      level: Value(level),
      backgroundId: Value(backgroundId),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      xp: Value(xp),
      goldInCopper: Value(goldInCopper),
      dataJson: Value(dataJson),
      currentHp: currentHp == null && nullToAbsent
          ? const Value.absent()
          : Value(currentHp),
      racialCantripOverride: racialCantripOverride == null && nullToAbsent
          ? const Value.absent()
          : Value(racialCantripOverride),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SavedCharacter.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedCharacter(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      raceId: serializer.fromJson<String>(json['raceId']),
      classId: serializer.fromJson<String>(json['classId']),
      level: serializer.fromJson<int>(json['level']),
      backgroundId: serializer.fromJson<String>(json['backgroundId']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      xp: serializer.fromJson<int>(json['xp']),
      goldInCopper: serializer.fromJson<int>(json['goldInCopper']),
      dataJson: serializer.fromJson<String>(json['dataJson']),
      currentHp: serializer.fromJson<int?>(json['currentHp']),
      racialCantripOverride:
          serializer.fromJson<String?>(json['racialCantripOverride']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'raceId': serializer.toJson<String>(raceId),
      'classId': serializer.toJson<String>(classId),
      'level': serializer.toJson<int>(level),
      'backgroundId': serializer.toJson<String>(backgroundId),
      'imagePath': serializer.toJson<String?>(imagePath),
      'xp': serializer.toJson<int>(xp),
      'goldInCopper': serializer.toJson<int>(goldInCopper),
      'dataJson': serializer.toJson<String>(dataJson),
      'currentHp': serializer.toJson<int?>(currentHp),
      'racialCantripOverride':
          serializer.toJson<String?>(racialCantripOverride),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SavedCharacter copyWith(
          {int? id,
          String? name,
          String? raceId,
          String? classId,
          int? level,
          String? backgroundId,
          Value<String?> imagePath = const Value.absent(),
          int? xp,
          int? goldInCopper,
          String? dataJson,
          Value<int?> currentHp = const Value.absent(),
          Value<String?> racialCantripOverride = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      SavedCharacter(
        id: id ?? this.id,
        name: name ?? this.name,
        raceId: raceId ?? this.raceId,
        classId: classId ?? this.classId,
        level: level ?? this.level,
        backgroundId: backgroundId ?? this.backgroundId,
        imagePath: imagePath.present ? imagePath.value : this.imagePath,
        xp: xp ?? this.xp,
        goldInCopper: goldInCopper ?? this.goldInCopper,
        dataJson: dataJson ?? this.dataJson,
        currentHp: currentHp.present ? currentHp.value : this.currentHp,
        racialCantripOverride: racialCantripOverride.present
            ? racialCantripOverride.value
            : this.racialCantripOverride,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  SavedCharacter copyWithCompanion(SavedCharactersCompanion data) {
    return SavedCharacter(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      raceId: data.raceId.present ? data.raceId.value : this.raceId,
      classId: data.classId.present ? data.classId.value : this.classId,
      level: data.level.present ? data.level.value : this.level,
      backgroundId: data.backgroundId.present
          ? data.backgroundId.value
          : this.backgroundId,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      xp: data.xp.present ? data.xp.value : this.xp,
      goldInCopper: data.goldInCopper.present
          ? data.goldInCopper.value
          : this.goldInCopper,
      dataJson: data.dataJson.present ? data.dataJson.value : this.dataJson,
      currentHp: data.currentHp.present ? data.currentHp.value : this.currentHp,
      racialCantripOverride: data.racialCantripOverride.present
          ? data.racialCantripOverride.value
          : this.racialCantripOverride,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedCharacter(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('raceId: $raceId, ')
          ..write('classId: $classId, ')
          ..write('level: $level, ')
          ..write('backgroundId: $backgroundId, ')
          ..write('imagePath: $imagePath, ')
          ..write('xp: $xp, ')
          ..write('goldInCopper: $goldInCopper, ')
          ..write('dataJson: $dataJson, ')
          ..write('currentHp: $currentHp, ')
          ..write('racialCantripOverride: $racialCantripOverride, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      raceId,
      classId,
      level,
      backgroundId,
      imagePath,
      xp,
      goldInCopper,
      dataJson,
      currentHp,
      racialCantripOverride,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedCharacter &&
          other.id == this.id &&
          other.name == this.name &&
          other.raceId == this.raceId &&
          other.classId == this.classId &&
          other.level == this.level &&
          other.backgroundId == this.backgroundId &&
          other.imagePath == this.imagePath &&
          other.xp == this.xp &&
          other.goldInCopper == this.goldInCopper &&
          other.dataJson == this.dataJson &&
          other.currentHp == this.currentHp &&
          other.racialCantripOverride == this.racialCantripOverride &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SavedCharactersCompanion extends UpdateCompanion<SavedCharacter> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> raceId;
  final Value<String> classId;
  final Value<int> level;
  final Value<String> backgroundId;
  final Value<String?> imagePath;
  final Value<int> xp;
  final Value<int> goldInCopper;
  final Value<String> dataJson;
  final Value<int?> currentHp;
  final Value<String?> racialCantripOverride;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const SavedCharactersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.raceId = const Value.absent(),
    this.classId = const Value.absent(),
    this.level = const Value.absent(),
    this.backgroundId = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.xp = const Value.absent(),
    this.goldInCopper = const Value.absent(),
    this.dataJson = const Value.absent(),
    this.currentHp = const Value.absent(),
    this.racialCantripOverride = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SavedCharactersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String raceId,
    required String classId,
    required int level,
    required String backgroundId,
    this.imagePath = const Value.absent(),
    this.xp = const Value.absent(),
    this.goldInCopper = const Value.absent(),
    required String dataJson,
    this.currentHp = const Value.absent(),
    this.racialCantripOverride = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : name = Value(name),
        raceId = Value(raceId),
        classId = Value(classId),
        level = Value(level),
        backgroundId = Value(backgroundId),
        dataJson = Value(dataJson);
  static Insertable<SavedCharacter> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? raceId,
    Expression<String>? classId,
    Expression<int>? level,
    Expression<String>? backgroundId,
    Expression<String>? imagePath,
    Expression<int>? xp,
    Expression<int>? goldInCopper,
    Expression<String>? dataJson,
    Expression<int>? currentHp,
    Expression<String>? racialCantripOverride,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (raceId != null) 'race_id': raceId,
      if (classId != null) 'class_id': classId,
      if (level != null) 'level': level,
      if (backgroundId != null) 'background_id': backgroundId,
      if (imagePath != null) 'image_path': imagePath,
      if (xp != null) 'xp': xp,
      if (goldInCopper != null) 'gold_in_copper': goldInCopper,
      if (dataJson != null) 'data_json': dataJson,
      if (currentHp != null) 'current_hp': currentHp,
      if (racialCantripOverride != null)
        'racial_cantrip_override': racialCantripOverride,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SavedCharactersCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? raceId,
      Value<String>? classId,
      Value<int>? level,
      Value<String>? backgroundId,
      Value<String?>? imagePath,
      Value<int>? xp,
      Value<int>? goldInCopper,
      Value<String>? dataJson,
      Value<int?>? currentHp,
      Value<String?>? racialCantripOverride,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return SavedCharactersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      raceId: raceId ?? this.raceId,
      classId: classId ?? this.classId,
      level: level ?? this.level,
      backgroundId: backgroundId ?? this.backgroundId,
      imagePath: imagePath ?? this.imagePath,
      xp: xp ?? this.xp,
      goldInCopper: goldInCopper ?? this.goldInCopper,
      dataJson: dataJson ?? this.dataJson,
      currentHp: currentHp ?? this.currentHp,
      racialCantripOverride:
          racialCantripOverride ?? this.racialCantripOverride,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (raceId.present) {
      map['race_id'] = Variable<String>(raceId.value);
    }
    if (classId.present) {
      map['class_id'] = Variable<String>(classId.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (backgroundId.present) {
      map['background_id'] = Variable<String>(backgroundId.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (xp.present) {
      map['xp'] = Variable<int>(xp.value);
    }
    if (goldInCopper.present) {
      map['gold_in_copper'] = Variable<int>(goldInCopper.value);
    }
    if (dataJson.present) {
      map['data_json'] = Variable<String>(dataJson.value);
    }
    if (currentHp.present) {
      map['current_hp'] = Variable<int>(currentHp.value);
    }
    if (racialCantripOverride.present) {
      map['racial_cantrip_override'] =
          Variable<String>(racialCantripOverride.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedCharactersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('raceId: $raceId, ')
          ..write('classId: $classId, ')
          ..write('level: $level, ')
          ..write('backgroundId: $backgroundId, ')
          ..write('imagePath: $imagePath, ')
          ..write('xp: $xp, ')
          ..write('goldInCopper: $goldInCopper, ')
          ..write('dataJson: $dataJson, ')
          ..write('currentHp: $currentHp, ')
          ..write('racialCantripOverride: $racialCantripOverride, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $CharacterInventoryItemsTable extends CharacterInventoryItems
    with TableInfo<$CharacterInventoryItemsTable, CharacterInventoryItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CharacterInventoryItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _characterIdMeta =
      const VerificationMeta('characterId');
  @override
  late final GeneratedColumn<int> characterId = GeneratedColumn<int>(
      'character_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
      'item_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _equippedMeta =
      const VerificationMeta('equipped');
  @override
  late final GeneratedColumn<bool> equipped = GeneratedColumn<bool>(
      'equipped', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("equipped" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, characterId, itemId, quantity, equipped];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'character_inventory_items';
  @override
  VerificationContext validateIntegrity(
      Insertable<CharacterInventoryItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('character_id')) {
      context.handle(
          _characterIdMeta,
          characterId.isAcceptableOrUnknown(
              data['character_id']!, _characterIdMeta));
    } else if (isInserting) {
      context.missing(_characterIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    }
    if (data.containsKey('equipped')) {
      context.handle(_equippedMeta,
          equipped.isAcceptableOrUnknown(data['equipped']!, _equippedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CharacterInventoryItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CharacterInventoryItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      characterId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}character_id'])!,
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_id'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      equipped: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}equipped'])!,
    );
  }

  @override
  $CharacterInventoryItemsTable createAlias(String alias) {
    return $CharacterInventoryItemsTable(attachedDatabase, alias);
  }
}

class CharacterInventoryItem extends DataClass
    implements Insertable<CharacterInventoryItem> {
  final int id;
  final int characterId;
  final String itemId;
  final int quantity;
  final bool equipped;
  const CharacterInventoryItem(
      {required this.id,
      required this.characterId,
      required this.itemId,
      required this.quantity,
      required this.equipped});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['character_id'] = Variable<int>(characterId);
    map['item_id'] = Variable<String>(itemId);
    map['quantity'] = Variable<int>(quantity);
    map['equipped'] = Variable<bool>(equipped);
    return map;
  }

  CharacterInventoryItemsCompanion toCompanion(bool nullToAbsent) {
    return CharacterInventoryItemsCompanion(
      id: Value(id),
      characterId: Value(characterId),
      itemId: Value(itemId),
      quantity: Value(quantity),
      equipped: Value(equipped),
    );
  }

  factory CharacterInventoryItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CharacterInventoryItem(
      id: serializer.fromJson<int>(json['id']),
      characterId: serializer.fromJson<int>(json['characterId']),
      itemId: serializer.fromJson<String>(json['itemId']),
      quantity: serializer.fromJson<int>(json['quantity']),
      equipped: serializer.fromJson<bool>(json['equipped']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'characterId': serializer.toJson<int>(characterId),
      'itemId': serializer.toJson<String>(itemId),
      'quantity': serializer.toJson<int>(quantity),
      'equipped': serializer.toJson<bool>(equipped),
    };
  }

  CharacterInventoryItem copyWith(
          {int? id,
          int? characterId,
          String? itemId,
          int? quantity,
          bool? equipped}) =>
      CharacterInventoryItem(
        id: id ?? this.id,
        characterId: characterId ?? this.characterId,
        itemId: itemId ?? this.itemId,
        quantity: quantity ?? this.quantity,
        equipped: equipped ?? this.equipped,
      );
  CharacterInventoryItem copyWithCompanion(
      CharacterInventoryItemsCompanion data) {
    return CharacterInventoryItem(
      id: data.id.present ? data.id.value : this.id,
      characterId:
          data.characterId.present ? data.characterId.value : this.characterId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      equipped: data.equipped.present ? data.equipped.value : this.equipped,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CharacterInventoryItem(')
          ..write('id: $id, ')
          ..write('characterId: $characterId, ')
          ..write('itemId: $itemId, ')
          ..write('quantity: $quantity, ')
          ..write('equipped: $equipped')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, characterId, itemId, quantity, equipped);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CharacterInventoryItem &&
          other.id == this.id &&
          other.characterId == this.characterId &&
          other.itemId == this.itemId &&
          other.quantity == this.quantity &&
          other.equipped == this.equipped);
}

class CharacterInventoryItemsCompanion
    extends UpdateCompanion<CharacterInventoryItem> {
  final Value<int> id;
  final Value<int> characterId;
  final Value<String> itemId;
  final Value<int> quantity;
  final Value<bool> equipped;
  const CharacterInventoryItemsCompanion({
    this.id = const Value.absent(),
    this.characterId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.equipped = const Value.absent(),
  });
  CharacterInventoryItemsCompanion.insert({
    this.id = const Value.absent(),
    required int characterId,
    required String itemId,
    this.quantity = const Value.absent(),
    this.equipped = const Value.absent(),
  })  : characterId = Value(characterId),
        itemId = Value(itemId);
  static Insertable<CharacterInventoryItem> custom({
    Expression<int>? id,
    Expression<int>? characterId,
    Expression<String>? itemId,
    Expression<int>? quantity,
    Expression<bool>? equipped,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (characterId != null) 'character_id': characterId,
      if (itemId != null) 'item_id': itemId,
      if (quantity != null) 'quantity': quantity,
      if (equipped != null) 'equipped': equipped,
    });
  }

  CharacterInventoryItemsCompanion copyWith(
      {Value<int>? id,
      Value<int>? characterId,
      Value<String>? itemId,
      Value<int>? quantity,
      Value<bool>? equipped}) {
    return CharacterInventoryItemsCompanion(
      id: id ?? this.id,
      characterId: characterId ?? this.characterId,
      itemId: itemId ?? this.itemId,
      quantity: quantity ?? this.quantity,
      equipped: equipped ?? this.equipped,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (characterId.present) {
      map['character_id'] = Variable<int>(characterId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (equipped.present) {
      map['equipped'] = Variable<bool>(equipped.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CharacterInventoryItemsCompanion(')
          ..write('id: $id, ')
          ..write('characterId: $characterId, ')
          ..write('itemId: $itemId, ')
          ..write('quantity: $quantity, ')
          ..write('equipped: $equipped')
          ..write(')'))
        .toString();
  }
}

class $CharacterResourceUsesTable extends CharacterResourceUses
    with TableInfo<$CharacterResourceUsesTable, CharacterResourceUse> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CharacterResourceUsesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _characterIdMeta =
      const VerificationMeta('characterId');
  @override
  late final GeneratedColumn<int> characterId = GeneratedColumn<int>(
      'character_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _resourceIdMeta =
      const VerificationMeta('resourceId');
  @override
  late final GeneratedColumn<String> resourceId = GeneratedColumn<String>(
      'resource_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _usesSpentMeta =
      const VerificationMeta('usesSpent');
  @override
  late final GeneratedColumn<int> usesSpent = GeneratedColumn<int>(
      'uses_spent', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, characterId, resourceId, usesSpent];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'character_resource_uses';
  @override
  VerificationContext validateIntegrity(
      Insertable<CharacterResourceUse> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('character_id')) {
      context.handle(
          _characterIdMeta,
          characterId.isAcceptableOrUnknown(
              data['character_id']!, _characterIdMeta));
    } else if (isInserting) {
      context.missing(_characterIdMeta);
    }
    if (data.containsKey('resource_id')) {
      context.handle(
          _resourceIdMeta,
          resourceId.isAcceptableOrUnknown(
              data['resource_id']!, _resourceIdMeta));
    } else if (isInserting) {
      context.missing(_resourceIdMeta);
    }
    if (data.containsKey('uses_spent')) {
      context.handle(_usesSpentMeta,
          usesSpent.isAcceptableOrUnknown(data['uses_spent']!, _usesSpentMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CharacterResourceUse map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CharacterResourceUse(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      characterId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}character_id'])!,
      resourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}resource_id'])!,
      usesSpent: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}uses_spent'])!,
    );
  }

  @override
  $CharacterResourceUsesTable createAlias(String alias) {
    return $CharacterResourceUsesTable(attachedDatabase, alias);
  }
}

class CharacterResourceUse extends DataClass
    implements Insertable<CharacterResourceUse> {
  final int id;
  final int characterId;
  final String resourceId;
  final int usesSpent;
  const CharacterResourceUse(
      {required this.id,
      required this.characterId,
      required this.resourceId,
      required this.usesSpent});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['character_id'] = Variable<int>(characterId);
    map['resource_id'] = Variable<String>(resourceId);
    map['uses_spent'] = Variable<int>(usesSpent);
    return map;
  }

  CharacterResourceUsesCompanion toCompanion(bool nullToAbsent) {
    return CharacterResourceUsesCompanion(
      id: Value(id),
      characterId: Value(characterId),
      resourceId: Value(resourceId),
      usesSpent: Value(usesSpent),
    );
  }

  factory CharacterResourceUse.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CharacterResourceUse(
      id: serializer.fromJson<int>(json['id']),
      characterId: serializer.fromJson<int>(json['characterId']),
      resourceId: serializer.fromJson<String>(json['resourceId']),
      usesSpent: serializer.fromJson<int>(json['usesSpent']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'characterId': serializer.toJson<int>(characterId),
      'resourceId': serializer.toJson<String>(resourceId),
      'usesSpent': serializer.toJson<int>(usesSpent),
    };
  }

  CharacterResourceUse copyWith(
          {int? id, int? characterId, String? resourceId, int? usesSpent}) =>
      CharacterResourceUse(
        id: id ?? this.id,
        characterId: characterId ?? this.characterId,
        resourceId: resourceId ?? this.resourceId,
        usesSpent: usesSpent ?? this.usesSpent,
      );
  CharacterResourceUse copyWithCompanion(CharacterResourceUsesCompanion data) {
    return CharacterResourceUse(
      id: data.id.present ? data.id.value : this.id,
      characterId:
          data.characterId.present ? data.characterId.value : this.characterId,
      resourceId:
          data.resourceId.present ? data.resourceId.value : this.resourceId,
      usesSpent: data.usesSpent.present ? data.usesSpent.value : this.usesSpent,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CharacterResourceUse(')
          ..write('id: $id, ')
          ..write('characterId: $characterId, ')
          ..write('resourceId: $resourceId, ')
          ..write('usesSpent: $usesSpent')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, characterId, resourceId, usesSpent);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CharacterResourceUse &&
          other.id == this.id &&
          other.characterId == this.characterId &&
          other.resourceId == this.resourceId &&
          other.usesSpent == this.usesSpent);
}

class CharacterResourceUsesCompanion
    extends UpdateCompanion<CharacterResourceUse> {
  final Value<int> id;
  final Value<int> characterId;
  final Value<String> resourceId;
  final Value<int> usesSpent;
  const CharacterResourceUsesCompanion({
    this.id = const Value.absent(),
    this.characterId = const Value.absent(),
    this.resourceId = const Value.absent(),
    this.usesSpent = const Value.absent(),
  });
  CharacterResourceUsesCompanion.insert({
    this.id = const Value.absent(),
    required int characterId,
    required String resourceId,
    this.usesSpent = const Value.absent(),
  })  : characterId = Value(characterId),
        resourceId = Value(resourceId);
  static Insertable<CharacterResourceUse> custom({
    Expression<int>? id,
    Expression<int>? characterId,
    Expression<String>? resourceId,
    Expression<int>? usesSpent,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (characterId != null) 'character_id': characterId,
      if (resourceId != null) 'resource_id': resourceId,
      if (usesSpent != null) 'uses_spent': usesSpent,
    });
  }

  CharacterResourceUsesCompanion copyWith(
      {Value<int>? id,
      Value<int>? characterId,
      Value<String>? resourceId,
      Value<int>? usesSpent}) {
    return CharacterResourceUsesCompanion(
      id: id ?? this.id,
      characterId: characterId ?? this.characterId,
      resourceId: resourceId ?? this.resourceId,
      usesSpent: usesSpent ?? this.usesSpent,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (characterId.present) {
      map['character_id'] = Variable<int>(characterId.value);
    }
    if (resourceId.present) {
      map['resource_id'] = Variable<String>(resourceId.value);
    }
    if (usesSpent.present) {
      map['uses_spent'] = Variable<int>(usesSpent.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CharacterResourceUsesCompanion(')
          ..write('id: $id, ')
          ..write('characterId: $characterId, ')
          ..write('resourceId: $resourceId, ')
          ..write('usesSpent: $usesSpent')
          ..write(')'))
        .toString();
  }
}

class $CombatEnemiesTable extends CombatEnemies
    with TableInfo<$CombatEnemiesTable, CombatEnemy> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CombatEnemiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _characterIdMeta =
      const VerificationMeta('characterId');
  @override
  late final GeneratedColumn<int> characterId = GeneratedColumn<int>(
      'character_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _maxHpMeta = const VerificationMeta('maxHp');
  @override
  late final GeneratedColumn<int> maxHp = GeneratedColumn<int>(
      'max_hp', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _currentHpMeta =
      const VerificationMeta('currentHp');
  @override
  late final GeneratedColumn<int> currentHp = GeneratedColumn<int>(
      'current_hp', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _armorClassMeta =
      const VerificationMeta('armorClass');
  @override
  late final GeneratedColumn<int> armorClass = GeneratedColumn<int>(
      'armor_class', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(10));
  static const VerificationMeta _speedMeta = const VerificationMeta('speed');
  @override
  late final GeneratedColumn<int> speed = GeneratedColumn<int>(
      'speed', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(30));
  static const VerificationMeta _conditionsJsonMeta =
      const VerificationMeta('conditionsJson');
  @override
  late final GeneratedColumn<String> conditionsJson = GeneratedColumn<String>(
      'conditions_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _hasAdvantageOnNextAttackMeta =
      const VerificationMeta('hasAdvantageOnNextAttack');
  @override
  late final GeneratedColumn<bool> hasAdvantageOnNextAttack =
      GeneratedColumn<bool>(
          'has_advantage_on_next_attack', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("has_advantage_on_next_attack" IN (0, 1))'),
          defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        characterId,
        name,
        maxHp,
        currentHp,
        armorClass,
        speed,
        conditionsJson,
        hasAdvantageOnNextAttack
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'combat_enemies';
  @override
  VerificationContext validateIntegrity(Insertable<CombatEnemy> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('character_id')) {
      context.handle(
          _characterIdMeta,
          characterId.isAcceptableOrUnknown(
              data['character_id']!, _characterIdMeta));
    } else if (isInserting) {
      context.missing(_characterIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('max_hp')) {
      context.handle(
          _maxHpMeta, maxHp.isAcceptableOrUnknown(data['max_hp']!, _maxHpMeta));
    } else if (isInserting) {
      context.missing(_maxHpMeta);
    }
    if (data.containsKey('current_hp')) {
      context.handle(_currentHpMeta,
          currentHp.isAcceptableOrUnknown(data['current_hp']!, _currentHpMeta));
    } else if (isInserting) {
      context.missing(_currentHpMeta);
    }
    if (data.containsKey('armor_class')) {
      context.handle(
          _armorClassMeta,
          armorClass.isAcceptableOrUnknown(
              data['armor_class']!, _armorClassMeta));
    }
    if (data.containsKey('speed')) {
      context.handle(
          _speedMeta, speed.isAcceptableOrUnknown(data['speed']!, _speedMeta));
    }
    if (data.containsKey('conditions_json')) {
      context.handle(
          _conditionsJsonMeta,
          conditionsJson.isAcceptableOrUnknown(
              data['conditions_json']!, _conditionsJsonMeta));
    }
    if (data.containsKey('has_advantage_on_next_attack')) {
      context.handle(
          _hasAdvantageOnNextAttackMeta,
          hasAdvantageOnNextAttack.isAcceptableOrUnknown(
              data['has_advantage_on_next_attack']!,
              _hasAdvantageOnNextAttackMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CombatEnemy map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CombatEnemy(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      characterId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}character_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      maxHp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}max_hp'])!,
      currentHp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}current_hp'])!,
      armorClass: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}armor_class'])!,
      speed: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}speed'])!,
      conditionsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}conditions_json'])!,
      hasAdvantageOnNextAttack: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}has_advantage_on_next_attack'])!,
    );
  }

  @override
  $CombatEnemiesTable createAlias(String alias) {
    return $CombatEnemiesTable(attachedDatabase, alias);
  }
}

class CombatEnemy extends DataClass implements Insertable<CombatEnemy> {
  final int id;
  final int characterId;
  final String name;
  final int maxHp;
  final int currentHp;
  final int armorClass;
  final int speed;
  final String conditionsJson;
  final bool hasAdvantageOnNextAttack;
  const CombatEnemy(
      {required this.id,
      required this.characterId,
      required this.name,
      required this.maxHp,
      required this.currentHp,
      required this.armorClass,
      required this.speed,
      required this.conditionsJson,
      required this.hasAdvantageOnNextAttack});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['character_id'] = Variable<int>(characterId);
    map['name'] = Variable<String>(name);
    map['max_hp'] = Variable<int>(maxHp);
    map['current_hp'] = Variable<int>(currentHp);
    map['armor_class'] = Variable<int>(armorClass);
    map['speed'] = Variable<int>(speed);
    map['conditions_json'] = Variable<String>(conditionsJson);
    map['has_advantage_on_next_attack'] =
        Variable<bool>(hasAdvantageOnNextAttack);
    return map;
  }

  CombatEnemiesCompanion toCompanion(bool nullToAbsent) {
    return CombatEnemiesCompanion(
      id: Value(id),
      characterId: Value(characterId),
      name: Value(name),
      maxHp: Value(maxHp),
      currentHp: Value(currentHp),
      armorClass: Value(armorClass),
      speed: Value(speed),
      conditionsJson: Value(conditionsJson),
      hasAdvantageOnNextAttack: Value(hasAdvantageOnNextAttack),
    );
  }

  factory CombatEnemy.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CombatEnemy(
      id: serializer.fromJson<int>(json['id']),
      characterId: serializer.fromJson<int>(json['characterId']),
      name: serializer.fromJson<String>(json['name']),
      maxHp: serializer.fromJson<int>(json['maxHp']),
      currentHp: serializer.fromJson<int>(json['currentHp']),
      armorClass: serializer.fromJson<int>(json['armorClass']),
      speed: serializer.fromJson<int>(json['speed']),
      conditionsJson: serializer.fromJson<String>(json['conditionsJson']),
      hasAdvantageOnNextAttack:
          serializer.fromJson<bool>(json['hasAdvantageOnNextAttack']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'characterId': serializer.toJson<int>(characterId),
      'name': serializer.toJson<String>(name),
      'maxHp': serializer.toJson<int>(maxHp),
      'currentHp': serializer.toJson<int>(currentHp),
      'armorClass': serializer.toJson<int>(armorClass),
      'speed': serializer.toJson<int>(speed),
      'conditionsJson': serializer.toJson<String>(conditionsJson),
      'hasAdvantageOnNextAttack':
          serializer.toJson<bool>(hasAdvantageOnNextAttack),
    };
  }

  CombatEnemy copyWith(
          {int? id,
          int? characterId,
          String? name,
          int? maxHp,
          int? currentHp,
          int? armorClass,
          int? speed,
          String? conditionsJson,
          bool? hasAdvantageOnNextAttack}) =>
      CombatEnemy(
        id: id ?? this.id,
        characterId: characterId ?? this.characterId,
        name: name ?? this.name,
        maxHp: maxHp ?? this.maxHp,
        currentHp: currentHp ?? this.currentHp,
        armorClass: armorClass ?? this.armorClass,
        speed: speed ?? this.speed,
        conditionsJson: conditionsJson ?? this.conditionsJson,
        hasAdvantageOnNextAttack:
            hasAdvantageOnNextAttack ?? this.hasAdvantageOnNextAttack,
      );
  CombatEnemy copyWithCompanion(CombatEnemiesCompanion data) {
    return CombatEnemy(
      id: data.id.present ? data.id.value : this.id,
      characterId:
          data.characterId.present ? data.characterId.value : this.characterId,
      name: data.name.present ? data.name.value : this.name,
      maxHp: data.maxHp.present ? data.maxHp.value : this.maxHp,
      currentHp: data.currentHp.present ? data.currentHp.value : this.currentHp,
      armorClass:
          data.armorClass.present ? data.armorClass.value : this.armorClass,
      speed: data.speed.present ? data.speed.value : this.speed,
      conditionsJson: data.conditionsJson.present
          ? data.conditionsJson.value
          : this.conditionsJson,
      hasAdvantageOnNextAttack: data.hasAdvantageOnNextAttack.present
          ? data.hasAdvantageOnNextAttack.value
          : this.hasAdvantageOnNextAttack,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CombatEnemy(')
          ..write('id: $id, ')
          ..write('characterId: $characterId, ')
          ..write('name: $name, ')
          ..write('maxHp: $maxHp, ')
          ..write('currentHp: $currentHp, ')
          ..write('armorClass: $armorClass, ')
          ..write('speed: $speed, ')
          ..write('conditionsJson: $conditionsJson, ')
          ..write('hasAdvantageOnNextAttack: $hasAdvantageOnNextAttack')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, characterId, name, maxHp, currentHp,
      armorClass, speed, conditionsJson, hasAdvantageOnNextAttack);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CombatEnemy &&
          other.id == this.id &&
          other.characterId == this.characterId &&
          other.name == this.name &&
          other.maxHp == this.maxHp &&
          other.currentHp == this.currentHp &&
          other.armorClass == this.armorClass &&
          other.speed == this.speed &&
          other.conditionsJson == this.conditionsJson &&
          other.hasAdvantageOnNextAttack == this.hasAdvantageOnNextAttack);
}

class CombatEnemiesCompanion extends UpdateCompanion<CombatEnemy> {
  final Value<int> id;
  final Value<int> characterId;
  final Value<String> name;
  final Value<int> maxHp;
  final Value<int> currentHp;
  final Value<int> armorClass;
  final Value<int> speed;
  final Value<String> conditionsJson;
  final Value<bool> hasAdvantageOnNextAttack;
  const CombatEnemiesCompanion({
    this.id = const Value.absent(),
    this.characterId = const Value.absent(),
    this.name = const Value.absent(),
    this.maxHp = const Value.absent(),
    this.currentHp = const Value.absent(),
    this.armorClass = const Value.absent(),
    this.speed = const Value.absent(),
    this.conditionsJson = const Value.absent(),
    this.hasAdvantageOnNextAttack = const Value.absent(),
  });
  CombatEnemiesCompanion.insert({
    this.id = const Value.absent(),
    required int characterId,
    required String name,
    required int maxHp,
    required int currentHp,
    this.armorClass = const Value.absent(),
    this.speed = const Value.absent(),
    this.conditionsJson = const Value.absent(),
    this.hasAdvantageOnNextAttack = const Value.absent(),
  })  : characterId = Value(characterId),
        name = Value(name),
        maxHp = Value(maxHp),
        currentHp = Value(currentHp);
  static Insertable<CombatEnemy> custom({
    Expression<int>? id,
    Expression<int>? characterId,
    Expression<String>? name,
    Expression<int>? maxHp,
    Expression<int>? currentHp,
    Expression<int>? armorClass,
    Expression<int>? speed,
    Expression<String>? conditionsJson,
    Expression<bool>? hasAdvantageOnNextAttack,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (characterId != null) 'character_id': characterId,
      if (name != null) 'name': name,
      if (maxHp != null) 'max_hp': maxHp,
      if (currentHp != null) 'current_hp': currentHp,
      if (armorClass != null) 'armor_class': armorClass,
      if (speed != null) 'speed': speed,
      if (conditionsJson != null) 'conditions_json': conditionsJson,
      if (hasAdvantageOnNextAttack != null)
        'has_advantage_on_next_attack': hasAdvantageOnNextAttack,
    });
  }

  CombatEnemiesCompanion copyWith(
      {Value<int>? id,
      Value<int>? characterId,
      Value<String>? name,
      Value<int>? maxHp,
      Value<int>? currentHp,
      Value<int>? armorClass,
      Value<int>? speed,
      Value<String>? conditionsJson,
      Value<bool>? hasAdvantageOnNextAttack}) {
    return CombatEnemiesCompanion(
      id: id ?? this.id,
      characterId: characterId ?? this.characterId,
      name: name ?? this.name,
      maxHp: maxHp ?? this.maxHp,
      currentHp: currentHp ?? this.currentHp,
      armorClass: armorClass ?? this.armorClass,
      speed: speed ?? this.speed,
      conditionsJson: conditionsJson ?? this.conditionsJson,
      hasAdvantageOnNextAttack:
          hasAdvantageOnNextAttack ?? this.hasAdvantageOnNextAttack,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (characterId.present) {
      map['character_id'] = Variable<int>(characterId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (maxHp.present) {
      map['max_hp'] = Variable<int>(maxHp.value);
    }
    if (currentHp.present) {
      map['current_hp'] = Variable<int>(currentHp.value);
    }
    if (armorClass.present) {
      map['armor_class'] = Variable<int>(armorClass.value);
    }
    if (speed.present) {
      map['speed'] = Variable<int>(speed.value);
    }
    if (conditionsJson.present) {
      map['conditions_json'] = Variable<String>(conditionsJson.value);
    }
    if (hasAdvantageOnNextAttack.present) {
      map['has_advantage_on_next_attack'] =
          Variable<bool>(hasAdvantageOnNextAttack.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CombatEnemiesCompanion(')
          ..write('id: $id, ')
          ..write('characterId: $characterId, ')
          ..write('name: $name, ')
          ..write('maxHp: $maxHp, ')
          ..write('currentHp: $currentHp, ')
          ..write('armorClass: $armorClass, ')
          ..write('speed: $speed, ')
          ..write('conditionsJson: $conditionsJson, ')
          ..write('hasAdvantageOnNextAttack: $hasAdvantageOnNextAttack')
          ..write(')'))
        .toString();
  }
}

class $PartyMembersTable extends PartyMembers
    with TableInfo<$PartyMembersTable, PartyMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PartyMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _characterIdMeta =
      const VerificationMeta('characterId');
  @override
  late final GeneratedColumn<int> characterId = GeneratedColumn<int>(
      'character_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _maxHpMeta = const VerificationMeta('maxHp');
  @override
  late final GeneratedColumn<int> maxHp = GeneratedColumn<int>(
      'max_hp', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _currentHpMeta =
      const VerificationMeta('currentHp');
  @override
  late final GeneratedColumn<int> currentHp = GeneratedColumn<int>(
      'current_hp', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, characterId, name, maxHp, currentHp];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'party_members';
  @override
  VerificationContext validateIntegrity(Insertable<PartyMember> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('character_id')) {
      context.handle(
          _characterIdMeta,
          characterId.isAcceptableOrUnknown(
              data['character_id']!, _characterIdMeta));
    } else if (isInserting) {
      context.missing(_characterIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('max_hp')) {
      context.handle(
          _maxHpMeta, maxHp.isAcceptableOrUnknown(data['max_hp']!, _maxHpMeta));
    } else if (isInserting) {
      context.missing(_maxHpMeta);
    }
    if (data.containsKey('current_hp')) {
      context.handle(_currentHpMeta,
          currentHp.isAcceptableOrUnknown(data['current_hp']!, _currentHpMeta));
    } else if (isInserting) {
      context.missing(_currentHpMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PartyMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PartyMember(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      characterId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}character_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      maxHp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}max_hp'])!,
      currentHp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}current_hp'])!,
    );
  }

  @override
  $PartyMembersTable createAlias(String alias) {
    return $PartyMembersTable(attachedDatabase, alias);
  }
}

class PartyMember extends DataClass implements Insertable<PartyMember> {
  final int id;
  final int characterId;
  final String name;
  final int maxHp;
  final int currentHp;
  const PartyMember(
      {required this.id,
      required this.characterId,
      required this.name,
      required this.maxHp,
      required this.currentHp});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['character_id'] = Variable<int>(characterId);
    map['name'] = Variable<String>(name);
    map['max_hp'] = Variable<int>(maxHp);
    map['current_hp'] = Variable<int>(currentHp);
    return map;
  }

  PartyMembersCompanion toCompanion(bool nullToAbsent) {
    return PartyMembersCompanion(
      id: Value(id),
      characterId: Value(characterId),
      name: Value(name),
      maxHp: Value(maxHp),
      currentHp: Value(currentHp),
    );
  }

  factory PartyMember.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PartyMember(
      id: serializer.fromJson<int>(json['id']),
      characterId: serializer.fromJson<int>(json['characterId']),
      name: serializer.fromJson<String>(json['name']),
      maxHp: serializer.fromJson<int>(json['maxHp']),
      currentHp: serializer.fromJson<int>(json['currentHp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'characterId': serializer.toJson<int>(characterId),
      'name': serializer.toJson<String>(name),
      'maxHp': serializer.toJson<int>(maxHp),
      'currentHp': serializer.toJson<int>(currentHp),
    };
  }

  PartyMember copyWith(
          {int? id,
          int? characterId,
          String? name,
          int? maxHp,
          int? currentHp}) =>
      PartyMember(
        id: id ?? this.id,
        characterId: characterId ?? this.characterId,
        name: name ?? this.name,
        maxHp: maxHp ?? this.maxHp,
        currentHp: currentHp ?? this.currentHp,
      );
  PartyMember copyWithCompanion(PartyMembersCompanion data) {
    return PartyMember(
      id: data.id.present ? data.id.value : this.id,
      characterId:
          data.characterId.present ? data.characterId.value : this.characterId,
      name: data.name.present ? data.name.value : this.name,
      maxHp: data.maxHp.present ? data.maxHp.value : this.maxHp,
      currentHp: data.currentHp.present ? data.currentHp.value : this.currentHp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PartyMember(')
          ..write('id: $id, ')
          ..write('characterId: $characterId, ')
          ..write('name: $name, ')
          ..write('maxHp: $maxHp, ')
          ..write('currentHp: $currentHp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, characterId, name, maxHp, currentHp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PartyMember &&
          other.id == this.id &&
          other.characterId == this.characterId &&
          other.name == this.name &&
          other.maxHp == this.maxHp &&
          other.currentHp == this.currentHp);
}

class PartyMembersCompanion extends UpdateCompanion<PartyMember> {
  final Value<int> id;
  final Value<int> characterId;
  final Value<String> name;
  final Value<int> maxHp;
  final Value<int> currentHp;
  const PartyMembersCompanion({
    this.id = const Value.absent(),
    this.characterId = const Value.absent(),
    this.name = const Value.absent(),
    this.maxHp = const Value.absent(),
    this.currentHp = const Value.absent(),
  });
  PartyMembersCompanion.insert({
    this.id = const Value.absent(),
    required int characterId,
    required String name,
    required int maxHp,
    required int currentHp,
  })  : characterId = Value(characterId),
        name = Value(name),
        maxHp = Value(maxHp),
        currentHp = Value(currentHp);
  static Insertable<PartyMember> custom({
    Expression<int>? id,
    Expression<int>? characterId,
    Expression<String>? name,
    Expression<int>? maxHp,
    Expression<int>? currentHp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (characterId != null) 'character_id': characterId,
      if (name != null) 'name': name,
      if (maxHp != null) 'max_hp': maxHp,
      if (currentHp != null) 'current_hp': currentHp,
    });
  }

  PartyMembersCompanion copyWith(
      {Value<int>? id,
      Value<int>? characterId,
      Value<String>? name,
      Value<int>? maxHp,
      Value<int>? currentHp}) {
    return PartyMembersCompanion(
      id: id ?? this.id,
      characterId: characterId ?? this.characterId,
      name: name ?? this.name,
      maxHp: maxHp ?? this.maxHp,
      currentHp: currentHp ?? this.currentHp,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (characterId.present) {
      map['character_id'] = Variable<int>(characterId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (maxHp.present) {
      map['max_hp'] = Variable<int>(maxHp.value);
    }
    if (currentHp.present) {
      map['current_hp'] = Variable<int>(currentHp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PartyMembersCompanion(')
          ..write('id: $id, ')
          ..write('characterId: $characterId, ')
          ..write('name: $name, ')
          ..write('maxHp: $maxHp, ')
          ..write('currentHp: $currentHp')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SavedCharactersTable savedCharacters =
      $SavedCharactersTable(this);
  late final $CharacterInventoryItemsTable characterInventoryItems =
      $CharacterInventoryItemsTable(this);
  late final $CharacterResourceUsesTable characterResourceUses =
      $CharacterResourceUsesTable(this);
  late final $CombatEnemiesTable combatEnemies = $CombatEnemiesTable(this);
  late final $PartyMembersTable partyMembers = $PartyMembersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        savedCharacters,
        characterInventoryItems,
        characterResourceUses,
        combatEnemies,
        partyMembers
      ];
}

typedef $$SavedCharactersTableCreateCompanionBuilder = SavedCharactersCompanion
    Function({
  Value<int> id,
  required String name,
  required String raceId,
  required String classId,
  required int level,
  required String backgroundId,
  Value<String?> imagePath,
  Value<int> xp,
  Value<int> goldInCopper,
  required String dataJson,
  Value<int?> currentHp,
  Value<String?> racialCantripOverride,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$SavedCharactersTableUpdateCompanionBuilder = SavedCharactersCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<String> raceId,
  Value<String> classId,
  Value<int> level,
  Value<String> backgroundId,
  Value<String?> imagePath,
  Value<int> xp,
  Value<int> goldInCopper,
  Value<String> dataJson,
  Value<int?> currentHp,
  Value<String?> racialCantripOverride,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$SavedCharactersTableFilterComposer
    extends Composer<_$AppDatabase, $SavedCharactersTable> {
  $$SavedCharactersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get raceId => $composableBuilder(
      column: $table.raceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get classId => $composableBuilder(
      column: $table.classId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get level => $composableBuilder(
      column: $table.level, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get backgroundId => $composableBuilder(
      column: $table.backgroundId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get xp => $composableBuilder(
      column: $table.xp, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get goldInCopper => $composableBuilder(
      column: $table.goldInCopper, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dataJson => $composableBuilder(
      column: $table.dataJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get currentHp => $composableBuilder(
      column: $table.currentHp, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get racialCantripOverride => $composableBuilder(
      column: $table.racialCantripOverride,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$SavedCharactersTableOrderingComposer
    extends Composer<_$AppDatabase, $SavedCharactersTable> {
  $$SavedCharactersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get raceId => $composableBuilder(
      column: $table.raceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get classId => $composableBuilder(
      column: $table.classId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get level => $composableBuilder(
      column: $table.level, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get backgroundId => $composableBuilder(
      column: $table.backgroundId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get xp => $composableBuilder(
      column: $table.xp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get goldInCopper => $composableBuilder(
      column: $table.goldInCopper,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dataJson => $composableBuilder(
      column: $table.dataJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get currentHp => $composableBuilder(
      column: $table.currentHp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get racialCantripOverride => $composableBuilder(
      column: $table.racialCantripOverride,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$SavedCharactersTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavedCharactersTable> {
  $$SavedCharactersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get raceId =>
      $composableBuilder(column: $table.raceId, builder: (column) => column);

  GeneratedColumn<String> get classId =>
      $composableBuilder(column: $table.classId, builder: (column) => column);

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get backgroundId => $composableBuilder(
      column: $table.backgroundId, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<int> get xp =>
      $composableBuilder(column: $table.xp, builder: (column) => column);

  GeneratedColumn<int> get goldInCopper => $composableBuilder(
      column: $table.goldInCopper, builder: (column) => column);

  GeneratedColumn<String> get dataJson =>
      $composableBuilder(column: $table.dataJson, builder: (column) => column);

  GeneratedColumn<int> get currentHp =>
      $composableBuilder(column: $table.currentHp, builder: (column) => column);

  GeneratedColumn<String> get racialCantripOverride => $composableBuilder(
      column: $table.racialCantripOverride, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SavedCharactersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SavedCharactersTable,
    SavedCharacter,
    $$SavedCharactersTableFilterComposer,
    $$SavedCharactersTableOrderingComposer,
    $$SavedCharactersTableAnnotationComposer,
    $$SavedCharactersTableCreateCompanionBuilder,
    $$SavedCharactersTableUpdateCompanionBuilder,
    (
      SavedCharacter,
      BaseReferences<_$AppDatabase, $SavedCharactersTable, SavedCharacter>
    ),
    SavedCharacter,
    PrefetchHooks Function()> {
  $$SavedCharactersTableTableManager(
      _$AppDatabase db, $SavedCharactersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavedCharactersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavedCharactersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavedCharactersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> raceId = const Value.absent(),
            Value<String> classId = const Value.absent(),
            Value<int> level = const Value.absent(),
            Value<String> backgroundId = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
            Value<int> xp = const Value.absent(),
            Value<int> goldInCopper = const Value.absent(),
            Value<String> dataJson = const Value.absent(),
            Value<int?> currentHp = const Value.absent(),
            Value<String?> racialCantripOverride = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              SavedCharactersCompanion(
            id: id,
            name: name,
            raceId: raceId,
            classId: classId,
            level: level,
            backgroundId: backgroundId,
            imagePath: imagePath,
            xp: xp,
            goldInCopper: goldInCopper,
            dataJson: dataJson,
            currentHp: currentHp,
            racialCantripOverride: racialCantripOverride,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String raceId,
            required String classId,
            required int level,
            required String backgroundId,
            Value<String?> imagePath = const Value.absent(),
            Value<int> xp = const Value.absent(),
            Value<int> goldInCopper = const Value.absent(),
            required String dataJson,
            Value<int?> currentHp = const Value.absent(),
            Value<String?> racialCantripOverride = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              SavedCharactersCompanion.insert(
            id: id,
            name: name,
            raceId: raceId,
            classId: classId,
            level: level,
            backgroundId: backgroundId,
            imagePath: imagePath,
            xp: xp,
            goldInCopper: goldInCopper,
            dataJson: dataJson,
            currentHp: currentHp,
            racialCantripOverride: racialCantripOverride,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SavedCharactersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SavedCharactersTable,
    SavedCharacter,
    $$SavedCharactersTableFilterComposer,
    $$SavedCharactersTableOrderingComposer,
    $$SavedCharactersTableAnnotationComposer,
    $$SavedCharactersTableCreateCompanionBuilder,
    $$SavedCharactersTableUpdateCompanionBuilder,
    (
      SavedCharacter,
      BaseReferences<_$AppDatabase, $SavedCharactersTable, SavedCharacter>
    ),
    SavedCharacter,
    PrefetchHooks Function()>;
typedef $$CharacterInventoryItemsTableCreateCompanionBuilder
    = CharacterInventoryItemsCompanion Function({
  Value<int> id,
  required int characterId,
  required String itemId,
  Value<int> quantity,
  Value<bool> equipped,
});
typedef $$CharacterInventoryItemsTableUpdateCompanionBuilder
    = CharacterInventoryItemsCompanion Function({
  Value<int> id,
  Value<int> characterId,
  Value<String> itemId,
  Value<int> quantity,
  Value<bool> equipped,
});

class $$CharacterInventoryItemsTableFilterComposer
    extends Composer<_$AppDatabase, $CharacterInventoryItemsTable> {
  $$CharacterInventoryItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get characterId => $composableBuilder(
      column: $table.characterId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get equipped => $composableBuilder(
      column: $table.equipped, builder: (column) => ColumnFilters(column));
}

class $$CharacterInventoryItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $CharacterInventoryItemsTable> {
  $$CharacterInventoryItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get characterId => $composableBuilder(
      column: $table.characterId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get equipped => $composableBuilder(
      column: $table.equipped, builder: (column) => ColumnOrderings(column));
}

class $$CharacterInventoryItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CharacterInventoryItemsTable> {
  $$CharacterInventoryItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get characterId => $composableBuilder(
      column: $table.characterId, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<bool> get equipped =>
      $composableBuilder(column: $table.equipped, builder: (column) => column);
}

class $$CharacterInventoryItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CharacterInventoryItemsTable,
    CharacterInventoryItem,
    $$CharacterInventoryItemsTableFilterComposer,
    $$CharacterInventoryItemsTableOrderingComposer,
    $$CharacterInventoryItemsTableAnnotationComposer,
    $$CharacterInventoryItemsTableCreateCompanionBuilder,
    $$CharacterInventoryItemsTableUpdateCompanionBuilder,
    (
      CharacterInventoryItem,
      BaseReferences<_$AppDatabase, $CharacterInventoryItemsTable,
          CharacterInventoryItem>
    ),
    CharacterInventoryItem,
    PrefetchHooks Function()> {
  $$CharacterInventoryItemsTableTableManager(
      _$AppDatabase db, $CharacterInventoryItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CharacterInventoryItemsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$CharacterInventoryItemsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CharacterInventoryItemsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> characterId = const Value.absent(),
            Value<String> itemId = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<bool> equipped = const Value.absent(),
          }) =>
              CharacterInventoryItemsCompanion(
            id: id,
            characterId: characterId,
            itemId: itemId,
            quantity: quantity,
            equipped: equipped,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int characterId,
            required String itemId,
            Value<int> quantity = const Value.absent(),
            Value<bool> equipped = const Value.absent(),
          }) =>
              CharacterInventoryItemsCompanion.insert(
            id: id,
            characterId: characterId,
            itemId: itemId,
            quantity: quantity,
            equipped: equipped,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CharacterInventoryItemsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $CharacterInventoryItemsTable,
        CharacterInventoryItem,
        $$CharacterInventoryItemsTableFilterComposer,
        $$CharacterInventoryItemsTableOrderingComposer,
        $$CharacterInventoryItemsTableAnnotationComposer,
        $$CharacterInventoryItemsTableCreateCompanionBuilder,
        $$CharacterInventoryItemsTableUpdateCompanionBuilder,
        (
          CharacterInventoryItem,
          BaseReferences<_$AppDatabase, $CharacterInventoryItemsTable,
              CharacterInventoryItem>
        ),
        CharacterInventoryItem,
        PrefetchHooks Function()>;
typedef $$CharacterResourceUsesTableCreateCompanionBuilder
    = CharacterResourceUsesCompanion Function({
  Value<int> id,
  required int characterId,
  required String resourceId,
  Value<int> usesSpent,
});
typedef $$CharacterResourceUsesTableUpdateCompanionBuilder
    = CharacterResourceUsesCompanion Function({
  Value<int> id,
  Value<int> characterId,
  Value<String> resourceId,
  Value<int> usesSpent,
});

class $$CharacterResourceUsesTableFilterComposer
    extends Composer<_$AppDatabase, $CharacterResourceUsesTable> {
  $$CharacterResourceUsesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get characterId => $composableBuilder(
      column: $table.characterId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get resourceId => $composableBuilder(
      column: $table.resourceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get usesSpent => $composableBuilder(
      column: $table.usesSpent, builder: (column) => ColumnFilters(column));
}

class $$CharacterResourceUsesTableOrderingComposer
    extends Composer<_$AppDatabase, $CharacterResourceUsesTable> {
  $$CharacterResourceUsesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get characterId => $composableBuilder(
      column: $table.characterId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get resourceId => $composableBuilder(
      column: $table.resourceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get usesSpent => $composableBuilder(
      column: $table.usesSpent, builder: (column) => ColumnOrderings(column));
}

class $$CharacterResourceUsesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CharacterResourceUsesTable> {
  $$CharacterResourceUsesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get characterId => $composableBuilder(
      column: $table.characterId, builder: (column) => column);

  GeneratedColumn<String> get resourceId => $composableBuilder(
      column: $table.resourceId, builder: (column) => column);

  GeneratedColumn<int> get usesSpent =>
      $composableBuilder(column: $table.usesSpent, builder: (column) => column);
}

class $$CharacterResourceUsesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CharacterResourceUsesTable,
    CharacterResourceUse,
    $$CharacterResourceUsesTableFilterComposer,
    $$CharacterResourceUsesTableOrderingComposer,
    $$CharacterResourceUsesTableAnnotationComposer,
    $$CharacterResourceUsesTableCreateCompanionBuilder,
    $$CharacterResourceUsesTableUpdateCompanionBuilder,
    (
      CharacterResourceUse,
      BaseReferences<_$AppDatabase, $CharacterResourceUsesTable,
          CharacterResourceUse>
    ),
    CharacterResourceUse,
    PrefetchHooks Function()> {
  $$CharacterResourceUsesTableTableManager(
      _$AppDatabase db, $CharacterResourceUsesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CharacterResourceUsesTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$CharacterResourceUsesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CharacterResourceUsesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> characterId = const Value.absent(),
            Value<String> resourceId = const Value.absent(),
            Value<int> usesSpent = const Value.absent(),
          }) =>
              CharacterResourceUsesCompanion(
            id: id,
            characterId: characterId,
            resourceId: resourceId,
            usesSpent: usesSpent,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int characterId,
            required String resourceId,
            Value<int> usesSpent = const Value.absent(),
          }) =>
              CharacterResourceUsesCompanion.insert(
            id: id,
            characterId: characterId,
            resourceId: resourceId,
            usesSpent: usesSpent,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CharacterResourceUsesTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $CharacterResourceUsesTable,
        CharacterResourceUse,
        $$CharacterResourceUsesTableFilterComposer,
        $$CharacterResourceUsesTableOrderingComposer,
        $$CharacterResourceUsesTableAnnotationComposer,
        $$CharacterResourceUsesTableCreateCompanionBuilder,
        $$CharacterResourceUsesTableUpdateCompanionBuilder,
        (
          CharacterResourceUse,
          BaseReferences<_$AppDatabase, $CharacterResourceUsesTable,
              CharacterResourceUse>
        ),
        CharacterResourceUse,
        PrefetchHooks Function()>;
typedef $$CombatEnemiesTableCreateCompanionBuilder = CombatEnemiesCompanion
    Function({
  Value<int> id,
  required int characterId,
  required String name,
  required int maxHp,
  required int currentHp,
  Value<int> armorClass,
  Value<int> speed,
  Value<String> conditionsJson,
  Value<bool> hasAdvantageOnNextAttack,
});
typedef $$CombatEnemiesTableUpdateCompanionBuilder = CombatEnemiesCompanion
    Function({
  Value<int> id,
  Value<int> characterId,
  Value<String> name,
  Value<int> maxHp,
  Value<int> currentHp,
  Value<int> armorClass,
  Value<int> speed,
  Value<String> conditionsJson,
  Value<bool> hasAdvantageOnNextAttack,
});

class $$CombatEnemiesTableFilterComposer
    extends Composer<_$AppDatabase, $CombatEnemiesTable> {
  $$CombatEnemiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get characterId => $composableBuilder(
      column: $table.characterId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxHp => $composableBuilder(
      column: $table.maxHp, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get currentHp => $composableBuilder(
      column: $table.currentHp, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get armorClass => $composableBuilder(
      column: $table.armorClass, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get speed => $composableBuilder(
      column: $table.speed, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get conditionsJson => $composableBuilder(
      column: $table.conditionsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get hasAdvantageOnNextAttack => $composableBuilder(
      column: $table.hasAdvantageOnNextAttack,
      builder: (column) => ColumnFilters(column));
}

class $$CombatEnemiesTableOrderingComposer
    extends Composer<_$AppDatabase, $CombatEnemiesTable> {
  $$CombatEnemiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get characterId => $composableBuilder(
      column: $table.characterId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxHp => $composableBuilder(
      column: $table.maxHp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get currentHp => $composableBuilder(
      column: $table.currentHp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get armorClass => $composableBuilder(
      column: $table.armorClass, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get speed => $composableBuilder(
      column: $table.speed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get conditionsJson => $composableBuilder(
      column: $table.conditionsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get hasAdvantageOnNextAttack => $composableBuilder(
      column: $table.hasAdvantageOnNextAttack,
      builder: (column) => ColumnOrderings(column));
}

class $$CombatEnemiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CombatEnemiesTable> {
  $$CombatEnemiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get characterId => $composableBuilder(
      column: $table.characterId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get maxHp =>
      $composableBuilder(column: $table.maxHp, builder: (column) => column);

  GeneratedColumn<int> get currentHp =>
      $composableBuilder(column: $table.currentHp, builder: (column) => column);

  GeneratedColumn<int> get armorClass => $composableBuilder(
      column: $table.armorClass, builder: (column) => column);

  GeneratedColumn<int> get speed =>
      $composableBuilder(column: $table.speed, builder: (column) => column);

  GeneratedColumn<String> get conditionsJson => $composableBuilder(
      column: $table.conditionsJson, builder: (column) => column);

  GeneratedColumn<bool> get hasAdvantageOnNextAttack => $composableBuilder(
      column: $table.hasAdvantageOnNextAttack, builder: (column) => column);
}

class $$CombatEnemiesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CombatEnemiesTable,
    CombatEnemy,
    $$CombatEnemiesTableFilterComposer,
    $$CombatEnemiesTableOrderingComposer,
    $$CombatEnemiesTableAnnotationComposer,
    $$CombatEnemiesTableCreateCompanionBuilder,
    $$CombatEnemiesTableUpdateCompanionBuilder,
    (
      CombatEnemy,
      BaseReferences<_$AppDatabase, $CombatEnemiesTable, CombatEnemy>
    ),
    CombatEnemy,
    PrefetchHooks Function()> {
  $$CombatEnemiesTableTableManager(_$AppDatabase db, $CombatEnemiesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CombatEnemiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CombatEnemiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CombatEnemiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> characterId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> maxHp = const Value.absent(),
            Value<int> currentHp = const Value.absent(),
            Value<int> armorClass = const Value.absent(),
            Value<int> speed = const Value.absent(),
            Value<String> conditionsJson = const Value.absent(),
            Value<bool> hasAdvantageOnNextAttack = const Value.absent(),
          }) =>
              CombatEnemiesCompanion(
            id: id,
            characterId: characterId,
            name: name,
            maxHp: maxHp,
            currentHp: currentHp,
            armorClass: armorClass,
            speed: speed,
            conditionsJson: conditionsJson,
            hasAdvantageOnNextAttack: hasAdvantageOnNextAttack,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int characterId,
            required String name,
            required int maxHp,
            required int currentHp,
            Value<int> armorClass = const Value.absent(),
            Value<int> speed = const Value.absent(),
            Value<String> conditionsJson = const Value.absent(),
            Value<bool> hasAdvantageOnNextAttack = const Value.absent(),
          }) =>
              CombatEnemiesCompanion.insert(
            id: id,
            characterId: characterId,
            name: name,
            maxHp: maxHp,
            currentHp: currentHp,
            armorClass: armorClass,
            speed: speed,
            conditionsJson: conditionsJson,
            hasAdvantageOnNextAttack: hasAdvantageOnNextAttack,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CombatEnemiesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CombatEnemiesTable,
    CombatEnemy,
    $$CombatEnemiesTableFilterComposer,
    $$CombatEnemiesTableOrderingComposer,
    $$CombatEnemiesTableAnnotationComposer,
    $$CombatEnemiesTableCreateCompanionBuilder,
    $$CombatEnemiesTableUpdateCompanionBuilder,
    (
      CombatEnemy,
      BaseReferences<_$AppDatabase, $CombatEnemiesTable, CombatEnemy>
    ),
    CombatEnemy,
    PrefetchHooks Function()>;
typedef $$PartyMembersTableCreateCompanionBuilder = PartyMembersCompanion
    Function({
  Value<int> id,
  required int characterId,
  required String name,
  required int maxHp,
  required int currentHp,
});
typedef $$PartyMembersTableUpdateCompanionBuilder = PartyMembersCompanion
    Function({
  Value<int> id,
  Value<int> characterId,
  Value<String> name,
  Value<int> maxHp,
  Value<int> currentHp,
});

class $$PartyMembersTableFilterComposer
    extends Composer<_$AppDatabase, $PartyMembersTable> {
  $$PartyMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get characterId => $composableBuilder(
      column: $table.characterId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxHp => $composableBuilder(
      column: $table.maxHp, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get currentHp => $composableBuilder(
      column: $table.currentHp, builder: (column) => ColumnFilters(column));
}

class $$PartyMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $PartyMembersTable> {
  $$PartyMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get characterId => $composableBuilder(
      column: $table.characterId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxHp => $composableBuilder(
      column: $table.maxHp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get currentHp => $composableBuilder(
      column: $table.currentHp, builder: (column) => ColumnOrderings(column));
}

class $$PartyMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $PartyMembersTable> {
  $$PartyMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get characterId => $composableBuilder(
      column: $table.characterId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get maxHp =>
      $composableBuilder(column: $table.maxHp, builder: (column) => column);

  GeneratedColumn<int> get currentHp =>
      $composableBuilder(column: $table.currentHp, builder: (column) => column);
}

class $$PartyMembersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PartyMembersTable,
    PartyMember,
    $$PartyMembersTableFilterComposer,
    $$PartyMembersTableOrderingComposer,
    $$PartyMembersTableAnnotationComposer,
    $$PartyMembersTableCreateCompanionBuilder,
    $$PartyMembersTableUpdateCompanionBuilder,
    (
      PartyMember,
      BaseReferences<_$AppDatabase, $PartyMembersTable, PartyMember>
    ),
    PartyMember,
    PrefetchHooks Function()> {
  $$PartyMembersTableTableManager(_$AppDatabase db, $PartyMembersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PartyMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PartyMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PartyMembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> characterId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> maxHp = const Value.absent(),
            Value<int> currentHp = const Value.absent(),
          }) =>
              PartyMembersCompanion(
            id: id,
            characterId: characterId,
            name: name,
            maxHp: maxHp,
            currentHp: currentHp,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int characterId,
            required String name,
            required int maxHp,
            required int currentHp,
          }) =>
              PartyMembersCompanion.insert(
            id: id,
            characterId: characterId,
            name: name,
            maxHp: maxHp,
            currentHp: currentHp,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PartyMembersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PartyMembersTable,
    PartyMember,
    $$PartyMembersTableFilterComposer,
    $$PartyMembersTableOrderingComposer,
    $$PartyMembersTableAnnotationComposer,
    $$PartyMembersTableCreateCompanionBuilder,
    $$PartyMembersTableUpdateCompanionBuilder,
    (
      PartyMember,
      BaseReferences<_$AppDatabase, $PartyMembersTable, PartyMember>
    ),
    PartyMember,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SavedCharactersTableTableManager get savedCharacters =>
      $$SavedCharactersTableTableManager(_db, _db.savedCharacters);
  $$CharacterInventoryItemsTableTableManager get characterInventoryItems =>
      $$CharacterInventoryItemsTableTableManager(
          _db, _db.characterInventoryItems);
  $$CharacterResourceUsesTableTableManager get characterResourceUses =>
      $$CharacterResourceUsesTableTableManager(_db, _db.characterResourceUses);
  $$CombatEnemiesTableTableManager get combatEnemies =>
      $$CombatEnemiesTableTableManager(_db, _db.combatEnemies);
  $$PartyMembersTableTableManager get partyMembers =>
      $$PartyMembersTableTableManager(_db, _db.partyMembers);
}
