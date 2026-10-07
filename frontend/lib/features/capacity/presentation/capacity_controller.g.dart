part of 'capacity_controller.dart';

String _$capacityControllerHash() =>
    r'9ad0c42ddfa78586c6f488a13fd1dde6a3c3a251';

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

abstract class _$CapacityController
    extends BuildlessAutoDisposeAsyncNotifier<CapacityState> {
  late final String householdId;

  FutureOr<CapacityState> build(String householdId);
}

@ProviderFor(CapacityController)
const capacityControllerProvider = CapacityControllerFamily();

class CapacityControllerFamily extends Family<AsyncValue<CapacityState>> {
  const CapacityControllerFamily();

  CapacityControllerProvider call(String householdId) {
    return CapacityControllerProvider(householdId);
  }

  @override
  CapacityControllerProvider getProviderOverride(
    covariant CapacityControllerProvider provider,
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
  String? get name => r'capacityControllerProvider';
}

class CapacityControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          CapacityController,
          CapacityState
        > {
  CapacityControllerProvider(String householdId)
    : this._internal(
        () => CapacityController()..householdId = householdId,
        from: capacityControllerProvider,
        name: r'capacityControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$capacityControllerHash,
        dependencies: CapacityControllerFamily._dependencies,
        allTransitiveDependencies:
            CapacityControllerFamily._allTransitiveDependencies,
        householdId: householdId,
      );

  CapacityControllerProvider._internal(
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
  FutureOr<CapacityState> runNotifierBuild(
    covariant CapacityController notifier,
  ) {
    return notifier.build(householdId);
  }

  @override
  Override overrideWith(CapacityController Function() create) {
    return ProviderOverride(
      origin: this,
      override: CapacityControllerProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<CapacityController, CapacityState>
  createElement() {
    return _CapacityControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CapacityControllerProvider &&
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
mixin CapacityControllerRef
    on AutoDisposeAsyncNotifierProviderRef<CapacityState> {
  String get householdId;
}

class _CapacityControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          CapacityController,
          CapacityState
        >
    with CapacityControllerRef {
  _CapacityControllerProviderElement(super.provider);

  @override
  String get householdId => (origin as CapacityControllerProvider).householdId;
}
