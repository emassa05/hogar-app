import 'package:dio/dio.dart';

import '../support/fake_http_adapter.dart';
import '../support/n2_fixtures.dart';

Map<String, dynamic> capacityMemberJson({
  String id = 'user-1',
  bool active = true,
}) => {
  'user_id': id,
  'display_name': id == 'user-1' ? 'Marta' : 'Pablo',
  'avatar': id == 'user-1' ? 'indigo' : 'green',
  'is_active': active,
};

Map<String, dynamic> distributionJson({
  String id = 'distribution-1',
  int own = 30,
  String date = '2026-10-12',
}) => {
  'id': id,
  'effective_from': date,
  'approved_by': capacityMemberJson(),
  'approved_at': '2026-10-07T12:00:00Z',
  'allocations': [
    {'member': capacityMemberJson(), 'percent': own},
    {'member': capacityMemberJson(id: 'user-2'), 'percent': 100 - own},
  ],
};

Map<String, dynamic> overviewJson({
  int? own = 30,
  int? other = 70,
  Map<String, dynamic>? current,
  Map<String, dynamic>? upcoming,
}) => {
  'status': current == null ? 'not_configured' : 'configured',
  'current': current,
  'upcoming': upcoming,
  'proposals': [
    {'member': capacityMemberJson(), 'proposed_capacity_percent': own},
    {
      'member': capacityMemberJson(id: 'user-2'),
      'proposed_capacity_percent': other,
    },
  ],
};

class CapacityServer {
  String role = 'admin';
  int? own = 30;
  int? other = 70;
  Map<String, dynamic>? current;
  Map<String, dynamic>? upcoming;
  List<Map<String, dynamic>> records = [];
  bool capacityFails = false;
  bool proposalFails = false;
  bool historyFails = false;
  String? approvalError;
  bool followUpFails = false;
  bool approved = false;

  Future<ResponseBody> respond(RequestOptions request) async {
    if (request.path.endsWith('/members/me/profile')) {
      if (request.method == 'PATCH') {
        if (proposalFails) return apiError('SERVICE_UNAVAILABLE', 503);
        own = requestBody(request)['proposed_capacity_percent'] as int;
      }
      return jsonResponse(profileJson()..['proposed_capacity_percent'] = own);
    }
    if (request.path.endsWith('/capacity/distributions')) {
      if (request.method == 'POST') {
        if (approvalError != null) {
          return apiError(
            approvalError!,
            approvalError == 'ADMIN_REQUIRED'
                ? 403
                : approvalError == 'CAPACITY_SUM_INVALID'
                ? 422
                : 503,
          );
        }
        final values = requestBody(request)['allocations'] as List<dynamic>;
        final ownAllocation = values.cast<Map<String, dynamic>>().firstWhere(
          (value) => value['user_id'] == 'user-1',
        );
        upcoming = distributionJson(
          id: 'distribution-${records.length + 1}',
          own: ownAllocation['percent'] as int,
        );
        records.insert(0, upcoming!);
        approved = true;
        return jsonResponse(upcoming, 201);
      }
      if (historyFails) return apiError('SERVICE_UNAVAILABLE', 503);
      final offset = request.queryParameters['cursor'] == null
          ? 0
          : int.parse(request.queryParameters['cursor'] as String);
      final page = records.skip(offset).take(1).toList();
      return jsonResponse({
        'items': page,
        'next_cursor': offset + page.length < records.length
            ? '${offset + page.length}'
            : null,
      });
    }
    if (request.path.endsWith('/capacity')) {
      if (capacityFails || followUpFails && approved) {
        return apiError('SERVICE_UNAVAILABLE', 503);
      }
      return jsonResponse(
        overviewJson(
          own: own,
          other: other,
          current: current,
          upcoming: upcoming,
        ),
      );
    }
    if (request.path.startsWith('/households/')) {
      return jsonResponse(
        householdJson(role: role)
          ..['members'] = [
            memberJson(role: role),
            memberJson(id: 'user-2', isMe: false, role: 'member'),
          ],
      );
    }
    throw StateError('Unexpected request: ${request.method} ${request.path}');
  }
}
