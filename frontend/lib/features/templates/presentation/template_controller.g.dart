part of 'template_controller.dart';

String _$templateControllerHash() =>
    r'2f05518027d3eb4297febb6d951b5b724ac4bb4c';

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

abstract class _$TemplateController
    extends BuildlessAutoDisposeAsyncNotifier<TemplateSelectionState> {
  late final String householdId;

  FutureOr<TemplateSelectionState> build(String householdId);
}

@ProviderFor(TemplateController)
const templateControllerProvider = TemplateControllerFamily();

class TemplateControllerFamily
    extends Family<AsyncValue<TemplateSelectionState>> {
  const TemplateControllerFamily();

  TemplateControllerProvider call(String householdId) {
    return TemplateControllerProvider(householdId);
  }

  @override
  TemplateControllerProvider getProviderOverride(
    covariant TemplateControllerProvider provider,
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
  String? get name => r'templateControllerProvider';
}

class TemplateControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          TemplateController,
          TemplateSelectionState
        > {
  TemplateControllerProvider(String householdId)
    : this._internal(
        () => TemplateController()..householdId = householdId,
        from: templateControllerProvider,
        name: r'templateControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$templateControllerHash,
        dependencies: TemplateControllerFamily._dependencies,
        allTransitiveDependencies:
            TemplateControllerFamily._allTransitiveDependencies,
        householdId: householdId,
      );

  TemplateControllerProvider._internal(
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
  FutureOr<TemplateSelectionState> runNotifierBuild(
    covariant TemplateController notifier,
  ) {
    return notifier.build(householdId);
  }

  @override
  Override overrideWith(TemplateController Function() create) {
    return ProviderOverride(
      origin: this,
      override: TemplateControllerProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<
    TemplateController,
    TemplateSelectionState
  >
  createElement() {
    return _TemplateControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TemplateControllerProvider &&
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
mixin TemplateControllerRef
    on AutoDisposeAsyncNotifierProviderRef<TemplateSelectionState> {
  String get householdId;
}

class _TemplateControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          TemplateController,
          TemplateSelectionState
        >
    with TemplateControllerRef {
  _TemplateControllerProviderElement(super.provider);

  @override
  String get householdId => (origin as TemplateControllerProvider).householdId;
}
