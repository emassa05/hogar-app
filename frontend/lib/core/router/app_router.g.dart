part of 'app_router.dart';

String _$appRouterHash() => r'd8b526b713484a781a105699bdeb71890a9678a7';

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
