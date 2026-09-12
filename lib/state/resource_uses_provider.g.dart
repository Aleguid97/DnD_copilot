// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_uses_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$characterResourceUsesHash() =>
    r'81226e4804842cea1d4ccf2cd0e37af3cfc56358';

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

/// See also [characterResourceUses].
@ProviderFor(characterResourceUses)
const characterResourceUsesProvider = CharacterResourceUsesFamily();

/// See also [characterResourceUses].
class CharacterResourceUsesFamily
    extends Family<AsyncValue<List<CharacterResourceUse>>> {
  /// See also [characterResourceUses].
  const CharacterResourceUsesFamily();

  /// See also [characterResourceUses].
  CharacterResourceUsesProvider call(
    int characterId,
  ) {
    return CharacterResourceUsesProvider(
      characterId,
    );
  }

  @override
  CharacterResourceUsesProvider getProviderOverride(
    covariant CharacterResourceUsesProvider provider,
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
  String? get name => r'characterResourceUsesProvider';
}

/// See also [characterResourceUses].
class CharacterResourceUsesProvider
    extends AutoDisposeStreamProvider<List<CharacterResourceUse>> {
  /// See also [characterResourceUses].
  CharacterResourceUsesProvider(
    int characterId,
  ) : this._internal(
          (ref) => characterResourceUses(
            ref as CharacterResourceUsesRef,
            characterId,
          ),
          from: characterResourceUsesProvider,
          name: r'characterResourceUsesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$characterResourceUsesHash,
          dependencies: CharacterResourceUsesFamily._dependencies,
          allTransitiveDependencies:
              CharacterResourceUsesFamily._allTransitiveDependencies,
          characterId: characterId,
        );

  CharacterResourceUsesProvider._internal(
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
    Stream<List<CharacterResourceUse>> Function(
            CharacterResourceUsesRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CharacterResourceUsesProvider._internal(
        (ref) => create(ref as CharacterResourceUsesRef),
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
  AutoDisposeStreamProviderElement<List<CharacterResourceUse>> createElement() {
    return _CharacterResourceUsesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CharacterResourceUsesProvider &&
        other.characterId == characterId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, characterId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin CharacterResourceUsesRef
    on AutoDisposeStreamProviderRef<List<CharacterResourceUse>> {
  /// The parameter `characterId` of this provider.
  int get characterId;
}

class _CharacterResourceUsesProviderElement
    extends AutoDisposeStreamProviderElement<List<CharacterResourceUse>>
    with CharacterResourceUsesRef {
  _CharacterResourceUsesProviderElement(super.provider);

  @override
  int get characterId => (origin as CharacterResourceUsesProvider).characterId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
