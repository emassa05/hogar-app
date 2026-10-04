part of 'token_storage.dart';

String _$tokenStorageHash() => r'9bf31c7d16f31bd343c659404a93bce78f1d6a2f';

@ProviderFor(tokenStorage)
final tokenStorageProvider = Provider<TokenStorage>.internal(
  tokenStorage,
  name: r'tokenStorageProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tokenStorageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
typedef TokenStorageRef = ProviderRef<TokenStorage>;
