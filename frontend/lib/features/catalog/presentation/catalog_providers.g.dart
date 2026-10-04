part of 'catalog_providers.dart';

String _$taskCategoriesHash() => r'2af25e27e3a07a5937ce3816d8c1270fe803a88b';

@ProviderFor(taskCategories)
final taskCategoriesProvider = FutureProvider<List<TaskCategory>>.internal(
  taskCategories,
  name: r'taskCategoriesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$taskCategoriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
typedef TaskCategoriesRef = FutureProviderRef<List<TaskCategory>>;
String _$activitiesHash() => r'344b7e3e0aff88d0c56b425b76cc77eed76728d6';

@ProviderFor(activities)
final activitiesProvider = FutureProvider<List<Activity>>.internal(
  activities,
  name: r'activitiesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activitiesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
typedef ActivitiesRef = FutureProviderRef<List<Activity>>;
