// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enemies_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$combatEnemiesHash() => r'1eab5b41723ab6034591041bfb8b16c21a5ab2a6';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [combatEnemies].
@ProviderFor(combatEnemies)
const combatEnemiesProvider = CombatEnemiesFamily();

/// See also [combatEnemies].
class CombatEnemiesFamily extends Family<AsyncValue<List<CombatEnemy>>> {
  /// See also [combatEnemies].
  const CombatEnemiesFamily();

  /// See also [combatEnemies].
  CombatEnemiesProvider call(
    int characterId,
  ) {
    return CombatEnemiesProvider(
      characterId,
    );
  }

  @override
  CombatEnemiesProvider getProviderOverride(
    covariant CombatEnemiesProvider provider,
  ) {
    return call(
      provider.characterId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'combatEnemiesProvider';
}

/// See also [combatEnemies].
class CombatEnemiesProvider
    extends AutoDisposeStreamProvider<List<CombatEnemy>> {
  /// See also [combatEnemies].
  CombatEnemiesProvider(
    int characterId,
  ) : this._internal(
          (ref) => combatEnemies(
            ref as CombatEnemiesRef,
            characterId,
          ),
          from: combatEnemiesProvider,
          name: r'combatEnemiesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$combatEnemiesHash,
          dependencies: CombatEnemiesFamily._dependencies,
          allTransitiveDependencies:
              CombatEnemiesFamily._allTransitiveDependencies,
          characterId: characterId,
        );

  CombatEnemiesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.characterId,
  }) : super.internal();

  final int characterId;

  @override
  Override overrideWith(
    Stream<List<CombatEnemy>> Function(CombatEnemiesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CombatEnemiesProvider._internal(
        (ref) => create(ref as CombatEnemiesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        characterId: characterId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<CombatEnemy>> createElement() {
    return _CombatEnemiesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CombatEnemiesProvider && other.characterId == characterId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, characterId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin CombatEnemiesRef on AutoDisposeStreamProviderRef<List<CombatEnemy>> {
  /// The parameter `characterId` of this provider.
  int get characterId;
}

class _CombatEnemiesProviderElement
    extends AutoDisposeStreamProviderElement<List<CombatEnemy>>
    with CombatEnemiesRef {
  _CombatEnemiesProviderElement(super.provider);

  @override
  int get characterId => (origin as CombatEnemiesProvider).characterId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
