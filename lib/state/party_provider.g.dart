// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'party_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$partyMembersHash() => r'7afe60d65080c53b79d36e004f8c7f291a9fb164';

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

/// See also [partyMembers].
@ProviderFor(partyMembers)
const partyMembersProvider = PartyMembersFamily();

/// See also [partyMembers].
class PartyMembersFamily extends Family<AsyncValue<List<PartyMember>>> {
  /// See also [partyMembers].
  const PartyMembersFamily();

  /// See also [partyMembers].
  PartyMembersProvider call(
    int characterId,
  ) {
    return PartyMembersProvider(
      characterId,
    );
  }

  @override
  PartyMembersProvider getProviderOverride(
    covariant PartyMembersProvider provider,
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
  String? get name => r'partyMembersProvider';
}

/// See also [partyMembers].
class PartyMembersProvider
    extends AutoDisposeStreamProvider<List<PartyMember>> {
  /// See also [partyMembers].
  PartyMembersProvider(
    int characterId,
  ) : this._internal(
          (ref) => partyMembers(
            ref as PartyMembersRef,
            characterId,
          ),
          from: partyMembersProvider,
          name: r'partyMembersProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$partyMembersHash,
          dependencies: PartyMembersFamily._dependencies,
          allTransitiveDependencies:
              PartyMembersFamily._allTransitiveDependencies,
          characterId: characterId,
        );

  PartyMembersProvider._internal(
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
    Stream<List<PartyMember>> Function(PartyMembersRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PartyMembersProvider._internal(
        (ref) => create(ref as PartyMembersRef),
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
  AutoDisposeStreamProviderElement<List<PartyMember>> createElement() {
    return _PartyMembersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PartyMembersProvider && other.characterId == characterId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, characterId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PartyMembersRef on AutoDisposeStreamProviderRef<List<PartyMember>> {
  /// The parameter `characterId` of this provider.
  int get characterId;
}

class _PartyMembersProviderElement
    extends AutoDisposeStreamProviderElement<List<PartyMember>>
    with PartyMembersRef {
  _PartyMembersProviderElement(super.provider);

  @override
  int get characterId => (origin as PartyMembersProvider).characterId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
