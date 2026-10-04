import '../l10n/app_strings.dart';

abstract final class PhoneValidator {
  static const defaultCountryCode = '+56';
  static final _format = RegExp(r'^\+[1-9]\d{7,14}$');

  static String normalize(String value, {String countryCode = defaultCountryCode}) {
    final compact = value.trim().replaceAll(RegExp(r'[\s()-]'), '');
    return compact.startsWith('+') ? compact : '$countryCode$compact';
  }

  static bool isValid(String value) => _format.hasMatch(normalize(value));
  static String? validate(String? value) => value == null || value.trim().isEmpty ? AppStrings.requiredField : isValid(value) ? null : AppStrings.invalidPhone;
}

class PasswordRules {
  PasswordRules(String value) : value = value.trim();

  final String value;
  bool get hasLength => value.runes.length >= 8 && value.runes.length <= 128;
  bool get hasUppercase => RegExp(r'[A-Z]').hasMatch(value);
  bool get hasDigitOrSymbol => RegExp(r'[0-9]|[^a-zA-Z0-9\s]').hasMatch(value);
  bool get isValid => hasLength && hasUppercase && hasDigitOrSymbol;
  int get score => isValid ? 4 : [hasLength, hasUppercase, hasDigitOrSymbol].where((rule) => rule).length;
}

abstract final class PasswordValidator {
  static String? validate(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.requiredField;
    final rules = PasswordRules(value);
    if (!rules.hasLength) return AppStrings.passwordLength;
    if (!rules.hasUppercase) return AppStrings.passwordUppercase;
    if (!rules.hasDigitOrSymbol) return AppStrings.passwordDigitOrSymbol;
    return null;
  }
}

abstract final class NameValidator {
  static String? validate(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return AppStrings.requiredField;
    return name.runes.length > 40 ? AppStrings.nameLength : null;
  }
}

abstract final class CodeValidator {
  static bool isValidOtp(String value) => RegExp(r'^\d{6}$').hasMatch(value);
  static String normalizeInvitation(String value) => value.toUpperCase().replaceAll(RegExp(r'[\s-]'), '');
  static bool isValidInvitation(String value) => RegExp(r'^[0-9A-HJKMNP-TV-Z]{8}$').hasMatch(normalizeInvitation(value));
  static String displayInvitation(String value) {
    final code = normalizeInvitation(value);
    return code.length == 8 ? '${code.substring(0, 4)}-${code.substring(4)}' : value;
  }
}
