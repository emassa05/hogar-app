part of 'session_bootstrap.dart';

String _$sessionBootstrapHash() => r'250c2350bd447148a1b1b82b5f7abb65eeea1e22';

@ProviderFor(sessionBootstrap)
final sessionBootstrapProvider = FutureProvider<void>.internal(
  sessionBootstrap,
  name: r'sessionBootstrapProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sessionBootstrapHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
typedef SessionBootstrapRef = FutureProviderRef<void>;
