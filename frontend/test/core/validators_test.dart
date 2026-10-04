import 'package:flutter_test/flutter_test.dart';
import 'package:hogar_app/core/validation/validators.dart';

void main() {
  test(
    'normalizes Chile phone numbers and preserves E.164 international numbers',
    () {
      expect(PhoneValidator.normalize('9 8765 4321'), '+56987654321');
      expect(PhoneValidator.normalize('+1 (212) 555-1234'), '+12125551234');
      expect(PhoneValidator.isValid('+56987654321'), isTrue);
      for (final value in [
        '',
        '+012345678',
        '+1234567',
        '+1234567890123456',
        'letters',
      ]) {
        expect(PhoneValidator.validate(value), isNotNull);
      }
    },
  );
  test('password follows length, uppercase, and digit or symbol rules', () {
    expect(PasswordValidator.validate('Segura12'), isNull);
    expect(PasswordValidator.validate('Segura!?'), isNull);
    expect(PasswordRules('Segura12').score, 4);
    for (final value in [
      'Corta1',
      'minuscula1',
      'Mayusculas',
      'A1${'a' * 127}',
    ]) {
      expect(PasswordValidator.validate(value), isNotNull);
    }
  });
  test('names are trimmed and limited to forty Unicode codepoints', () {
    expect(NameValidator.validate(' Marta '), isNull);
    expect(NameValidator.validate(' '), isNotNull);
    expect(NameValidator.validate('a' * 40), isNull);
    expect(NameValidator.validate('a' * 41), isNotNull);
    expect(NameValidator.validate('😀' * 40), isNull);
  });
  test('SMS and Crockford invitation codes have distinct formats', () {
    expect(CodeValidator.isValidOtp('482715'), isTrue);
    expect(CodeValidator.isValidOtp('48271a'), isFalse);
    expect(CodeValidator.displayInvitation('7qk2 m9xa'), '7QK2-M9XA');
    expect(CodeValidator.isValidInvitation('7qk2-m9xa'), isTrue);
    expect(CodeValidator.isValidInvitation('IIII-OOOO'), isFalse);
  });
}
