part of 'app_config.dart';

String _$appConfigHash() => r'c2cf4c47a445e3b4e93b1a993c54fca0f4f12cbb';

@ProviderFor(appConfig)
final appConfigProvider = Provider<AppConfig>.internal(
  appConfig,
  name: r'appConfigProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appConfigHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
typedef AppConfigRef = ProviderRef<AppConfig>;
