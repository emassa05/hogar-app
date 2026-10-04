part of 'auth_controller.dart';

String _$authControllerHash() => r'bdc8879cba16e964b0619a6ddf0ddb060c756efb';

@ProviderFor(AuthController)
final authControllerProvider =
    NotifierProvider<AuthController, AuthFlowState>.internal(
      AuthController.new,
      name: r'authControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$authControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AuthController = Notifier<AuthFlowState>;
