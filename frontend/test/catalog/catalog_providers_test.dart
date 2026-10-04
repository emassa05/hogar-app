import 'package:flutter_test/flutter_test.dart';
import 'package:hogar_app/core/errors/app_exception.dart';
import 'package:hogar_app/core/session/session_controller.dart';
import 'package:hogar_app/features/catalog/presentation/catalog_providers.dart';
import 'package:hogar_app/features/households/presentation/household_controller.dart';
import '../support/fake_http_adapter.dart';
import '../support/n2_fixtures.dart';
import '../support/n2_harness.dart';

void main() {
  test(
    'catalog providers cache each catalog and revoke cached values on logout',
    () async {
      final harness = N2Harness(
        (request) async => jsonResponse(
          request.path.endsWith('task-categories')
              ? categoriesJson()
              : activitiesJson(),
        ),
      );
      addTearDown(harness.dispose);
      await harness.signIn();
      expect(
        (await harness.container.read(taskCategoriesProvider.future)).length,
        2,
      );
      expect(
        (await harness.container.read(activitiesProvider.future)).length,
        2,
      );
      await harness.container.read(taskCategoriesProvider.future);
      await harness.container.read(activitiesProvider.future);
      expect(harness.adapter.requests.length, 2);
      await harness.container.read(sessionControllerProvider.notifier).expire();
      await expectLater(
        harness.container.read(activitiesProvider.future),
        throwsA(isA<UnauthenticatedException>()),
      );
      expect(harness.adapter.requests.length, 2);
    },
  );
  test(
    'household queries expose summaries and update active query when session changes',
    () async {
      final harness = N2Harness(
        (request) async => jsonResponse(
          request.path == '/households' ? [summaryJson()] : householdJson(),
        ),
      );
      addTearDown(harness.dispose);
      await harness.signIn();
      final active = harness.container.listen(
        activeHouseholdProvider,
        (previous, next) {},
      );
      final list = harness.container.listen(
        householdListProvider,
        (previous, next) {},
      );
      addTearDown(active.close);
      addTearDown(list.close);
      expect(
        (await harness.container.read(
          householdListProvider.future,
        )).single.memberCount,
        1,
      );
      expect(
        (await harness.container.read(activeHouseholdProvider.future))!.id,
        'household-1',
      );
      await harness.container.read(sessionControllerProvider.notifier).expire();
      expect(
        await harness.container.read(activeHouseholdProvider.future),
        isNull,
      );
      await expectLater(
        harness.container.read(householdListProvider.future),
        throwsA(isA<UnauthenticatedException>()),
      );
    },
  );
}
