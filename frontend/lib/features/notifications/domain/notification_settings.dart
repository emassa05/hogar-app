class QuietHours {
  const QuietHours(this.start, this.end);
  final String start;
  final String end;

  static bool validTime(String value) =>
      value.length == 5 &&
      RegExp(r'^(?:[01][0-9]|2[0-3]):[0-5][0-9]$').hasMatch(value);

  Map<String, Object?> toJson() => {'start': start, 'end': end};
}

class NotificationSettings {
  NotificationSettings({
    required this.muted,
    required List<String> mutedTypes,
    required this.quietHours,
    required this.reminderLeadMinutes,
  }) : mutedTypes = List.unmodifiable(mutedTypes);

  static const supportedTypes = {
    'task_reminder',
    'task_due',
    'routine_without_candidate',
    'swap_request',
    'swap_resolved',
    'suggestion_pending',
    'suggestion_resolved',
    'member_joined',
  };

  final bool muted;
  final List<String> mutedTypes;
  final QuietHours? quietHours;
  final int? reminderLeadMinutes;

  bool get isValid =>
      mutedTypes.every(supportedTypes.contains) &&
      (reminderLeadMinutes == null ||
          (reminderLeadMinutes! >= 5 && reminderLeadMinutes! <= 10080)) &&
      (quietHours == null ||
          (QuietHours.validTime(quietHours!.start) &&
              QuietHours.validTime(quietHours!.end)));

  factory NotificationSettings.fromJson(Object? data) {
    if (data is! Map<String, Object?> ||
        data['muted'] is! bool ||
        data['muted_types'] is! List<Object?> ||
        !data.containsKey('quiet_hours') ||
        !data.containsKey('reminder_lead_minutes')) {
      throw const FormatException('Invalid notification settings');
    }
    final types = data['muted_types'];
    final lead = data['reminder_lead_minutes'];
    final quiet = data['quiet_hours'];
    if (types is! List<Object?> ||
        types.any((value) => value is! String) ||
        (lead != null && lead is! int)) {
      throw const FormatException('Invalid notification settings fields');
    }
    QuietHours? hours;
    if (quiet != null) {
      if (quiet case {'start': final String start, 'end': final String end}) {
        hours = QuietHours(start, end);
      } else {
        throw const FormatException('Invalid quiet hours');
      }
    }
    final result = NotificationSettings(
      muted: data['muted'] as bool,
      mutedTypes: [for (final value in types) value as String],
      quietHours: hours,
      reminderLeadMinutes: lead as int?,
    );
    if (!result.isValid) {
      throw const FormatException('Invalid notification settings values');
    }
    return result;
  }

  Map<String, Object?> toJson() => {
    'muted': muted,
    'muted_types': mutedTypes,
    'quiet_hours': quietHours?.toJson(),
    'reminder_lead_minutes': reminderLeadMinutes,
  };

  bool sameValues(NotificationSettings other) =>
      muted == other.muted &&
      reminderLeadMinutes == other.reminderLeadMinutes &&
      quietHours?.start == other.quietHours?.start &&
      quietHours?.end == other.quietHours?.end &&
      mutedTypes.toSet().length == other.mutedTypes.toSet().length &&
      mutedTypes.toSet().containsAll(other.mutedTypes);
}
