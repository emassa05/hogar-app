import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../theme/app_colors.dart';
import '../validation/validators.dart';
import 'app_icon.dart';
import 'app_text_field.dart';

class PasswordField extends StatefulWidget {
  const PasswordField({
    this.controller,
    this.onChanged,
    this.errorText,
    this.successText,
    this.label = AppStrings.password,
    this.newPassword = true,
    this.validator,
    this.enabled = true,
    this.focusNode,
    this.onSubmitted,
    this.textInputAction = TextInputAction.done,
    super.key,
  });
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final String? successText;
  final String label;
  final bool newPassword;
  final bool enabled;
  final FocusNode? focusNode;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction textInputAction;
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
    successText: widget.successText,
    enabled: widget.enabled,
    focusNode: widget.focusNode,
    onSubmitted: widget.onSubmitted,
    obscureText: _obscure,
    maxLength: 128,
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
    textInputAction: widget.textInputAction,
    suffix: widget.successText != null
        ? const AppIcon(AppIcons.checkCircleLarge, color: AppColors.iconSuccess)
        : IconButton(
            tooltip: _obscure
                ? AppStrings.showPassword
                : AppStrings.hidePassword,
            onPressed: widget.enabled
                ? () => setState(() => _obscure = !_obscure)
                : null,
            padding: EdgeInsets.zero,
            alignment: Alignment.centerRight,
            constraints: const BoxConstraints.tightFor(width: 44, height: 48),
            icon: AppIcon(
              _obscure ? AppIcons.eye : AppIcons.eyeOff,
              color: AppColors.iconSecondary,
            ),
          ),
  );
}
