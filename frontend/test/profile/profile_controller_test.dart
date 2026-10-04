import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hogar_app/core/errors/api_error_code.dart';
import 'package:hogar_app/core/errors/app_exception.dart';
import 'package:hogar_app/core/session/session_controller.dart';
import 'package:hogar_app/core/session/session_user.dart';
import 'package:hogar_app/features/profile/domain/profile_entities.dart';
import 'package:hogar_app/features/profile/domain/profile_repository.dart';
import 'package:hogar_app/features/profile/presentation/profile_controller.dart';

import '../support/fake_http_adapter.dart';
import '../support/n2_fixtures.dart';
import '../support/n2_harness.dart';

void main() {
  test(
    'profile failure after avatar success reports partial save and retries only the profile',
    () async {
      var avatarPatches = 0;
      var profilePatches = 0;
      final harness = N2Harness((request) async {
        if (request.path == '/users/me') {
          avatarPatches++;
          return jsonResponse(userJson(avatar: 'green'));
        }
        if (request.method == 'PATCH') {
          profilePatches++;
          return profilePatches == 1
              ? apiError('SERVICE_UNAVAILABLE', 503)
              : jsonResponse(
                  profileJson(avatar: 'green')
                    ..['nickname'] = 'Martita'
                    ..['proposed_capacity_percent'] = 30,
                );
        }
        return jsonResponse(profileJson());
      });
      addTearDown(harness.dispose);
      await harness.signIn();
      final provider = profileControllerProvider('household-1');
      final subscription = harness.container.listen(
        provider,
        (previous, next) {},
      );
      addTearDown(subscription.close);
      await harness.container.read(provider.future);
      final controller = harness.container.read(provider.notifier);
      expect(
        await controller.saveProfile(' Martita ', 30, AvatarChoice.green),
        isFalse,
      );
      final partial = harness.container.read(provider).requireValue;
      expect(partial.profile.avatar, AvatarChoice.green);
      expect(partial.profile.nickname, isNull);
      expect(partial.savedPart, contains('personaje ya está guardado'));
      expect(
        harness.container.read(sessionControllerProvider).user!.avatar,
        AvatarChoice.green,
      );
      expect(
        await controller.saveProfile(' Martita ', 30, AvatarChoice.green),
        isTrue,
      );
      expect(avatarPatches, 1);
      expect(profilePatches, 2);
      expect(
        harness.container.read(provider).requireValue.profile.nickname,
        'Martita',
      );
      expect(requestBody(harness.adapter.requests.last)['nickname'], 'Martita');
    },
  );
  test(
    'availability stays unchanged on failure and replaces the confirmed schedule on retry',
    () async {
      var writes = 0;
      final harness = N2Harness((request) async {
        if (request.method == 'PUT') {
          writes++;
          return writes == 1
              ? apiError('INTERNAL_ERROR', 500)
              : jsonResponse(requestBody(request));
        }
        return jsonResponse(profileJson());
      });
      addTearDown(harness.dispose);
      await harness.signIn();
      final provider = profileControllerProvider('household-1');
      final subscription = harness.container.listen(
        provider,
        (previous, next) {},
      );
      addTearDown(subscription.close);
      await harness.container.read(provider.future);
      final controller = harness.container.read(provider.notifier);
      const value = Availability(
        slots: [AvailabilitySlot(weekday: 2, period: DayPeriod.evening)],
        exceptions: [],
      );
      expect(await controller.saveAvailability(value), isFalse);
      expect(
        harness.container
            .read(provider)
            .requireValue
            .profile
            .availability
            .slots,
        isEmpty,
      );
      expect(await controller.saveAvailability(value), isTrue);
      expect(
        harness.container.read(provider).requireValue.profile.availability,
        value,
      );
    },
  );
  test(
    'restriction create edit and removal expose only confirmed server state',
    () async {
      final harness = N2Harness((request) async {
        if (request.method == 'GET') return jsonResponse(profileJson());
        if (request.method == 'DELETE') return jsonResponse(null, 204);
        return jsonResponse(
          restrictionJson(
            kind: request.method == 'PUT' ? 'temporary' : 'permanent',
            endsOn: request.method == 'PUT' ? '2026-10-12' : null,
          ),
        );
      });
      addTearDown(harness.dispose);
      await harness.signIn();
      final provider = profileControllerProvider('household-1');
      final subscription = harness.container.listen(
        provider,
        (previous, next) {},
      );
      addTearDown(subscription.close);
      await harness.container.read(provider.future);
      final controller = harness.container.read(provider.notifier);
      const target = RestrictionTarget(
        type: RestrictionTargetType.activity,
        key: 'laundry_load',
      );
      expect(
        await controller.addRestriction(
          const RestrictionInput(
            target: target,
            kind: RestrictionKind.permanent,
          ),
        ),
        isTrue,
      );
      expect(
        harness.container
            .read(provider)
            .requireValue
            .profile
            .restrictions
            .single
            .kind,
        RestrictionKind.permanent,
      );
      expect(
        await controller.editRestriction(
          'restriction-1',
          const RestrictionInput(
            target: target,
            kind: RestrictionKind.temporary,
            endsOn: '2026-10-12',
          ),
        ),
        isTrue,
      );
      expect(
        harness.container
            .read(provider)
            .requireValue
            .profile
            .restrictions
            .single
            .endsOn,
        '2026-10-12',
      );
      expect(await controller.removeRestriction('restriction-1'), isTrue);
      expect(
        harness.container.read(provider).requireValue.profile.restrictions,
        isEmpty,
      );
    },
  );
  test(
    'a timed out restriction creation reconciles a server save without sending duplicate POST',
    () async {
      var created = false;
      var posts = 0;
      final harness = N2Harness((request) async {
        if (request.method == 'POST') {
          posts++;
          created = true;
          throw DioException(
            requestOptions: request,
            type: DioExceptionType.receiveTimeout,
          );
        }
        return jsonResponse(
          profileJson(restrictions: created ? [restrictionJson()] : []),
        );
      });
      addTearDown(harness.dispose);
      await harness.signIn();
      final provider = profileControllerProvider('household-1');
      final subscription = harness.container.listen(
        provider,
        (previous, next) {},
      );
      addTearDown(subscription.close);
      await harness.container.read(provider.future);
      final controller = harness.container.read(provider.notifier);
      const input = RestrictionInput(
        target: RestrictionTarget(
          type: RestrictionTargetType.activity,
          key: 'laundry_load',
        ),
        kind: RestrictionKind.permanent,
      );
      expect(await controller.addRestriction(input), isFalse);
      expect(
        harness.container.read(provider).requireValue.profile.restrictions,
        isEmpty,
      );
      expect(await controller.addRestriction(input), isTrue);
      expect(posts, 1);
      expect(
        harness.container
            .read(provider)
            .requireValue
            .profile
            .restrictions
            .length,
        1,
      );
    },
  );
  test(
    'unable activities create permanent restrictions and retry resumes partially saved preferences',
    () async {
      final restrictions = <Object?>[];
      var preferred = <String>['laundry_load'];
      var finalWrites = 0;
      var posts = 0;
      final harness = N2Harness((request) async {
        if (request.method == 'GET') {
          return jsonResponse(
            profileJson(restrictions: restrictions, preferred: preferred),
          );
        }
        if (request.method == 'POST') {
          posts++;
          expect(requestBody(request), {
            'target': {'type': 'activity', 'key': 'laundry_load'},
            'kind': 'permanent',
          });
          final restriction = restrictionJson();
          restrictions.add(restriction);
          return jsonResponse(restriction, 201);
        }
        final keys = (requestBody(request)['preferred_activity_keys'] as List)
            .cast<String>();
        if (keys.contains('dog_walk')) {
          finalWrites++;
          if (finalWrites == 1) return apiError('SERVICE_UNAVAILABLE', 503);
        }
        preferred = keys;
        return jsonResponse(preferencesJson(keys));
      });
      addTearDown(harness.dispose);
      await harness.signIn();
      final provider = profileControllerProvider('household-1');
      final subscription = harness.container.listen(
        provider,
        (previous, next) {},
      );
      addTearDown(subscription.close);
      await harness.container.read(provider.future);
      final controller = harness.container.read(provider.notifier);
      expect(
        await controller.savePreferences(['dog_walk'], {'laundry_load'}),
        isFalse,
      );
      final partial = harness.container.read(provider).requireValue;
      expect(
        partial.profile.restrictions.single.kind,
        RestrictionKind.permanent,
      );
      expect(partial.profile.preferences.preferredActivityKeys, isEmpty);
      expect(partial.savedPart, contains('Parte de las restricciones'));
      expect(
        await controller.savePreferences(['dog_walk'], {'laundry_load'}),
        isTrue,
      );
      expect(posts, 1);
      expect(
        harness.container
            .read(provider)
            .requireValue
            .profile
            .preferences
            .preferredActivityKeys,
        ['dog_walk'],
      );
    },
  );
  test(
    'contradictory preferred and unable selections fail validation before any writes',
    () async {
      final harness = N2Harness((request) async => jsonResponse(profileJson()));
      addTearDown(harness.dispose);
      await harness.signIn();
      final provider = profileControllerProvider('household-1');
      final subscription = harness.container.listen(
        provider,
        (previous, next) {},
      );
      addTearDown(subscription.close);
      await harness.container.read(provider.future);
      expect(
        await harness.container
            .read(provider.notifier)
            .savePreferences(['laundry_load'], {'laundry_load'}),
        isFalse,
      );
      final error =
          harness.container.read(provider).requireValue.error as ApiException;
      expect(error.code, ApiErrorCode.validationError);
      expect(error.fields.single.code, 'conflicting_values');
      expect(
        harness.adapter.requests.where((request) => request.method != 'GET'),
        isEmpty,
      );
    },
  );
  test(
    'concurrent saves are rejected and logout prevents a late profile write from restoring state',
    () async {
      final gate = Completer<ResponseBody>();
      final harness = N2Harness(
        (request) async => request.method == 'PATCH'
            ? gate.future
            : jsonResponse(profileJson()),
      );
      addTearDown(harness.dispose);
      await harness.signIn();
      final provider = profileControllerProvider('household-1');
      final subscription = harness.container.listen(
        provider,
        (previous, next) {},
      );
      addTearDown(subscription.close);
      await harness.container.read(provider.future);
      final controller = harness.container.read(provider.notifier);
      final pending = controller.saveProfile('Cambio', 30, AvatarChoice.indigo);
      expect(
        await controller.saveProfile('Otro', 40, AvatarChoice.indigo),
        isFalse,
      );
      await harness.container.read(sessionControllerProvider.notifier).expire();
      gate.complete(jsonResponse(profileJson()..['nickname'] = 'Cambio'));
      expect(await pending, isFalse);
      await Future<void>.delayed(Duration.zero);
      expect(
        harness.container.read(sessionControllerProvider).isAuthenticated,
        isFalse,
      );
      expect(harness.container.read(provider).hasError, isTrue);
    },
  );
}
