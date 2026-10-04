part of 'auth_repository_impl.dart';

String _$authRepositoryHash() => r'509396e7cb0d36fb0e808fe7082d69cccab881d7';

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
