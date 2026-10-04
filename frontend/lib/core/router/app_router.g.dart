part of 'app_router.dart';

String _$appRouterHash() => r'3f282cfcd8682602a5853c09fc4830a9701d7567';

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
