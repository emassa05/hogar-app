part of 'catalog_repository_impl.dart';

String _$catalogRepositoryHash() => r'c99518c84184ac24f3a77dbf99949ef91835f356';

@ProviderFor(catalogRepository)
final catalogRepositoryProvider = Provider<CatalogRepository>.internal(
  catalogRepository,
  name: r'catalogRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$catalogRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
typedef CatalogRepositoryRef = ProviderRef<CatalogRepository>;
