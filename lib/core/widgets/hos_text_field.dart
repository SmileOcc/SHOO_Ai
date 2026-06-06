import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/hos_colors.dart';
import '../theme/hos_spacing.dart';
import '../theme/hos_theme_extension.dart';
import '../theme/hos_typography.dart';

/// 统一输入框组件。
///
/// 参考文章第三步：统一边框、错误提示、字数统计、前缀/后缀图标。
/// 通过 [didUpdateWidget] 同步外部传入的 [error]，避免错误态不刷新。
///
/// ```dart
/// SHOAppTextField(
///   label: 'Email',
///   hint: 'Enter your email',
///   controller: _emailController,
///   keyboardType: TextInputType.emailAddress,
///   prefixIcon: const Icon(Icons.email_outlined, size: 18),
///   error: _emailError,
///   onChanged: (_) => setState(() => _emailError = null),
/// )
///
/// // 密码框 + 显示切换
/// SHOAppTextField(
///   label: 'Password',
///   obscureText: !_showPassword,
///   suffixIcon: IconButton(
///     icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
///     onPressed: () => setState(() => _showPassword = !_showPassword),
///   ),
/// )
///
/// // 搜索框
/// SHOAppTextField(
///   hint: 'Search styles...',
///   prefixIcon: const Icon(Icons.search, size: 18),
///   maxLength: 50,
/// )
/// ```
class SHOAppTextField extends StatefulWidget {
  const SHOAppTextField({
    super.key,
    this.label,
    this.hint,
    this.error,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.maxLines = 1,
    this.readOnly = false,
    this.autofocus = false,
    this.inputFormatters,
  });

  final String? label;
  final String? hint;
  final String? error;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool readOnly;
  final bool autofocus;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<SHOAppTextField> createState() => _SHOAppTextFieldState();
}

class _SHOAppTextFieldState extends State<SHOAppTextField> {
  late bool _hasError;

  @override
  void initState() {
    super.initState();
    _hasError = widget.error != null;
  }

  @override
  void didUpdateWidget(SHOAppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.error != widget.error) {
      setState(() => _hasError = widget.error != null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(SHOAppSpacing.buttonRadius);
    final theme = context.shoTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: SHOAppTypography.textTheme.labelLarge,
          ),
          const SizedBox(height: SHOAppSpacing.xs),
        ],
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          maxLength: widget.maxLength,
          maxLines: widget.maxLines,
          readOnly: widget.readOnly,
          autofocus: widget.autofocus,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          validator: widget.validator,
          inputFormatters: widget.inputFormatters,
          style: SHOAppTypography.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: SHOAppTypography.textTheme.bodyMedium,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.suffixIcon,
            errorText: _hasError ? widget.error : null,
            counterText: widget.maxLength != null ? '' : null,
            filled: true,
            fillColor: theme.surfaceMuted,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: SHOAppSpacing.lg,
              vertical: SHOAppSpacing.md,
            ),
            border: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(color: theme.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(color: theme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: const BorderSide(color: SHOAppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: const BorderSide(color: SHOAppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: const BorderSide(color: SHOAppColors.error, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
