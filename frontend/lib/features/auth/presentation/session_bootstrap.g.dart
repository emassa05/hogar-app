part of 'session_bootstrap.dart';

String _$sessionBootstrapHash() => r'7c075c3e808a20dbb51f8771857d6c4966a7a178';

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
