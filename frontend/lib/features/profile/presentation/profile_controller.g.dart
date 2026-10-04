part of 'profile_controller.dart';

String _$profileControllerHash() => r'a04ea6b0b43268e9878b77e062136fcd9978435c';

class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    hash = 0x1fffffff & (hash + value);
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$ProfileController
    extends BuildlessAutoDisposeAsyncNotifier<ProfileViewState> {
  late final String householdId;

  FutureOr<ProfileViewState> build(String householdId);
}

@ProviderFor(ProfileController)
const profileControllerProvider = ProfileControllerFamily();

class ProfileControllerFamily extends Family<AsyncValue<ProfileViewState>> {
  const ProfileControllerFamily();

  ProfileControllerProvider call(String householdId) {
    return ProfileControllerProvider(householdId);
  }

  @override
  ProfileControllerProvider getProviderOverride(
    covariant ProfileControllerProvider provider,
  ) {
    return call(provider.householdId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'profileControllerProvider';
}

class ProfileControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          ProfileController,
          ProfileViewState
        > {
  ProfileControllerProvider(String householdId)
    : this._internal(
        () => ProfileController()..householdId = householdId,
        from: profileControllerProvider,
        name: r'profileControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$profileControllerHash,
        dependencies: ProfileControllerFamily._dependencies,
        allTransitiveDependencies:
            ProfileControllerFamily._allTransitiveDependencies,
        householdId: householdId,
      );

  ProfileControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.householdId,
  }) : super.internal();

  final String householdId;

  @override
  FutureOr<ProfileViewState> runNotifierBuild(
    covariant ProfileController notifier,
  ) {
    return notifier.build(householdId);
  }

  @override
  Override overrideWith(ProfileController Function() create) {
    return ProviderOverride(
      origin: this,
      override: ProfileControllerProvider._internal(
        () => create()..householdId = householdId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        householdId: householdId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ProfileController, ProfileViewState>
  createElement() {
    return _ProfileControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProfileControllerProvider &&
        other.householdId == householdId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, householdId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
mixin ProfileControllerRef
    on AutoDisposeAsyncNotifierProviderRef<ProfileViewState> {
  String get householdId;
}

class _ProfileControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          ProfileController,
          ProfileViewState
        >
    with ProfileControllerRef {
  _ProfileControllerProviderElement(super.provider);

  @override
  String get householdId => (origin as ProfileControllerProvider).householdId;
}
