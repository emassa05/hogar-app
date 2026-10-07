part of 'capacity_repository_impl.dart';

String _$capacityRepositoryHash() =>
    r'e9dd1d4daddabb1c32ad7aa3d135a7c57900c405';

@ProviderFor(capacityRepository)
final capacityRepositoryProvider = Provider<CapacityRepository>.internal(
  capacityRepository,
  name: r'capacityRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$capacityRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
typedef CapacityRepositoryRef = ProviderRef<CapacityRepository>;
