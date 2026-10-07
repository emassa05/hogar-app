import '../../../core/network/api_response.dart';
import '../../../core/session/session_user.dart';
import '../domain/capacity_entities.dart';

abstract final class CapacityDtos {
  static void _requireKeys(Map<String, dynamic> json, List<String> keys) {
    if (keys.any((key) => !json.containsKey(key))) {
      throw const FormatException('Missing required capacity response fields');
    }
  }

  static int percent(Object? value) {
    if (value is! int || value < 0 || value > 100) {
      throw const FormatException(
        'Expected an integer percent between 0 and 100',
      );
    }
    return value;
  }

  static CapacityMember member(Object? value) {
    final json = ApiResponse.object(value);
    _requireKeys(json, ['user_id', 'display_name', 'avatar', 'is_active']);
    final avatar = json['avatar'];
    return CapacityMember(
      userId: json['user_id'] as String,
      displayName: json['display_name'] as String,
      avatar: avatar == null
          ? null
          : AvatarChoice.values.byName(avatar as String),
      isActive: json['is_active'] as bool,
    );
  }

  static CapacityDistribution distribution(Object? value) {
    final json = ApiResponse.object(value);
    final date = json['effective_from'] as String;
    final approvedAt = DateTime.parse(json['approved_at'] as String);
    if (!approvedAt.isUtc) {
      throw const FormatException('Expected a UTC approval timestamp');
    }
    final parsed = DateTime.tryParse(date);
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date) ||
        parsed == null ||
        parsed.toIso8601String().substring(0, 10) != date) {
      throw const FormatException('Expected a local date');
    }
    final allocations = ApiResponse.objects(json['allocations'])
        .map(
          (item) => CapacityAllocation(
            member: member(item['member']),
            percent: percent(item['percent']),
          ),
        )
        .toList(growable: false);
    if (allocations.fold(0, (sum, item) => sum + item.percent) != 100 ||
        allocations.map((item) => item.member.userId).toSet().length !=
            allocations.length) {
      throw const FormatException(
        'Expected a complete 100 percent distribution',
      );
    }
    return CapacityDistribution(
      id: json['id'] as String,
      effectiveFrom: date,
      approvedBy: member(json['approved_by']),
      approvedAt: approvedAt,
      allocations: allocations,
    );
  }

  static CapacityOverview overview(Object? value) {
    final json = ApiResponse.object(value);
    _requireKeys(json, ['status', 'current', 'upcoming', 'proposals']);
    final status = switch (json['status']) {
      'configured' => CapacityStatus.configured,
      'not_configured' => CapacityStatus.notConfigured,
      _ => throw const FormatException('Unknown capacity status'),
    };
    final current = json['current'] == null
        ? null
        : distribution(json['current']);
    final upcoming = json['upcoming'] == null
        ? null
        : distribution(json['upcoming']);
    final proposals = ApiResponse.objects(json['proposals'])
        .map(
          (item) => CapacityProposal(
            member: member(item['member']),
            proposedCapacityPercent: item['proposed_capacity_percent'] == null
                ? null
                : percent(item['proposed_capacity_percent']),
          ),
        )
        .toList(growable: false);
    final ids = proposals.map((item) => item.member.userId).toSet();
    if ((status == CapacityStatus.configured) != (current != null) ||
        ids.length != proposals.length ||
        proposals.any((item) => !item.member.isActive)) {
      throw const FormatException('Inconsistent capacity overview');
    }
    for (final approved in [
      current,
      upcoming,
    ].whereType<CapacityDistribution>()) {
      if (approved.allocations.length != ids.length ||
          approved.allocations.any(
            (item) =>
                !ids.contains(item.member.userId) || !item.member.isActive,
          )) {
        throw const FormatException(
          'Distribution does not match active members',
        );
      }
    }
    return CapacityOverview(
      status: status,
      current: current,
      upcoming: upcoming,
      proposals: proposals,
    );
  }

  static CapacityHistory history(Object? value) {
    final json = ApiResponse.object(value);
    _requireKeys(json, ['items', 'next_cursor']);
    return CapacityHistory(
      items: ApiResponse.objects(
        json['items'],
      ).map(distribution).toList(growable: false),
      nextCursor: json['next_cursor'] as String?,
    );
  }
}
