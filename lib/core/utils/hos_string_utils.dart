/// 常用字符串工具。
abstract final class SHOStringUtils {
  static bool isBlank(String? value) =>
      value == null || value.trim().isEmpty;

  static bool isNotBlank(String? value) => !isBlank(value);

  static String orEmpty(String? value) => value ?? '';

  static String truncate(String value, int maxLength, {String suffix = '...'}) {
    if (value.length <= maxLength) return value;
    return '${value.substring(0, maxLength)}$suffix';
  }

  static String maskPhone(String phone) {
    if (phone.length < 7) return phone;
    return '${phone.substring(0, 3)}****${phone.substring(phone.length - 4)}';
  }

  static String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final name = parts[0];
    if (name.length <= 2) return '**@${parts[1]}';
    return '${name.substring(0, 2)}***@${parts[1]}';
  }

  static String capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  static int? toIntOrNull(String? value) => int.tryParse(value ?? '');

  static double? toDoubleOrNull(String? value) => double.tryParse(value ?? '');
}
