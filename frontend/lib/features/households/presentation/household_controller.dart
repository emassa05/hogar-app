import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/errors/api_error_code.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/network/request_options.dart';
import '../../../core/result/result.dart';
import '../../../core/result/result_value.dart';
import '../../../core/session/session_controller.dart';
import '../../../core/session/session_operation.dart';
import '../../../core/validation/validators.dart';
import '../data/household_repository_impl.dart';
import '../domain/household_entities.dart';
import 'household_flow_state.dart';
import 'household_strings.dart';
part 'household_controller.g.dart';

@Riverpod(keepAlive: true)
class HouseholdController extends _$HouseholdController {
  int _revision = 0;
  bool _alive = true;
  IdempotentAction? _creation;
  String? _creationName;
  String? _pendingPreviewCode;
  @override
  HouseholdFlowState build() {
    ref.onDispose(() => _alive = false);
    ref.listen(sessionControllerProvider.select((value) => value.user?.id), (
      previous,
      next,
    ) {
      if (previous != next) reset();
    });
    return const HouseholdFlowState();
  }

  bool get _canStart =>
      _alive &&
      !state.busy &&
      !(state.blockedUntil?.isAfter(DateTime.now().toUtc()) ?? false) &&
      ref.read(sessionControllerProvider).isAuthenticated;
  void reset() {
    _revision++;
    _creation = null;
    _creationName = null;
    _pendingPreviewCode = null;
    state = const HouseholdFlowState();
  }

  void clearError() => state = state.copyWith(error: null);
  void clearPreview() {
    if (state.busy && _pendingPreviewCode == null) return;
    _revision++;
    _pendingPreviewCode = null;
    state = state.copyWith(
      preview: null,
      previewCode: '',
      busy: false,
      error: null,
    );
  }

  void _activate(HouseholdDetail household) {
    final user = ref.read(sessionControllerProvider).user;
    if (user != null) {
      ref
          .read(sessionControllerProvider.notifier)
          .confirmUser(user.copyWith(activeHouseholdId: household.id));
    }
    ref.invalidate(householdListProvider);
    ref.invalidate(activeHouseholdProvider);
  }

  Future<bool> _run(
    Future<void> Function(SessionOperation operation) action,
  ) async {
    if (!_canStart) return false;
    final revision = ++_revision;
    final operation = SessionOperation(
      ref.read(sessionControllerProvider.notifier),
      isAlive: () => _alive && revision == _revision,
    );
    state = state.copyWith(busy: true, error: null, savedPart: '');
    final result = await capture(() => action(operation));
    if (!operation.isCurrent) return false;
    _pendingPreviewCode = null;
    if (result case Failure<void>(:final error)) {
      state = state.copyWith(
        busy: false,
        error: error,
        blockedUntil: error is ApiException && error.retryAfterSeconds != null
            ? DateTime.now().toUtc().add(
                Duration(seconds: error.retryAfterSeconds!),
              )
            : state.blockedUntil,
      );
      return false;
    }
    state = state.copyWith(busy: false, savedPart: '');
    return true;
  }

  Future<bool> create(String name) {
    final normalized = name.trim();
    if (!_canStart || NameValidator.validate(normalized) != null) {
      return Future.value(false);
    }
    if (normalized != _creationName) {
      _creationName = normalized;
      _creation = IdempotentAction();
    }
    final key = _creation!.key;
    return _run((operation) async {
      final household =
          (await ref.read(householdRepositoryProvider).create(normalized, key))
              .valueOrThrow;
      operation.checkCurrent();
      state = state.copyWith(household: household, invitation: null);
      _activate(household);
    });
  }

  Future<bool> load(String id, {bool includeInvitation = true}) =>
      _run((operation) async {
        if (state.household?.id != id) {
          state = state.copyWith(household: null, invitation: null);
        }
        final repository = ref.read(householdRepositoryProvider);
        final household = (await repository.detail(id)).valueOrThrow;
        operation.checkCurrent();
        state = state.copyWith(
          household: household,
          invitation: household.myRole == MemberRole.admin
              ? state.invitation
              : null,
        );
        if (includeInvitation && household.myRole == MemberRole.admin) {
          final invitation = (await repository.invitation(id)).valueOrThrow;
          operation.checkCurrent();
          state = state.copyWith(invitation: invitation);
        }
      });
  Future<bool> regenerate(String id) => _run((operation) async {
    final invitation =
        (await ref.read(householdRepositoryProvider).regenerateInvitation(id))
            .valueOrThrow;
    operation.checkCurrent();
    state = state.copyWith(invitation: invitation);
  });
  Future<bool> refreshConfirmedHousehold(String id) async {
    if (!_canStart ||
        ref.read(sessionControllerProvider).user?.activeHouseholdId != id) {
      return false;
    }
    final userId = ref.read(sessionControllerProvider).user?.id;
    final epoch = ref.read(sessionControllerProvider.notifier).epoch;
    final savedPart = state.savedPart;
    final loaded = await load(id, includeInvitation: false);
    final user = ref.read(sessionControllerProvider).user;
    if (!_alive ||
        state.household?.id != id ||
        user?.id != userId ||
        user?.activeHouseholdId != id ||
        ref.read(sessionControllerProvider.notifier).epoch != epoch) {
      return false;
    }
    if (loaded) {
      ref.invalidate(activeHouseholdProvider);
    } else {
      state = state.copyWith(savedPart: savedPart);
    }
    return loaded;
  }

