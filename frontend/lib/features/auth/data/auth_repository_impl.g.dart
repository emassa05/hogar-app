part of 'auth_repository_impl.dart';

String _$authRepositoryHash() => r'5c635a38edd6f726561cacb0367ee557784ed51e';

@ProviderFor(authRepository)
final authRepositoryProvider = Provider<AuthRepository>.internal(
  authRepository,
  name: r'authRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
typedef AuthRepositoryRef = ProviderRef<AuthRepository>;
