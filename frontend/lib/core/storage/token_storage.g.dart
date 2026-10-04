part of 'token_storage.dart';

String _$tokenStorageHash() => r'b1d6c8bc15ddc53b621d238093321e8a28e153d4';

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
