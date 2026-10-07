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
import '../../profile/data/profile_repository_impl.dart';
import '../../profile/presentation/member_profile_provider.dart';
import '../../profile/presentation/profile_controller.dart';
import '../data/capacity_repository_impl.dart';
import 'capacity_state.dart';
import 'capacity_strings.dart';

part 'capacity_controller.g.dart';

@riverpod
class CapacityController extends _$CapacityController {
  bool _alive = true;
  int _revision = 0;
  IdempotentAction? _approval;
  Map<String, int>? _approvalPayload;

  @override
  Future<CapacityState> build(String householdId) async {
    _alive = true;
    final revision = ++_revision;
    _approval = null;
    _approvalPayload = null;
    ref.onDispose(() {
      _alive = false;
      _revision++;
    });
    final session = ref.watch(sessionControllerProvider);
    if (!session.isAuthenticated) throw const UnauthenticatedException();
    if (session.user?.activeHouseholdId != householdId) {
      throw const NetworkException(NetworkFailure.cancelled);
    }
    final operation = SessionOperation(
      ref.read(sessionControllerProvider.notifier),
      isAlive: () => _alive && revision == _revision,
    );
    final householdRepository = ref.watch(householdRepositoryProvider);
    final capacityRepository = ref.watch(capacityRepositoryProvider);
    final household = (await householdRepository.detail(
      householdId,
    )).valueOrThrow;
    operation.checkCurrent();
    final overview = (await capacityRepository.overview(
      householdId,
    )).valueOrThrow;
    operation.checkCurrent();
    return CapacityState(overview: overview, role: household.myRole);
  }

  Future<bool> _run(
    Future<void> Function(SessionOperation operation) action, {
    bool preserveConfirmation = false,
  }) async {
    final current = state.valueOrNull;
    if (!_alive ||
        state.isLoading ||
        state.hasError ||
        current == null ||
        current.busy ||
        (current.blockedUntil?.isAfter(DateTime.now().toUtc()) ?? false) ||
        ref.read(sessionControllerProvider).user?.activeHouseholdId !=
            householdId) {
      return false;
    }
    final revision = _revision;
    final operation = SessionOperation(
      ref.read(sessionControllerProvider.notifier),
      isAlive: () => _alive && revision == _revision,
    );
    state = AsyncData(
      current.copyWith(
        busy: true,
        error: null,
        savedPart: preserveConfirmation ? current.savedPart : '',
      ),
    );
    final result = await capture(() => action(operation));
    if (!operation.isCurrent) return false;
    if (result case Failure<void>(:final error)) {
      state = AsyncData(
        state.requireValue.copyWith(
          busy: false,
          error: error,
          blockedUntil: error is ApiException && error.retryAfterSeconds != null
              ? DateTime.now().toUtc().add(
                  Duration(seconds: error.retryAfterSeconds!),
                )
              : current.blockedUntil,
        ),
      );
      return false;
    }
    state = AsyncData(state.requireValue.copyWith(busy: false));
    return true;
  }

  Future<void> _reload(SessionOperation operation) async {
    final household =
        (await ref.read(householdRepositoryProvider).detail(householdId))
            .valueOrThrow;
    operation.checkCurrent();
    final overview =
        (await ref.read(capacityRepositoryProvider).overview(householdId))
            .valueOrThrow;
    operation.checkCurrent();
    state = AsyncData(
      state.requireValue.copyWith(overview: overview, role: household.myRole),
    );
  }

  Future<bool> reload() => _run(_reload, preserveConfirmation: true);

  Future<bool> saveProposal(int percent) => _run((operation) async {
    if (percent < 0 || percent > 100) {
      throw const UnexpectedException();
    }
    final profile =
        (await ref
                .read(profileRepositoryProvider)
                .updateCapacity(householdId, percent))
            .valueOrThrow;
    operation.checkCurrent();
    final current = state.requireValue;
    if (!profile.isMe ||
        profile.userId != ref.read(sessionControllerProvider).user?.id) {
      throw const UnexpectedException();
    }
    state = AsyncData(
      current.copyWith(
        overview: current.overview.copyWith(
          proposals: [
            for (final proposal in current.overview.proposals)
              if (proposal.member.userId == profile.userId)
                proposal.copyWith(
                  proposedCapacityPercent: profile.proposedCapacityPercent,
                )
              else
                proposal,
          ],
        ),
        savedPart: CapacityStrings.proposalSaved,
      ),
    );
    ref.invalidate(memberProfileProvider);
    ref.invalidate(profileControllerProvider(householdId));
  });

  Future<bool> approve(Map<String, int> allocations) {
    final current = state.valueOrNull;
    if (current == null ||
        state.isLoading ||
        state.hasError ||
        current.busy ||
        current.role != MemberRole.admin ||
        allocations.isEmpty ||
        allocations.values.any((value) => value < 0 || value > 100) ||
        allocations.values.fold(0, (sum, value) => sum + value) != 100 ||
        allocations.length != current.overview.proposals.length ||
        current.overview.proposals.any(
          (item) => !allocations.containsKey(item.member.userId),
        )) {
      return Future.value(false);
    }
    final same =
        _approvalPayload != null &&
        _approvalPayload!.length == allocations.length &&
        allocations.entries.every(
          (item) => _approvalPayload![item.key] == item.value,
        );
    if (!same) {
      _approval = IdempotentAction();
      _approvalPayload = Map.unmodifiable(allocations);
    }
    final payload = _approvalPayload!;
    final key = _approval!.key;
    return _run((operation) async {
      final result = await ref
          .read(capacityRepositoryProvider)
          .approve(householdId, payload, key);
      operation.checkCurrent();
      if (result case Failure(:final error)) {
        if (error is ApiException &&
            (error.code == ApiErrorCode.capacitySumInvalid ||
                error.code == ApiErrorCode.adminRequired ||
                error.code == ApiErrorCode.versionConflict)) {
          await capture(() => _reload(operation));
          operation.checkCurrent();
        }
      }
      final approved = result.valueOrThrow;
      _approval = null;
      _approvalPayload = null;
      state = AsyncData(
        state.requireValue.copyWith(
          overview: state.requireValue.overview.copyWith(upcoming: approved),
          savedPart:
              '${CapacityStrings.approvalSaved} ${CapacityStrings.effective(approved.effectiveFrom)}',
          history: [],
          historyLoaded: false,
          nextCursor: null,
        ),
      );
      await _reload(operation);
    });
  }

  Future<bool> loadHistory() => _run((operation) async {
    final current = state.requireValue;
    final page =
        (await ref
                .read(capacityRepositoryProvider)
                .history(
                  householdId,
                  cursor: current.historyLoaded ? current.nextCursor : null,
                ))
            .valueOrThrow;
    operation.checkCurrent();
    state = AsyncData(
      state.requireValue.copyWith(
        historyLoaded: true,
        nextCursor: page.nextCursor,
        history: [
          ...current.history,
          ...page.items.where(
            (item) => !current.history.any((old) => old.id == item.id),
          ),
        ],
      ),
    );
  });
}
