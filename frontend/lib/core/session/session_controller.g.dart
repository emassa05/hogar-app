part of 'session_controller.dart';

String _$sessionControllerHash() => r'78d47b9564beeff6dba3064317ab93d0a6716c20';

@ProviderFor(SessionController)
final sessionControllerProvider =
    NotifierProvider<SessionController, SessionState>.internal(
      SessionController.new,
      name: r'sessionControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$sessionControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SessionController = Notifier<SessionState>;
