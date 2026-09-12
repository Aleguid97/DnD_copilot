// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'racial_cantrip_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$racialCantripOverrideHash() =>
    r'174be96b69ff92b0436a3363259e897e83be655f';

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

/// See also [racialCantripOverride].
@ProviderFor(racialCantripOverride)
const racialCantripOverrideProvider = RacialCantripOverrideFamily();

/// See also [racialCantripOverride].
class RacialCantripOverrideFamily extends Family<AsyncValue<String?>> {
  /// See also [racialCantripOverride].
  const RacialCantripOverrideFamily();

  /// See also [racialCantripOverride].
  RacialCantripOverrideProvider call(
    int characterId,
  ) {
    return RacialCantripOverrideProvider(
      characterId,
    );
  }

  @override
  RacialCantripOverrideProvider getProviderOverride(
    covariant RacialCantripOverrideProvider provider,
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
  String? get name => r'racialCantripOverrideProvider';
}

/// See also [racialCantripOverride].
class RacialCantripOverrideProvider extends AutoDisposeStreamProvider<String?> {
  /// See also [racialCantripOverride].
  RacialCantripOverrideProvider(
    int characterId,
  ) : this._internal(
          (ref) => racialCantripOverride(
            ref as RacialCantripOverrideRef,
            characterId,
          ),
          from: racialCantripOverrideProvider,
          name: r'racialCantripOverrideProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$racialCantripOverrideHash,
          dependencies: RacialCantripOverrideFamily._dependencies,
          allTransitiveDependencies:
              RacialCantripOverrideFamily._allTransitiveDependencies,
          characterId: characterId,
        );

  RacialCantripOverrideProvider._internal(
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
    Stream<String?> Function(RacialCantripOverrideRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RacialCantripOverrideProvider._internal(
        (ref) => create(ref as RacialCantripOverrideRef),
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
  AutoDisposeStreamProviderElement<String?> createElement() {
    return _RacialCantripOverrideProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RacialCantripOverrideProvider &&
        other.characterId == characterId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, characterId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin RacialCantripOverrideRef on AutoDisposeStreamProviderRef<String?> {
  /// The parameter `characterId` of this provider.
  int get characterId;
}

class _RacialCantripOverrideProviderElement
    extends AutoDisposeStreamProviderElement<String?>
    with RacialCantripOverrideRef {
  _RacialCantripOverrideProviderElement(super.provider);

  @override
  int get characterId => (origin as RacialCantripOverrideProvider).characterId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
