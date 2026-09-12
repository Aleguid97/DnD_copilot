// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gold_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$characterGoldHash() => r'45da46c5bcb8a51a1979f20dc111e82351d55377';

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

/// See also [characterGold].
@ProviderFor(characterGold)
const characterGoldProvider = CharacterGoldFamily();

/// See also [characterGold].
class CharacterGoldFamily extends Family<AsyncValue<int>> {
  /// See also [characterGold].
  const CharacterGoldFamily();

  /// See also [characterGold].
  CharacterGoldProvider call(
    int characterId,
  ) {
    return CharacterGoldProvider(
      characterId,
    );
  }

  @override
  CharacterGoldProvider getProviderOverride(
    covariant CharacterGoldProvider provider,
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
  String? get name => r'characterGoldProvider';
}

/// See also [characterGold].
class CharacterGoldProvider extends AutoDisposeStreamProvider<int> {
  /// See also [characterGold].
  CharacterGoldProvider(
    int characterId,
  ) : this._internal(
          (ref) => characterGold(
            ref as CharacterGoldRef,
            characterId,
          ),
          from: characterGoldProvider,
          name: r'characterGoldProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$characterGoldHash,
          dependencies: CharacterGoldFamily._dependencies,
          allTransitiveDependencies:
              CharacterGoldFamily._allTransitiveDependencies,
          characterId: characterId,
        );

  CharacterGoldProvider._internal(
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
    Stream<int> Function(CharacterGoldRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CharacterGoldProvider._internal(
        (ref) => create(ref as CharacterGoldRef),
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
  AutoDisposeStreamProviderElement<int> createElement() {
    return _CharacterGoldProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CharacterGoldProvider && other.characterId == characterId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, characterId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin CharacterGoldRef on AutoDisposeStreamProviderRef<int> {
  /// The parameter `characterId` of this provider.
  int get characterId;
}

class _CharacterGoldProviderElement
    extends AutoDisposeStreamProviderElement<int> with CharacterGoldRef {
  _CharacterGoldProviderElement(super.provider);

  @override
  int get characterId => (origin as CharacterGoldProvider).characterId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
