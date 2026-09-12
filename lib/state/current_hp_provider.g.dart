// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_hp_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentHpHash() => r'773b3ff40d0f765f16b7d3dbad786c8e0d83fc49';

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

/// See also [currentHp].
@ProviderFor(currentHp)
const currentHpProvider = CurrentHpFamily();

/// See also [currentHp].
class CurrentHpFamily extends Family<AsyncValue<int?>> {
  /// See also [currentHp].
  const CurrentHpFamily();

  /// See also [currentHp].
  CurrentHpProvider call(
    int characterId,
  ) {
    return CurrentHpProvider(
      characterId,
    );
  }

  @override
  CurrentHpProvider getProviderOverride(
    covariant CurrentHpProvider provider,
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
  String? get name => r'currentHpProvider';
}

/// See also [currentHp].
class CurrentHpProvider extends AutoDisposeStreamProvider<int?> {
  /// See also [currentHp].
  CurrentHpProvider(
    int characterId,
  ) : this._internal(
          (ref) => currentHp(
            ref as CurrentHpRef,
            characterId,
          ),
          from: currentHpProvider,
          name: r'currentHpProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$currentHpHash,
          dependencies: CurrentHpFamily._dependencies,
          allTransitiveDependencies: CurrentHpFamily._allTransitiveDependencies,
          characterId: characterId,
        );

  CurrentHpProvider._internal(
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
    Stream<int?> Function(CurrentHpRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CurrentHpProvider._internal(
        (ref) => create(ref as CurrentHpRef),
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
  AutoDisposeStreamProviderElement<int?> createElement() {
    return _CurrentHpProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CurrentHpProvider && other.characterId == characterId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, characterId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin CurrentHpRef on AutoDisposeStreamProviderRef<int?> {
  /// The parameter `characterId` of this provider.
  int get characterId;
}

class _CurrentHpProviderElement extends AutoDisposeStreamProviderElement<int?>
    with CurrentHpRef {
  _CurrentHpProviderElement(super.provider);

  @override
  int get characterId => (origin as CurrentHpProvider).characterId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
