import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/errors/api_error_code.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/result/result.dart';
import '../../../core/result/result_value.dart';
import '../../../core/session/session_controller.dart';
import '../../../core/session/session_operation.dart';
import '../../../core/session/session_user.dart';
import '../../auth/data/auth_repository_impl.dart';
import '../../households/presentation/household_strings.dart';
import '../data/profile_repository_impl.dart';
import '../domain/profile_entities.dart';
import '../domain/profile_repository.dart';
import 'profile_view_state.dart';
part 'profile_controller.g.dart';

@riverpod
class ProfileController extends _$ProfileController {
  bool _alive = true;
  int _revision = 0;
  String? _uncertainRestriction;
  Set<String> _knownRestrictionIds = {};
  @override
  Future<ProfileViewState> build(String householdId) async {
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
    final repository = ref.watch(profileRepositoryProvider);
    final revision = _revision;
    final profile = (await repository.profile(householdId)).valueOrThrow;
    if (!_alive || revision != _revision) {
      throw const NetworkException(NetworkFailure.cancelled);
    }
    return ProfileViewState(profile: profile);
  }

  void clearError() {
    final current = state.valueOrNull;
    if (current != null && !current.busy) {
      state = AsyncData(current.copyWith(error: null));
    }
  }

  Future<bool> _run(
    Future<void> Function(SessionOperation operation) action,
  ) async {
    final current = state.valueOrNull;
    if (!_alive ||
        current == null ||
        current.busy ||
        (current.blockedUntil?.isAfter(DateTime.now().toUtc()) ?? false) ||
        !ref.read(sessionControllerProvider).isAuthenticated) {
      return false;
    }
    final revision = _revision;
    final operation = SessionOperation(
      ref.read(sessionControllerProvider.notifier),
      isAlive: () => _alive && revision == _revision,
    );
    state = AsyncData(current.copyWith(busy: true, error: null, savedPart: ''));
    final result = await capture(() => action(operation));
    if (!operation.isCurrent) return false;
    final updated = state.requireValue;
    if (result case Failure<void>(:final error)) {
      state = AsyncData(
        updated.copyWith(
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
    state = AsyncData(updated.copyWith(busy: false, savedPart: ''));
    return true;
  }

  void _confirm(
    SessionOperation operation,
    MemberProfile profile, {
    String savedPart = '',
  }) {
    operation.checkCurrent();
    state = AsyncData(
      state.requireValue.copyWith(profile: profile, savedPart: savedPart),
    );
  }

  Future<void> _reload(SessionOperation operation) async {
    final profile =
        (await ref.read(profileRepositoryProvider).profile(householdId))
            .valueOrThrow;
    _confirm(operation, profile);
  }

  Future<bool> reload() => _run(_reload);
  Future<bool> saveProfile(
    String? nickname,
    int? capacity,
    AvatarChoice? avatar,
  ) => _run((operation) async {
    final user = ref.read(sessionControllerProvider).user;
    if (user != null && user.avatar != avatar) {
      final updated =
          (await ref.read(authRepositoryProvider).updateAvatar(avatar))
              .valueOrThrow;
      operation.checkCurrent();
      ref.read(sessionControllerProvider.notifier).confirmUser(updated);
      _confirm(
        operation,
        state.requireValue.profile.copyWith(avatar: updated.avatar),
        savedPart: HouseholdStrings.avatarSaved,
      );
    }
    final normalized = nickname?.trim();
    final profile =
        (await ref
                .read(profileRepositoryProvider)
                .update(
                  householdId,
                  normalized == null || normalized.isEmpty ? null : normalized,
                  capacity,
                ))
            .valueOrThrow;
    _confirm(operation, profile);
  });
  Future<bool> saveAvailability(Availability value) => _run((operation) async {
    final availability =
        (await ref
                .read(profileRepositoryProvider)
                .availability(householdId, value))
            .valueOrThrow;
    _confirm(
      operation,
      state.requireValue.profile.copyWith(availability: availability),
    );
  });
  String _fingerprint(RestrictionInput input) =>
      '${input.target.type.name}:${input.target.key}:${input.kind.name}:${input.startsOn}:${input.endsOn}';
  bool _matches(Restriction restriction, RestrictionInput input) =>
      restriction.target == input.target &&
      restriction.kind == input.kind &&
      (input.startsOn == null || restriction.startsOn == input.startsOn) &&
      restriction.endsOn ==
          (input.kind == RestrictionKind.permanent ? null : input.endsOn);
  Future<bool> addRestriction(RestrictionInput input) => _run((
    operation,
  ) async {
    final fingerprint = _fingerprint(input);
    if (_uncertainRestriction == fingerprint) {
      await _reload(operation);
      final existing = state.requireValue.profile.restrictions.where(
        (restriction) =>
            !_knownRestrictionIds.contains(restriction.id) &&
            _matches(restriction, input),
      );
      if (existing.isNotEmpty) {
        _uncertainRestriction = null;
        return;
      }
    }
    final knownIds = state.requireValue.profile.restrictions
        .map((restriction) => restriction.id)
        .toSet();
    final result = await ref
        .read(profileRepositoryProvider)
        .addRestriction(householdId, input);
    operation.checkCurrent();
    if (result case Failure<Restriction>(error: NetworkException())) {
      _uncertainRestriction = fingerprint;
      _knownRestrictionIds = knownIds;
    }
    final restriction = result.valueOrThrow;
    _uncertainRestriction = null;
    final profile = state.requireValue.profile;
    _confirm(
      operation,
      profile.copyWith(restrictions: [...profile.restrictions, restriction]),
    );
  });
  Future<bool> editRestriction(String id, RestrictionInput input) =>
      _run((operation) async {
        final restriction =
            (await ref
                    .read(profileRepositoryProvider)
                    .editRestriction(householdId, id, input))
                .valueOrThrow;
        operation.checkCurrent();
        final profile = state.requireValue.profile;
        _confirm(
          operation,
          profile.copyWith(
            restrictions: [
              for (final current in profile.restrictions)
                if (current.id == id) restriction else current,
            ],
          ),
        );
      });
  Future<bool> removeRestriction(String id) => _run((operation) async {
    (await ref
            .read(profileRepositoryProvider)
            .removeRestriction(householdId, id))
        .valueOrThrow;
    operation.checkCurrent();
    final profile = state.requireValue.profile;
    _confirm(
      operation,
      profile.copyWith(
        restrictions: profile.restrictions
            .where((restriction) => restriction.id != id)
            .toList(),
      ),
    );
  });
  Future<bool> savePreferences(
    List<String> preferred,
    Set<String> unable,
  ) => _run((operation) async {
    if (preferred.length > 50 ||
        preferred.toSet().length != preferred.length ||
        preferred.any(unable.contains)) {
      throw ApiException(
        statusCode: 422,
        code: ApiErrorCode.validationError,
        details: {
          'fields': [
            {
              'field': 'body.preferred_activity_keys',
              'code': preferred.any(unable.contains)
                  ? 'conflicting_values'
                  : preferred.toSet().length != preferred.length
                  ? 'duplicated'
                  : 'too_long',
            },
          ],
        },
      );
    }
    final repository = ref.read(profileRepositoryProvider);
    await _reload(operation);
    var profile = state.requireValue.profile;
    final current = profile.restrictions
        .where(
          (restriction) =>
              restriction.target.type == RestrictionTargetType.activity &&
              restriction.kind == RestrictionKind.permanent &&
              restriction.isActive,
        )
        .toList();
    final selected = current
        .map((restriction) => restriction.target.key)
        .toSet();
    final toAdd = unable.difference(selected);
    final interim = profile.preferences.preferredActivityKeys
        .where((key) => !toAdd.contains(key))
        .toList();
    if (interim.length != profile.preferences.preferredActivityKeys.length) {
      final preferences = (await repository.preferences(
        householdId,
        interim,
      )).valueOrThrow;
      _confirm(
        operation,
        profile.copyWith(preferences: preferences),
        savedPart: HouseholdStrings.preferencesPartSaved,
      );
    }
    for (final restriction in current.where(
      (value) => !unable.contains(value.target.key),
    )) {
      (await repository.removeRestriction(
        householdId,
        restriction.id,
      )).valueOrThrow;
      operation.checkCurrent();
      profile = state.requireValue.profile;
      _confirm(
        operation,
        profile.copyWith(
          restrictions: profile.restrictions
              .where((value) => value.id != restriction.id)
              .toList(),
        ),
        savedPart: HouseholdStrings.restrictionsPartSaved,
      );
    }
    for (final key in unable) {
      operation.checkCurrent();
      profile = state.requireValue.profile;
      if (profile.restrictions.any(
        (value) =>
            value.target.type == RestrictionTargetType.activity &&
            value.target.key == key &&
            value.kind == RestrictionKind.permanent &&
            value.isActive,
      )) {
        continue;
      }
      final restriction = (await repository.addRestriction(
        householdId,
        RestrictionInput(
          target: RestrictionTarget(
            type: RestrictionTargetType.activity,
            key: key,
          ),
          kind: RestrictionKind.permanent,
        ),
      )).valueOrThrow;
      _confirm(
        operation,
        profile.copyWith(restrictions: [...profile.restrictions, restriction]),
        savedPart: HouseholdStrings.restrictionsPartSaved,
      );
    }
    final preferences = (await repository.preferences(
      householdId,
      preferred,
    )).valueOrThrow;
    _confirm(
      operation,
      state.requireValue.profile.copyWith(preferences: preferences),
    );
  });
}
