part of 'dio_client.dart';

String _$dioClientHash() => r'b8e7f304860744012bc56a70cc069a55fe9b1ea4';

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
