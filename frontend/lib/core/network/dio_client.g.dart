part of 'dio_client.dart';

String _$dioClientHash() => r'a2701c840fe751ca06c46b92154588f7c8c84a00';

@ProviderFor(dioClient)
final dioClientProvider = Provider<Dio>.internal(
  dioClient,
  name: r'dioClientProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dioClientHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
typedef DioClientRef = ProviderRef<Dio>;
