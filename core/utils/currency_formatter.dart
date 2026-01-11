import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(int amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  static String formatWithDecimal(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  static int parse(String value) {
    final cleanValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(cleanValue) ?? 0;
  }
}