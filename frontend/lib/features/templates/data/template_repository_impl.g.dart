part of 'template_repository_impl.dart';

String _$templateRepositoryHash() =>
    r'186ecd290b78062ae899259eb8caf5aa4ad87b70';

@ProviderFor(templateRepository)
final templateRepositoryProvider = Provider<TemplateRepository>.internal(
  templateRepository,
  name: r'templateRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$templateRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
typedef TemplateRepositoryRef = ProviderRef<TemplateRepository>;
