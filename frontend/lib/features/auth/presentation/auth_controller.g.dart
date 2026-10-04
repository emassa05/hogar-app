part of 'auth_controller.dart';

String _$authControllerHash() => r'd508378b225047d74711e35598e386359f7ad842';

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
