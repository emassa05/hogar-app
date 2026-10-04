part of 'household_repository_impl.dart';

String _$householdRepositoryHash() =>
    r'80f5eb84026019354885bf96dd90fd019b8ead2c';

@ProviderFor(householdRepository)
final householdRepositoryProvider = Provider<HouseholdRepository>.internal(
  householdRepository,
  name: r'householdRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$householdRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
typedef HouseholdRepositoryRef = ProviderRef<HouseholdRepository>;
