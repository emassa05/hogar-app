import 'package:flutter/foundation.dart';

@immutable
class FieldValidationError {
  const FieldValidationError({required this.field, required this.code});
  final String field;
  final String code;

  String get fieldName => field.replaceFirst(RegExp(r'^(body|query|path)\.'), '');

  static List<FieldValidationError> parse(Object? value) {
    if (value is! List) return const [];
    return value.whereType<Map<String, dynamic>>().map((item) => FieldValidationError(field: item['field'] is String ? item['field'] as String : '', code: item['code'] is String ? item['code'] as String : 'invalid_format')).where((item) => item.field.isNotEmpty).toList(growable: false);
  }
}
