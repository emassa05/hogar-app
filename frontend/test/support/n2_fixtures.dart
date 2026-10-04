Map<String, dynamic> userJson({
  String? householdId = 'household-1',
  String? avatar = 'indigo',
}) => {
  'id': 'user-1',
  'phone': '+56987654321',
  'name': 'Marta',
  'avatar': avatar,
  'active_household_id': householdId,
  'created_at': '2026-10-04T12:00:00Z',
};
Map<String, dynamic> memberJson({
  String id = 'user-1',
  String role = 'admin',
  bool isMe = true,
}) => {
  'user_id': id,
  'name': isMe ? 'Marta' : 'Pablo',
  'nickname': null,
  'avatar': 'indigo',
  'role': role,
  'joined_at': '2026-10-04T12:00:00Z',
  'is_me': isMe,
};
Map<String, dynamic> householdJson({
  int version = 1,
  String name = 'Casa Los Robles',
  bool templatesApplied = false,
  String role = 'admin',
}) => {
  'id': 'household-1',
  'name': name,
  'timezone': 'America/Santiago',
  'imbalance_threshold_percent': null,
  'my_role': role,
  'members': [memberJson(role: role)],
  'templates_applied': templatesApplied,
  'version': version,
  'created_at': '2026-10-04T12:00:00Z',
};
Map<String, dynamic> summaryJson() => {
  'id': 'household-1',
  'name': 'Casa Los Robles',
  'my_role': 'admin',
  'member_count': 1,
  'created_at': '2026-10-04T12:00:00Z',
};
Map<String, dynamic> invitationJson({String code = '7QK2-M9XA'}) => {
  'code': code,
  'expires_at': DateTime.now()
      .toUtc()
      .add(const Duration(days: 7))
      .toIso8601String(),
  'share_url': 'https://hogarapp.cl/unirse/$code',
};
Map<String, dynamic> previewJson({String name = 'Casa Los Robles'}) => {
  'household_id': 'household-1',
  'household_name': name,
  'member_count': 4,
  'expires_at': DateTime.now()
      .toUtc()
      .add(const Duration(days: 7))
      .toIso8601String(),
};
Map<String, dynamic> availabilityJson() => {
  'slots': <Object?>[],
  'exceptions': <Object?>[],
};
Map<String, dynamic> preferencesJson([List<String> keys = const []]) => {
  'preferred_activity_keys': keys,
};
Map<String, dynamic> restrictionJson({
  String id = 'restriction-1',
  String key = 'laundry_load',
  String type = 'activity',
  String kind = 'permanent',
  String? endsOn,
}) => {
  'id': id,
  'target': {'type': type, 'key': key},
  'target_name': 'Poner la lavadora',
  'kind': kind,
  'starts_on': '2026-10-04',
  'ends_on': endsOn,
  'is_active': true,
  'created_at': '2026-10-04T12:00:00Z',
};
Map<String, dynamic> profileJson({
  List<Object?> restrictions = const [],
  List<String> preferred = const [],
  String? avatar = 'indigo',
}) => {
  'user_id': 'user-1',
  'name': 'Marta',
  'nickname': null,
  'avatar': avatar,
  'role': 'admin',
  'is_me': true,
  'proposed_capacity_percent': null,
  'approved_capacity_percent': null,
  'availability': availabilityJson(),
  'restrictions': restrictions,
  'preferences': preferencesJson(preferred),
};
List<Map<String, dynamic>> categoriesJson() => [
  {'key': 'laundry', 'name': 'Ropa'},
  {'key': 'pets', 'name': 'Mascotas'},
];
List<Map<String, dynamic>> activitiesJson() => [
  {
    'key': 'laundry_load',
    'name': 'Poner la lavadora',
    'category_key': 'laundry',
  },
  {'key': 'dog_walk', 'name': 'Pasear al perro', 'category_key': 'pets'},
];
Map<String, dynamic> templateTaskJson({String key = 'laundry_load'}) => {
  'activity_key': key,
  'name': key == 'dog_walk' ? 'Pasear al perro' : 'Poner la lavadora',
  'category_key': key == 'dog_walk' ? 'pets' : 'laundry',
  'recurrence_label': '2 veces por semana',
  'distribution': 'rotating',
  'estimated_duration_minutes': 20,
  'effort': 2,
  'mental_load': 1,
};
Map<String, dynamic> templateJson({
  String key = 'family',
  int count = 19,
  bool detail = false,
}) => {
  'key': key,
  'name': key == 'pets' ? 'Vivo con mascotas' : 'Familia con niñas o niños',
  'description': 'Tareas habituales del hogar',
  'task_count': count,
  if (detail)
    'tasks': [
      templateTaskJson(key: key == 'pets' ? 'dog_walk' : 'laundry_load'),
    ],
};
Map<String, dynamic> applicationJson({
  List<String> keys = const ['family'],
  int count = 19,
}) => {
  'template_keys': keys,
  'task_count': count,
  'applied_by': {
    'user_id': 'user-1',
    'display_name': 'Marta',
    'avatar': 'indigo',
    'is_active': true,
  },
  'applied_at': '2026-10-04T12:00:00Z',
};
