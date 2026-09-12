// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$characterInventoryHash() =>
    r'a26783b9355c516204b9b6b6a1e0dbab3f599899';

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

/// See also [characterInventory].
@ProviderFor(characterInventory)
const characterInventoryProvider = CharacterInventoryFamily();

/// See also [characterInventory].
class CharacterInventoryFamily
    extends Family<AsyncValue<List<CharacterInventoryItem>>> {
  /// See also [characterInventory].
  const CharacterInventoryFamily();

  /// See also [characterInventory].
  CharacterInventoryProvider call(
    int characterId,
  ) {
    return CharacterInventoryProvider(
      characterId,
    );
  }

  @override
  CharacterInventoryProvider getProviderOverride(
    covariant CharacterInventoryProvider provider,
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
  String? get name => r'characterInventoryProvider';
}

/// See also [characterInventory].
class CharacterInventoryProvider
    extends AutoDisposeStreamProvider<List<CharacterInventoryItem>> {
  /// See also [characterInventory].
  CharacterInventoryProvider(
    int characterId,
  ) : this._internal(
          (ref) => characterInventory(
            ref as CharacterInventoryRef,
            characterId,
          ),
          from: characterInventoryProvider,
          name: r'characterInventoryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$characterInventoryHash,
          dependencies: CharacterInventoryFamily._dependencies,
          allTransitiveDependencies:
              CharacterInventoryFamily._allTransitiveDependencies,
          characterId: characterId,
        );

  CharacterInventoryProvider._internal(
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
    Stream<List<CharacterInventoryItem>> Function(
            CharacterInventoryRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CharacterInventoryProvider._internal(
        (ref) => create(ref as CharacterInventoryRef),
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
  AutoDisposeStreamProviderElement<List<CharacterInventoryItem>>
      createElement() {
    return _CharacterInventoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CharacterInventoryProvider &&
        other.characterId == characterId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, characterId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin CharacterInventoryRef
    on AutoDisposeStreamProviderRef<List<CharacterInventoryItem>> {
  /// The parameter `characterId` of this provider.
  int get characterId;
}

class _CharacterInventoryProviderElement
    extends AutoDisposeStreamProviderElement<List<CharacterInventoryItem>>
    with CharacterInventoryRef {
  _CharacterInventoryProviderElement(super.provider);

  @override
  int get characterId => (origin as CharacterInventoryProvider).characterId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
