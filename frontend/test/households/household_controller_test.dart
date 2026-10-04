import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hogar_app/core/errors/api_error_code.dart';
import 'package:hogar_app/core/errors/app_exception.dart';
import 'package:hogar_app/core/session/session_controller.dart';
import 'package:hogar_app/features/households/domain/household_entities.dart';
import 'package:hogar_app/features/households/presentation/household_controller.dart';
import '../support/fake_http_adapter.dart';
import '../support/n2_fixtures.dart';
import '../support/n2_harness.dart';

void main() {
  test(
    'creation reuses an intention key after timeout and rejects concurrent changed payloads',
    () async {
      final first = Completer<ResponseBody>();
      final started = Completer<RequestOptions>();
      var creations = 0;
      final harness = N2Harness((request) async {
        creations++;
        if (creations == 1) {
          started.complete(request);
          return first.future;
        }
        return jsonResponse(householdJson(), 201);
      });
      addTearDown(harness.dispose);
      await harness.signIn(householdId: null);
      final controller = harness.container.read(
        householdControllerProvider.notifier,
      );
      final pending = controller.create(' Casa Los Robles ');
      expect(await controller.create('Otro hogar'), isFalse);
      final firstRequest = await started.future.timeout(
        const Duration(seconds: 3),
      );
      first.completeError(
        DioException(
          requestOptions: firstRequest,
          type: DioExceptionType.receiveTimeout,
        ),
      );
      expect(await pending, isFalse);
      expect(
        harness.container.read(householdControllerProvider).household,
        isNull,
      );
      expect(await controller.create('Casa Los Robles'), isTrue);
      expect(
        harness.adapter.requests[1].headers['Idempotency-Key'],
        firstRequest.headers['Idempotency-Key'],
      );
      expect(
        harness.container
            .read(sessionControllerProvider)
            .user!
            .activeHouseholdId,
        'household-1',
      );
      expect(await controller.create('Otro hogar'), isTrue);
      expect(
        harness.adapter.requests.last.headers['Idempotency-Key'],
        isNot(firstRequest.headers['Idempotency-Key']),
      );
    },
  );
  test(
    'version conflict reloads current resource and never retries an overwrite automatically',
    () async {
      var patches = 0;
      final harness = N2Harness((request) async {
        if (request.method == 'PATCH') {
          patches++;
          return patches == 1
              ? apiError('VERSION_CONFLICT', 412)
              : jsonResponse(householdJson(version: 3, name: 'Cambio mío'));
        }
        return jsonResponse(householdJson(version: 2, name: 'Cambio ajeno'));
      });
      addTearDown(harness.dispose);
      await harness.signIn();
      final controller = harness.container.read(
        householdControllerProvider.notifier,
      );
      expect(await controller.rename('household-1', 1, 'Cambio mío'), isFalse);
      final state = harness.container.read(householdControllerProvider);
      expect(state.household!.name, 'Cambio ajeno');
      expect(state.household!.version, 2);
      expect((state.error as ApiException).code, ApiErrorCode.versionConflict);
      expect(patches, 1);
      expect(
        await controller.rename(
          'household-1',
          state.household!.version,
          'Cambio mío',
        ),
        isTrue,
      );
      expect(requestBody(harness.adapter.requests.last)['version'], 2);
    },
  );
  test(
    'failed conflict reload preserves the 412 error and tells the caller to reload',
    () async {
      final harness = N2Harness(
        (request) async => request.method == 'PATCH'
            ? apiError('VERSION_CONFLICT', 412)
            : apiError('SERVICE_UNAVAILABLE', 503),
      );
      addTearDown(harness.dispose);
      await harness.signIn();
      expect(
        await harness.container
            .read(householdControllerProvider.notifier)
            .rename('household-1', 1, 'Cambio'),
        isFalse,
      );
      final state = harness.container.read(householdControllerProvider);
      expect((state.error as ApiException).code, ApiErrorCode.versionConflict);
      expect(state.savedPart, contains('No pudimos cargar'));
    },
  );
  test(
    'late invitation preview cannot overwrite a newer code or cleared input',
    () async {
      final gates = {
        '7QK2-M9XA': Completer<ResponseBody>(),
        '8QK2-M9XA': Completer<ResponseBody>(),
      };
      final harness = N2Harness(
        (request) async => gates[request.path.split('/').last]!.future,
      );
      addTearDown(harness.dispose);
      await harness.signIn();
      final controller = harness.container.read(
        householdControllerProvider.notifier,
      );
      final old = controller.preview('7qk2m9xa');
      final current = controller.preview('8qk2-m9xa');
      gates['8QK2-M9XA']!.complete(
        jsonResponse(previewJson(name: 'Hogar actual')),
      );
      expect(await current, isTrue);
      gates['7QK2-M9XA']!.complete(
        jsonResponse(previewJson(name: 'Hogar anterior')),
      );
      expect(await old, isFalse);
      expect(
        harness.container
            .read(householdControllerProvider)
            .preview!
            .householdName,
        'Hogar actual',
      );
      controller.clearPreview();
      expect(
        harness.container.read(householdControllerProvider).preview,
        isNull,
      );
      expect(await controller.preview('invalid'), isFalse);
    },
  );
  test(
    'logout cancels a late creation and prevents restoring household or session state',
    () async {
      final gate = Completer<ResponseBody>();
      final harness = N2Harness((request) async => gate.future);
      addTearDown(harness.dispose);
      await harness.signIn(householdId: null);
      final pending = harness.container
          .read(householdControllerProvider.notifier)
          .create('Casa');
      await harness.container.read(sessionControllerProvider.notifier).expire();
      gate.complete(jsonResponse(householdJson(), 201));
      expect(await pending, isFalse);
      expect(
        harness.container.read(householdControllerProvider).household,
        isNull,
      );
      expect(
        harness.container.read(sessionControllerProvider).isAuthenticated,
        isFalse,
      );
    },
  );
  test(
    'accept activates only confirmed membership and an existing home uses PATCH users me',
    () async {
      var accepted = false;
      final harness = N2Harness((request) async {
        if (request.path.endsWith('/accept')) {
          accepted = true;
          return apiError('ALREADY_MEMBER', 409, {
            'household_id': 'household-1',
          });
        }
        if (request.path == '/users/me') return jsonResponse(userJson());
        if (request.path.startsWith('/invitations')) {
          return jsonResponse(previewJson());
        }
        return jsonResponse(householdJson(role: 'member'));
      });
      addTearDown(harness.dispose);
      await harness.signIn(householdId: null);
      final controller = harness.container.read(
        householdControllerProvider.notifier,
      );
      expect(await controller.accept(), isFalse);
      expect(await controller.preview('7QK2M9XA'), isTrue);
      expect(await controller.accept(), isFalse);
      expect(accepted, isTrue);
      expect(
        harness.container
            .read(sessionControllerProvider)
            .user!
            .activeHouseholdId,
        isNull,
      );
      expect(
        (harness.container.read(householdControllerProvider).error
                as ApiException)
            .details['household_id'],
        'household-1',
      );
      expect(await controller.openExisting('household-1'), isTrue);
      expect(harness.adapter.requests.last.method, 'PATCH');
      expect(requestBody(harness.adapter.requests.last), {
        'active_household_id': 'household-1',
      });
    },
  );
  test(
    'expired previews are rejected without accepting on the server',
    () async {
      final harness = N2Harness(
        (request) async => jsonResponse(
          previewJson()
            ..['expires_at'] = DateTime.now()
                .subtract(const Duration(seconds: 1))
                .toIso8601String(),
        ),
      );
      addTearDown(harness.dispose);
      await harness.signIn();
      final controller = harness.container.read(
        householdControllerProvider.notifier,
      );
      expect(await controller.preview('7QK2-M9XA'), isTrue);
      expect(await controller.accept(), isFalse);
      expect(
        (harness.container.read(householdControllerProvider).error
                as ApiException)
            .code,
        ApiErrorCode.invitationExpired,
      );
      expect(harness.adapter.requests.length, 1);
    },
  );
  test(
    'a confirmed member permission remains visible when follow up reload fails',
    () async {
      var loads = 0;
      final harness = N2Harness((request) async {
        if (request.method == 'PATCH') {
          return jsonResponse(memberJson(role: 'member'));
        }
        loads++;
        return loads == 1
            ? jsonResponse(householdJson())
            : apiError('SERVICE_UNAVAILABLE', 503);
      });
      addTearDown(harness.dispose);
      await harness.signIn();
      final controller = harness.container.read(
        householdControllerProvider.notifier,
      );
      expect(
        await controller.load('household-1', includeInvitation: false),
        isTrue,
      );
      expect(
        await controller.changeRole('household-1', 'user-1', MemberRole.member),
        isFalse,
      );
      final state = harness.container.read(householdControllerProvider);
      expect(state.household!.members.single.role, MemberRole.member);
      expect(state.household!.myRole, MemberRole.member);
      expect(state.savedPart, contains('permiso ya está guardado'));
      expect(state.busy, isFalse);
      expect(state.error, isA<ApiException>());
    },
  );
  test(
    'admin invitation failures preserve confirmed household and rate limits block retries',
    () async {
      final harness = N2Harness(
        (request) async => request.path.endsWith('/invitation')
            ? apiError('RATE_LIMITED', 429, {'retry_after_seconds': 60})
            : jsonResponse(householdJson()),
      );
      addTearDown(harness.dispose);
      await harness.signIn();
      final controller = harness.container.read(
        householdControllerProvider.notifier,
      );
      expect(await controller.load('household-1'), isFalse);
      expect(
        harness.container.read(householdControllerProvider).household,
        isNotNull,
      );
      expect(
        harness.container.read(householdControllerProvider).invitation,
        isNull,
      );
      expect(await controller.load('household-1'), isFalse);
      expect(harness.adapter.requests.length, 2);
      expect(
        harness.container
            .read(householdControllerProvider)
            .blockedUntil!
            .isAfter(DateTime.now()),
        isTrue,
      );
    },
  );
}
