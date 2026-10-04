part of 'app_router.dart';

String _$appRouterHash() => r'65bf840d2a4d67183e853fc04fb303dbd45b72e0';

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
