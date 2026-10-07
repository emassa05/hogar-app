part of 'app_router.dart';

String _$appRouterHash() => r'819f4c47960c3122beca0fa8e315f7ff275faed2';

@ProviderFor(appRouter)
final appRouterProvider = Provider<GoRouter>.internal(
  appRouter,
  name: r'appRouterProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appRouterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
typedef AppRouterRef = ProviderRef<GoRouter>;
