@Tags(['e2e'])
library;

import 'package:flutter_test/flutter_test.dart';

import 'auth_scenarios.dart';
import 'capacity_scenarios.dart';
import 'household_scenarios.dart';
import 'n6_scenarios.dart';
import 'support/api_probe.dart';
import 'support/contract_report.dart';
import 'support/e2e_client.dart';
import 'support/e2e_config.dart';

void main() {
  final config = E2eConfig();
  final records = <ApiRecord>[];
  final report = ContractReport();
  final clients = <E2eClient>[];

  E2eClient newClient() {
    final client = E2eClient(config, records);
    clients.add(client);
    return client;
  }

  setUpAll(config.validate);
  tearDown(() async {
    for (final client in clients) {
      await client.close();
    }
    clients.clear();
    await ApiProbe.writeEvidence(records);
    await report.write();
    report.verifyEnvelopes(records);
  });

  test(
    'n1 verifies, registers, logs in, resets a locked account and logs out',
    () async {
      await exerciseAuth(newClient(), report);
    },
  );

  test(
    'real interceptors refresh once for concurrent 401s and reject rotation reuse',
    () async {
      await exerciseRefresh(newClient());
    },
  );

  test(
    'n2 persists households, invitations, profiles, catalog and templates',
    () async {
      await exerciseHouseholds(newClient(), newClient(), report);
    },
  );

  group('n6', () {
    test(
      'backend enforces roles and independent own profile identity',
      () async {
        await exerciseN6Permissions(newClient(), newClient());
      },
    );
    test(
      'switching persists and leaving requires manual next selection',
      () async {
        await exerciseN6SwitchAndLeave(newClient(), newClient());
      },
    );
    test(
      'rf18 approves next Monday and invalidates changed membership',
      () async {
        await exerciseCapacity(newClient(), newClient(), newClient());
      },
    );
    test(
      'f5 reports missing n3 settings dependency, not persistence',
      () async {
        await exerciseMissingNotificationDependency(newClient());
      },
    );
  });
}
