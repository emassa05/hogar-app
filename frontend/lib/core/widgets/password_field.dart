import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../validation/validators.dart';
import 'app_text_field.dart';

class PasswordField extends StatefulWidget {
  const PasswordField({
    this.controller,
    this.onChanged,
    this.errorText,
    this.label = AppStrings.password,
    this.newPassword = true,
    this.validator,
    this.enabled = true,
    super.key,
  });
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final String label;
  final bool newPassword;
  final bool enabled;
  final String? Function(String?)? validator;
  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;
  @override
  Widget build(BuildContext context) => AppTextField(
    label: widget.label,
    controller: widget.controller,
    onChanged: widget.onChanged,
    errorText: widget.errorText,
    enabled: widget.enabled,
    obscureText: _obscure,
    autofillHints: [
      widget.newPassword ? AutofillHints.newPassword : AutofillHints.password,
    ],
    validator:
        widget.validator ??
        (widget.newPassword
            ? PasswordValidator.validate
            : (value) => value == null || value.isEmpty
                  ? AppStrings.requiredField
                  : null),
    textInputAction: TextInputAction.done,
    suffix: IconButton(
      tooltip: _obscure ? AppStrings.showPassword : AppStrings.hidePassword,
      onPressed: widget.enabled
          ? () => setState(() => _obscure = !_obscure)
          : null,
      icon: Icon(
        _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
      ),
    ),
  );
}
