import 'package:flutter_test/flutter_test.dart';
import 'package:hogar_app/core/errors/app_exception.dart';
import 'package:hogar_app/core/result/result.dart';
import 'package:hogar_app/features/capacity/data/capacity_dtos.dart';
import 'package:hogar_app/features/capacity/data/capacity_repository_impl.dart';
import 'package:hogar_app/features/capacity/domain/capacity_entities.dart';
import 'package:hogar_app/features/profile/data/profile_repository_impl.dart';

import '../support/fake_http_adapter.dart';
import '../support/n2_harness.dart';
import 'capacity_fixtures.dart';

void main() {
  test(
    'capacity overview preserves nullable values and separates current from upcoming',
    () {
      final overview = CapacityDtos.overview(
        overviewJson(own: null, other: 0, upcoming: distributionJson()),
      );
      expect(overview.status, CapacityStatus.notConfigured);
      expect(overview.current, isNull);
      expect(overview.upcoming!.effectiveFrom, '2026-10-12');
      expect(overview.proposals.first.proposedCapacityPercent, isNull);
      expect(overview.proposals.last.proposedCapacityPercent, 0);
    },
  );
  for (final value in [1.5, '30', true, -1, 101, null]) {
    test(
      'percent parser rejects $value',
      () => expect(() => CapacityDtos.percent(value), throwsFormatException),
    );
  }
  test(
    'unknown status incomplete allocations and malformed local dates are rejected',
    () {
      expect(
        () => CapacityDtos.overview(overviewJson()..['status'] = 'unknown'),
        throwsFormatException,
      );
      expect(
        () => CapacityDtos.distribution(
          distributionJson()..['effective_from'] = '2026-02-30',
        ),
        throwsFormatException,
      );
      expect(
        () => CapacityDtos.distribution(
          distributionJson()
            ..['allocations'] = [
              {'member': capacityMemberJson(), 'percent': 50},
            ],
        ),
        throwsFormatException,
      );
      expect(
        () => CapacityDtos.overview(overviewJson()..['status'] = 'configured'),
        throwsFormatException,
      );
    },
  );
  test(
    'repository uses exact routes key body and opaque cursor; own proposal patches capacity only',
    () async {
      final server = CapacityServer();
      final harness = N2Harness(server.respond);
      addTearDown(harness.dispose);
      final repository = harness.container.read(capacityRepositoryProvider);
      expect(
        await repository.overview('household-1'),
        isA<Success<CapacityOverview>>(),
      );
      expect(
        await repository.approve('household-1', {
          'user-1': 40,
          'user-2': 60,
        }, 'action-key'),
        isA<Success<CapacityDistribution>>(),
      );
      final approval = harness.adapter.requests.last;
      expect(approval.path, '/households/household-1/capacity/distributions');
      expect(approval.headers['Idempotency-Key'], 'action-key');
      expect(requestBody(approval), {
        'allocations': [
          {'user_id': 'user-1', 'percent': 40},
          {'user_id': 'user-2', 'percent': 60},
        ],
      });
      await repository.history('household-1', cursor: '1');
      expect(harness.adapter.requests.last.queryParameters, {'cursor': '1'});
      await harness.container
          .read(profileRepositoryProvider)
          .updateCapacity('household-1', 0);
      expect(requestBody(harness.adapter.requests.last), {
        'proposed_capacity_percent': 0,
      });
      expect(
        harness.adapter.requests.last.path,
        '/households/household-1/members/me/profile',
      );
    },
  );
  test(
    'malformed server response is failure rather than fake capacity',
    () async {
      final harness = N2Harness(
        (_) async => jsonResponse({
          'status': 'not_configured',
          'proposals': <Object?>[],
        }),
      );
      addTearDown(harness.dispose);
      final result = await harness.container
          .read(capacityRepositoryProvider)
          .overview('household-1');
      expect(result, isA<Failure<CapacityOverview>>());
      expect(
        (result as Failure<CapacityOverview>).error,
        isA<UnexpectedException>(),
      );
    },
  );
}
