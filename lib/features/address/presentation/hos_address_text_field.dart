import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/hos_colors.dart';
import '../../../core/theme/hos_spacing.dart';
import '../../../core/theme/hos_theme_extension.dart';

/// 地址表单专用输入框：圆角 6、必填红 *、失焦校验。
class SHOAddressTextField extends StatefulWidget {
  const SHOAddressTextField({
    super.key,
    required this.label,
    required this.controller,
    this.required = false,
    this.hint,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.inputFormatters,
  });

  static const double borderRadius = 6;

  final String label;
  final TextEditingController controller;
  final bool required;
  final String? hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<SHOAddressTextField> createState() => _SHOAddressTextFieldState();
}

class _SHOAddressTextFieldState extends State<SHOAddressTextField> {
  final _fieldKey = GlobalKey<FormFieldState<String>>();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus && widget.validator != null) {
      _fieldKey.currentState?.validate();
    }
  }

  void _validateOnEnd() {
    if (widget.validator != null) {
      _fieldKey.currentState?.validate();
    }
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.shoTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(SHOAddressTextField.borderRadius);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.label,
              style: textTheme.labelLarge,
            ),
            if (widget.required)
              Text(
                ' *',
                style: textTheme.labelLarge?.copyWith(
                  color: SHOAppColors.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
        const SizedBox(height: SHOAppSpacing.xs),
        TextFormField(
          key: _fieldKey,
          controller: widget.controller,
          focusNode: _focusNode,
          keyboardType: widget.keyboardType,
          maxLines: widget.maxLines,
          inputFormatters: widget.inputFormatters,
          validator: widget.validator,
          onTapOutside: (_) => _validateOnEnd(),
          onEditingComplete: _validateOnEnd,
          style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
          cursorColor: colorScheme.onSurface,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.45),
            ),
            filled: true,
            fillColor: theme.surfaceMuted,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: SHOAppSpacing.lg,
              vertical: SHOAppSpacing.md,
            ),
            border: OutlineInputBorder(
              borderRadius: radius,
              borderSide: BorderSide(color: theme.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: BorderSide(color: theme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: BorderSide(color: colorScheme.onSurface, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: const BorderSide(color: SHOAppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide:
                  const BorderSide(color: SHOAppColors.error, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
