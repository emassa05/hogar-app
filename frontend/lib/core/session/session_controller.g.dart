part of 'session_controller.dart';

String _$sessionControllerHash() => r'd35b7c93e849f13aebab92b0be623a3720bf337e';

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
