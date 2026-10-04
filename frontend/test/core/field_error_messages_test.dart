import 'package:flutter_test/flutter_test.dart';
import 'package:hogar_app/core/errors/api_error_code.dart';
import 'package:hogar_app/core/errors/app_exception.dart';
import 'package:hogar_app/core/l10n/error_messages.dart';

void main() {
  test('maps indexed API validation to the parent form field', () {
    final error = ApiException(
      statusCode: 422,
      code: ApiErrorCode.validationError,
      details: {
        'fields': [
          {
            'field': 'body.preferred_activity_keys.0',
            'code': 'conflicting_values',
          },
        ],
      },
    );
    expect(
      ErrorMessages.field(error, 'preferred_activity_keys'),
      'Esta opción es incompatible con los datos actuales.',
    );
    expect(
      ErrorMessages.field(error, 'preferred_activity_keys.0'),
      'Esta opción es incompatible con los datos actuales.',
    );
    expect(ErrorMessages.field(error, 'preferred_activity'), isNull);
    expect(ErrorMessages.field(error, 'preferred_activity_keys.1'), isNull);
    expect(ErrorMessages.field(error, 'nickname'), isNull);
  });

  test('maps nested availability errors without confusing sibling fields', () {
    final error = ApiException(
      statusCode: 422,
      code: ApiErrorCode.validationError,
      details: {
        'fields': [
          {'field': 'body.slots.1.weekday', 'code': 'out_of_range'},
          {'field': 'body.exceptions.0.date', 'code': 'invalid_format'},
        ],
      },
    );
    expect(
      ErrorMessages.field(error, 'slots'),
      'Elige un valor dentro del rango permitido.',
    );
    expect(
      ErrorMessages.field(error, 'slots.1'),
      'Elige un valor dentro del rango permitido.',
    );
    expect(
      ErrorMessages.field(error, 'exceptions'),
      'Revisa el formato de este campo.',
    );
    expect(ErrorMessages.field(error, 'slots.0'), isNull);
    expect(ErrorMessages.field(error, 'slot'), isNull);
  });
}
