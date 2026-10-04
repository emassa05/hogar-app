part of 'app_router.dart';

String _$appRouterHash() => r'd54c5741c7f8b5c942dbb4251ad25721dcde4fd8';

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
