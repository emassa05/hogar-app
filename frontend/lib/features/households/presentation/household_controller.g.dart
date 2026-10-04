part of 'household_controller.dart';

String _$householdListHash() => r'a056a108ad12f48c25230553993566f6f820c264';

@ProviderFor(householdList)
final householdListProvider =
    AutoDisposeFutureProvider<List<HouseholdSummary>>.internal(
      householdList,
      name: r'householdListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$householdListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
typedef HouseholdListRef = AutoDisposeFutureProviderRef<List<HouseholdSummary>>;
String _$activeHouseholdHash() => r'8ac3b03e2c51cb959a666a486dbb841396faa069';

@ProviderFor(activeHousehold)
final activeHouseholdProvider =
    AutoDisposeFutureProvider<HouseholdDetail?>.internal(
      activeHousehold,
      name: r'activeHouseholdProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$activeHouseholdHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
typedef ActiveHouseholdRef = AutoDisposeFutureProviderRef<HouseholdDetail?>;
String _$householdControllerHash() =>
    r'c5fa07a14a0ef02eddbb9d97cc12390585b73e97';

@ProviderFor(HouseholdController)
final householdControllerProvider =
    NotifierProvider<HouseholdController, HouseholdFlowState>.internal(
      HouseholdController.new,
      name: r'householdControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$householdControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$HouseholdController = Notifier<HouseholdFlowState>;
