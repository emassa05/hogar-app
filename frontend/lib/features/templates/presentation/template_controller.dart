import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/errors/api_error_code.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/network/request_options.dart';
import '../../../core/result/result.dart';
import '../../../core/result/result_value.dart';
import '../../../core/session/session_controller.dart';
import '../../../core/session/session_operation.dart';
import '../../households/data/household_repository_impl.dart';
import '../../households/domain/household_entities.dart';
import '../../households/presentation/household_controller.dart';
import '../data/template_repository_impl.dart';
import '../domain/template_entities.dart';
import 'template_selection_state.dart';
part 'template_controller.g.dart';

@riverpod
class TemplateController extends _$TemplateController {
  bool _alive = true;
  int _revision = 0;
  IdempotentAction? _action;
  String? _signature;
  @override
  Future<TemplateSelectionState> build(String householdId) async {
    _alive = true;
    _revision++;
    ref.onDispose(() {
      _alive = false;
      _revision++;
    });
    final userId = ref.watch(
      sessionControllerProvider.select((value) => value.user?.id),
    );
    if (userId == null) throw const UnauthenticatedException();
    final households = ref.watch(householdRepositoryProvider);
    final repository = ref.watch(templateRepositoryProvider);
    final revision = _revision;
    final household = (await households.detail(householdId)).valueOrThrow;
    if (household.myRole != MemberRole.admin) {
      throw ApiException(statusCode: 403, code: ApiErrorCode.adminRequired);
    }
    if (household.templatesApplied) {
      final application = (await repository.application(
        householdId,
      )).valueOrThrow;
      return TemplateSelectionState(
        templates: const [],
        details: const {},
        application: application,
      );
    }
    final templates = (await repository.list()).valueOrThrow;
    final details = await Future.wait(
      templates.map(
        (template) async =>
            (await repository.detail(template.key)).valueOrThrow,
      ),
    );
    if (!_alive || revision != _revision) {
      throw const NetworkException(NetworkFailure.cancelled);
    }
    return TemplateSelectionState(
      templates: templates,
      details: {for (final detail in details) detail.key: detail},
    );
  }

  void clearError() {
    final current = state.valueOrNull;
    if (current != null && !current.busy) {
      state = AsyncData(current.copyWith(error: null));
    }
  }

  void toggle(String key) {
    final current = state.valueOrNull;
    if (current == null ||
        current.busy ||
        current.application != null ||
        !current.templates.any((template) => template.key == key)) {
      return;
    }
    final selected = current.selected.toSet();
    if (!selected.add(key)) selected.remove(key);
    state = AsyncData(current.copyWith(selected: selected, error: null));
  }

  Future<bool> apply({bool empty = false}) async {
    final current = state.valueOrNull;
    if (!_alive ||
        current == null ||
        current.busy ||
        current.application != null ||
        (current.blockedUntil?.isAfter(DateTime.now().toUtc()) ?? false) ||
        !ref.read(sessionControllerProvider).isAuthenticated) {
      return false;
    }
    final keys = empty ? <String>[] : (current.selected.toList()..sort());
    if (!empty && keys.isEmpty) return false;
    final signature = keys.join(',');
    if (signature != _signature) {
      _signature = signature;
      _action = IdempotentAction();
    }
    final revision = _revision;
    final operation = SessionOperation(
      ref.read(sessionControllerProvider.notifier),
      isAlive: () => _alive && revision == _revision,
    );
    final repository = ref.read(templateRepositoryProvider);
    state = AsyncData(current.copyWith(busy: true, error: null));
    var result = await repository.apply(householdId, keys, _action!.key);
    if (!operation.isCurrent) return false;
    if (result case Failure<TemplateApplication>(
      error: ApiException(code: ApiErrorCode.templatesAlreadyApplied),
    )) {
      result = await repository.application(householdId);
    }
    if (!operation.isCurrent) return false;
    switch (result) {
      case Success<TemplateApplication>(:final value):
        state = AsyncData(
          state.requireValue.copyWith(busy: false, application: value),
        );
        ref.invalidate(activeHouseholdProvider);
        return true;
      case Failure<TemplateApplication>(:final error):
        state = AsyncData(
          state.requireValue.copyWith(
            busy: false,
            error: error,
            blockedUntil:
                error is ApiException && error.retryAfterSeconds != null
                ? DateTime.now().toUtc().add(
                    Duration(seconds: error.retryAfterSeconds!),
                  )
                : current.blockedUntil,
          ),
        );
        return false;
    }
  }
}