  Future<bool> preview(String code) {
    if (state.busy && _pendingPreviewCode == null) return Future.value(false);
    clearPreview();
    if (!CodeValidator.isValidInvitation(code) || !_canStart) {
      return Future.value(false);
    }
    final normalized = CodeValidator.displayInvitation(code);
    _pendingPreviewCode = normalized;
    return _run((operation) async {
      final preview =
          (await ref.read(householdRepositoryProvider).preview(normalized))
              .valueOrThrow;
      operation.checkCurrent();
      state = state.copyWith(preview: preview, previewCode: normalized);
    });
  }

  Future<bool> accept() {
    final preview = state.preview;
    final code = state.previewCode;
    if (!_canStart || preview == null) return Future.value(false);
    return _run((operation) async {
      if (!preview.expiresAt.isAfter(DateTime.now().toUtc())) {
        throw ApiException(
          statusCode: 410,
          code: ApiErrorCode.invitationExpired,
        );
      }
      final household =
          (await ref.read(householdRepositoryProvider).accept(code))
              .valueOrThrow;
      operation.checkCurrent();
      state = state.copyWith(
        household: household,
        preview: null,
        invitation: null,
      );
      _activate(household);
    });
  }

  Future<bool> openExisting(String id) => _run((operation) async {
    final repository = ref.read(householdRepositoryProvider);
    final household = (await repository.detail(id)).valueOrThrow;
    operation.checkCurrent();
    final user = (await repository.selectActive(id)).valueOrThrow;
    operation.checkCurrent();
    state = state.copyWith(household: household, invitation: null);
    ref.read(sessionControllerProvider.notifier).confirmUser(user);
    ref.invalidate(householdListProvider);
    ref.invalidate(activeHouseholdProvider);
  });
  Future<bool> changeRole(String id, String userId, MemberRole role) => _run((
    operation,
  ) async {
    final repository = ref.read(householdRepositoryProvider);
    final member = (await repository.changeRole(id, userId, role)).valueOrThrow;
    operation.checkCurrent();
    final current = state.household;
    if (current?.id == id) {
      state = state.copyWith(
        household: current!.copyWith(
          members: current.members
              .map((value) => value.userId == userId ? member : value)
              .toList(),
          myRole: member.isMe ? member.role : current.myRole,
        ),
      );
    }
    state = state.copyWith(savedPart: HouseholdStrings.memberRoleSaved);
    final household = (await repository.detail(id)).valueOrThrow;
    operation.checkCurrent();
    state = state.copyWith(
      household: household,
      invitation: household.myRole == MemberRole.admin
          ? state.invitation
          : null,
    );
    ref.invalidate(householdListProvider);
    ref.invalidate(activeHouseholdProvider);
  });
  Future<bool> removeMember(String id, String userId) =>
      _run((operation) async {
        final repository = ref.read(householdRepositoryProvider);
        (await repository.removeMember(id, userId)).valueOrThrow;
        operation.checkCurrent();
        final current = state.household;
        if (current?.id == id) {
          state = state.copyWith(
            household: current!.copyWith(
              members: current.members
                  .where((value) => value.userId != userId)
                  .toList(),
            ),
          );
        }
        state = state.copyWith(savedPart: HouseholdStrings.memberRemoved);
        final household = (await repository.detail(id)).valueOrThrow;
        operation.checkCurrent();
        state = state.copyWith(household: household);
        ref.invalidate(householdListProvider);
        ref.invalidate(activeHouseholdProvider);
      });
  Future<bool> rename(String id, int version, String name) {
    if (NameValidator.validate(name) != null) return Future.value(false);
    return _run((operation) async {
      final repository = ref.read(householdRepositoryProvider);
      final result = await repository.update(id, version, name.trim());
      operation.checkCurrent();
      if (result case Failure<HouseholdDetail>(
        error: ApiException(code: ApiErrorCode.versionConflict),
      )) {
        final reload = await repository.detail(id);
        operation.checkCurrent();
        if (reload case Success<HouseholdDetail>(:final value)) {
          state = state.copyWith(
            household: value,
            savedPart: HouseholdStrings.currentVersionLoaded,
          );
        } else {
          state = state.copyWith(
            savedPart: HouseholdStrings.currentVersionUnavailable,
          );
        }
      }
      state = state.copyWith(household: result.valueOrThrow);
      ref.invalidate(householdListProvider);
      ref.invalidate(activeHouseholdProvider);
    });
  }
}

@riverpod
Future<List<HouseholdSummary>> householdList(Ref ref) async {
  final userId = ref.watch(
    sessionControllerProvider.select((value) => value.user?.id),
  );
  if (userId == null) throw const UnauthenticatedException();
  return (await ref.watch(householdRepositoryProvider).list()).valueOrThrow;
}

@riverpod
Future<HouseholdDetail?> activeHousehold(Ref ref) async {
  final (userId, id) = ref.watch(
    sessionControllerProvider.select(
      (value) => (value.user?.id, value.user?.activeHouseholdId),
    ),
  );
  if (userId == null || id == null) return null;
  return (await ref.watch(householdRepositoryProvider).detail(id)).valueOrThrow;
}
