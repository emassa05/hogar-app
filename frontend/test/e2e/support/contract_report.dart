import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:hogar_app/core/errors/api_error_code.dart';
import 'package:hogar_app/core/result/result.dart';
import 'package:hogar_app/features/templates/domain/template_entities.dart';

import 'api_probe.dart';
import 'e2e_client.dart';

class ContractReport {
  final List<Map<String, dynamic>> findings = [];

  Future<void> checkLogoutReplay(E2eClient client, String refreshToken) async {
    final result = await client.auth.logout(refreshToken);
    if (result is Success<void>) return;
    final record = client.probe.records.last;
    findings.add({
      'contract': '11.2 POST /auth/logout: repeated logout returns 204',
      'request': {
        'method': 'POST',
        'path': '/auth/logout',
        'body': {'refresh_token': '[REDACTED]'},
        'authorization': '[REDACTED]',
      },
      'expected_status': 204,
      'actual': record.toJson(),
    });
  }

  Future<void> checkTemplateResources(
    E2eClient client,
    String householdId,
    TemplateApplication application,
  ) async {
    for (final resource in ['tasks', 'routines']) {
      final path = '/households/$householdId/$resource';
      try {
        await client.dio.get<Object?>(path, queryParameters: {'limit': 100});
      } on DioException {
        final record = client.probe.records.last;
        findings.add({
          'contract':
              '11.8 template application generates unassigned tasks and routines',
          'request': {
            'method': 'GET',
            'path': path,
            'query': {'limit': 100},
            'authorization': '[REDACTED]',
          },
          'application': {
            'method': 'POST',
            'path': '/households/$householdId/template-application',
            'status': 201,
            'request': {'template_keys': application.templateKeys},
            'response': {
              'template_keys': application.templateKeys,
              'task_count': application.taskCount,
            },
          },
          'expected_status': 200,
          'actual': record.toJson(),
        });
      }
    }
  }

  Future<void> write() async {
    final directory = Directory('build/e2e');
    await directory.create(recursive: true);
    await File(
      '${directory.path}/contract-findings.json',
    ).writeAsString(const JsonEncoder.withIndent('  ').convert(findings));
  }

  void verifyEnvelopes(List<ApiRecord> records) {
    for (final record in records) {
      if (record.error != null &&
          ApiErrorCode.fromValue(record.error!['code']) ==
              ApiErrorCode.unknown) {
        throw StateError('The API returned an unmapped error code.');
      }
      if (record.echoedRequestId != record.requestId) {
        throw StateError(
          'The API did not echo X-Request-ID on ${record.path}.',
        );
      }
      if (record.error?['request_id'] != null &&
          record.error!['request_id'] != record.requestId) {
        throw StateError('The error envelope has a different request ID.');
      }
    }
  }
}
