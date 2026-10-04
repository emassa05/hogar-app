import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_typography.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.label,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.validator,
    this.errorText,
    this.helperText,
    this.hintText,
    this.suffix,
    this.prefix,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.inputFormatters,
    this.maxLength,
    this.obscureText = false,
    this.enabled = true,
    this.focusNode,
    this.onSubmitted,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    super.key,
  });
  final String label;
  final TextEditingController? controller;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final String? errorText;
  final String? helperText;
  final String? hintText;
  final Widget? suffix;
  final Widget? prefix;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final bool obscureText;
  final bool enabled;
  final FocusNode? focusNode;
  final ValueChanged<String>? onSubmitted;
  final AutovalidateMode autovalidateMode;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(label, style: AppTypography.bodySmall),
      const SizedBox(height: 8),
      Semantics(
        label: label,
        child: TextFormField(
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          onChanged: onChanged,
          validator: validator,
          forceErrorText: errorText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          obscureText: obscureText,
          enableSuggestions: !obscureText,
          autocorrect: !obscureText,
          enabled: enabled,
          focusNode: focusNode,
          onFieldSubmitted: onSubmitted,
          autovalidateMode: autovalidateMode,
          style: AppTypography.bodyMedium,
          decoration: InputDecoration(
            hintText: hintText,
            helperText: helperText,
            helperMaxLines: 5,
            suffixIcon: suffix,
            prefixIcon: prefix,
            counterStyle: AppTypography.dataSmall,
          ),
        ),
      ),
    ],
  );
}
