import 'package:intl/intl.dart';

/// Formats integer cents into display currency strings.
class SHOPriceFormatter {
  SHOPriceFormatter({String locale = 'en_US', String symbol = r'$'})
      : _formatter = NumberFormat.currency(
          locale: locale,
          symbol: symbol,
          decimalDigits: 2,
        );

  final NumberFormat _formatter;

  String formatCents(int cents) => _formatter.format(cents / 100);

  String formatDiscount(int priceCents, int originalCents) {
    if (originalCents <= 0 || priceCents >= originalCents) return '';
    final percent = ((1 - priceCents / originalCents) * 100).round();
    return '-$percent%';
  }

  static String compactCount(int count) {
    if (count >= 10000) {
      return '${(count / 1000).toStringAsFixed(1)}k sold';
    }
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k sold';
    }
    return '$count sold';
  }
}

final priceFormatter = SHOPriceFormatter();
