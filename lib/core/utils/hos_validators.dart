import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// 表单校验器集合，配合 [SHOAppTextField.validator] 使用。
///
/// ```dart
/// SHOAppTextField(
///   validator: SHOValidators.compose([
///     SHOValidators.required(l10n),
///     SHOValidators.phone(l10n),
///   ]),
/// )
/// ```
abstract final class SHOValidators {
  static String? Function(String?) required(AppLocalizations l10n) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return l10n.validationRequired;
      }
      return null;
    };
  }

  static String? Function(String?) phone(AppLocalizations l10n) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      final phone = value.trim();
      final ok = RegExp(r'^1[3-9]\d{9}$').hasMatch(phone) ||
          RegExp(r'^\+\d{8,15}$').hasMatch(phone);
      return ok ? null : l10n.validationPhone;
    };
  }

  static String? Function(String?) email(AppLocalizations l10n) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      final ok = RegExp(r'^[\w.+-]+@[\w.-]+\.\w+$').hasMatch(value.trim());
      return ok ? null : l10n.validationEmail;
    };
  }

  static String? Function(String?) minLength(
    AppLocalizations l10n,
    int length,
  ) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      return value.length >= length ? null : l10n.validationMinLength(length);
    };
  }

  static String? Function(String?) compose(
    List<String? Function(String?)> validators,
  ) {
    return (value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}

/// 在 [Form] 中统一校验并聚焦第一个错误字段。
class SHOFormHelper {
  static bool validateAndFocus(GlobalKey<FormState> formKey) {
    final form = formKey.currentState;
    if (form == null) return false;
    return form.validate();
  }
}
