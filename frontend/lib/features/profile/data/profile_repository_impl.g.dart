part of 'profile_repository_impl.dart';

String _$profileRepositoryHash() => r'21373fe5e8a77457ebc25ac3bfd3791bc172224a';

@ProviderFor(profileRepository)
final profileRepositoryProvider = Provider<ProfileRepository>.internal(
  profileRepository,
  name: r'profileRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$profileRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
typedef ProfileRepositoryRef = ProviderRef<ProfileRepository>;
