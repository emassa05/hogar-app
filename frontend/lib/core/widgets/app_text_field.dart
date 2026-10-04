import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_typography.dart';
import 'app_icon.dart';
import 'field_message.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    required this.label,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.validator,
    this.errorText,
    this.helperText,
    this.helperIcon,
    this.successText,
    this.hintText,
    this.suffix,
    this.prefix,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.inputFormatters,
    this.maxLength,
    this.showCounter = false,
    this.obscureText = false,
    this.enabled = true,
    this.compact = false,
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
  final AppIcons? helperIcon;
  final String? successText;
  final String? hintText;
  final Widget? suffix;
  final Widget? prefix;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final bool showCounter;
  final bool obscureText;
  final bool enabled;
  final bool compact;
  final FocusNode? focusNode;
  final ValueChanged<String>? onSubmitted;
  final AutovalidateMode autovalidateMode;
  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  TextEditingController? _ownController;
  FocusNode? _ownFocus;
  final _fieldKey = GlobalKey<FormFieldState<String>>();

  TextEditingController get _controller =>
      widget.controller ??
      (_ownController ??= TextEditingController(text: widget.initialValue));
  FocusNode get _focus => widget.focusNode ?? (_ownFocus ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _focus.addListener(_refresh);
    _controller.addListener(_sync);
  }

  @override
  void didUpdateWidget(covariant AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _ownFocus)?.removeListener(_refresh);
      _focus.addListener(_refresh);
    }
    if (oldWidget.controller != widget.controller) {
      (oldWidget.controller ?? _ownController)?.removeListener(_sync);
      _controller.addListener(_sync);
    }
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _sync() {
    final field = _fieldKey.currentState;
    if (field != null && field.value != _controller.text) {
      field.didChange(_controller.text);
    } else {
      _refresh();
    }
  }

  @override
  void dispose() {
    _focus.removeListener(_refresh);
    _controller.removeListener(_sync);
    _ownController?.dispose();
    _ownFocus?.dispose();
    super.dispose();
  }

  BoxDecoration _decoration(String? error) {
    final radius = BorderRadius.circular(
      widget.compact ? AppRadius.medium : AppRadius.large,
    );
    if (!widget.enabled) {
      return BoxDecoration(
        color: AppColors.sunken,
        borderRadius: radius,
        border: Border.all(color: AppColors.borderSubtle),
      );
    }
    if (error != null) {
      return BoxDecoration(
        color: AppColors.dangerSubtle,
        borderRadius: radius,
        border: Border.all(color: AppColors.borderDanger, width: 1.5),
        boxShadow: AppShadows.dangerRing,
      );
    }
    if (_focus.hasFocus) {
      return BoxDecoration(
        color: AppColors.surface,
        borderRadius: radius,
        border: Border.all(color: AppColors.focus, width: 1.5),
        boxShadow: AppShadows.focusRing,
      );
    }
    if (widget.successText != null) {
      return BoxDecoration(
        color: AppColors.surface,
        borderRadius: radius,
        border: Border.all(color: AppColors.borderSuccess, width: 1.5),
      );
    }
    return BoxDecoration(
      color: AppColors.surface,
      borderRadius: radius,
      border: Border.all(
        color: widget.compact ? AppColors.borderStrong : AppColors.border,
      ),
      boxShadow: widget.compact ? null : AppShadows.field,
    );
  }

  TextStyle _textStyle(String? error) {
    final base = widget.obscureText
        ? AppTypography.obscuredInput
        : widget.compact
        ? AppTypography.fieldInputCompact
        : AppTypography.fieldInput;
    if (!widget.enabled) return base.copyWith(color: AppColors.textDisabled);
    return error == null ? base : base.copyWith(color: AppColors.danger);
  }

  Widget _box(FormFieldState<String> field) {
    final error = field.errorText;
    final counter = widget.showCounter && widget.maxLength != null
        ? '${_controller.text.characters.length}/${widget.maxLength}'
        : null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.enabled ? _focus.requestFocus : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        constraints: BoxConstraints(minHeight: widget.compact ? 48 : 56),
        padding: EdgeInsets.symmetric(horizontal: widget.compact ? 14 : 16),
        decoration: _decoration(error),
        child: Row(
          children: [
            if (widget.prefix != null) ...[
              widget.prefix!,
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Semantics(
                  label: widget.label,
                  child: TextField(
                    controller: _controller,
                    focusNode: _focus,
                    onChanged: (value) {
                      field.didChange(value);
                      widget.onChanged?.call(value);
                    },
                    keyboardType: widget.keyboardType,
                    textInputAction: widget.textInputAction,
                    textCapitalization: widget.textCapitalization,
                    autofillHints: widget.enabled ? widget.autofillHints : null,
                    inputFormatters: [
                      ...?widget.inputFormatters,
                      if (widget.maxLength != null)
                        LengthLimitingTextInputFormatter(widget.maxLength),
                    ],
                    obscureText: widget.obscureText,
                    obscuringCharacter: '•',
                    enableSuggestions: !widget.obscureText,
                    autocorrect: !widget.obscureText,
                    enabled: widget.enabled,
                    onSubmitted: widget.onSubmitted,
                    style: _textStyle(error),
                    cursorColor: AppColors.brand,
                    cursorWidth: 2,
                    cursorRadius: const Radius.circular(1),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      hintText: widget.hintText,
                      hintStyle: _textStyle(
                        null,
                      ).copyWith(color: AppColors.textDisabled),
                    ),
                  ),
                ),
              ),
            ),
            if (counter != null) ...[
              const SizedBox(width: 10),
              ExcludeSemantics(
                child: Text(counter, style: AppTypography.dataSmall),
              ),
            ],
            if (widget.suffix != null) ...[
              const SizedBox(width: 10),
              widget.suffix!,
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => FormField<String>(
    key: _fieldKey,
    initialValue: _controller.text,
    validator: widget.validator,
    forceErrorText: widget.errorText,
    autovalidateMode: widget.autovalidateMode,
    enabled: widget.enabled,
    builder: (field) {
      final error = field.errorText;
      final message = error != null
          ? FieldMessage.error(error)
          : widget.successText != null
          ? FieldMessage.success(widget.successText!)
          : widget.helperText != null
          ? FieldMessage.helper(widget.helperText!, icon: widget.helperIcon)
          : null;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ExcludeSemantics(
            child: Text(
              widget.label,
              style: widget.compact
                  ? AppTypography.labelMedium
                  : AppTypography.fieldLabel,
            ),
          ),
          SizedBox(height: widget.compact ? 6 : 8),
          _box(field),
          if (message != null) ...[
            SizedBox(height: widget.compact ? 6 : 8),
            message,
          ],
        ],
      );
    },
  );
}
