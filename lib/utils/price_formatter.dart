import 'package:intl/intl.dart';

class PriceFormatter {
  // Formats a price using the given currency symbol (default: $)
  static String format(double value, {String symbol = r'$'}) {
    final fmt = NumberFormat.currency(symbol: symbol, decimalDigits: 2);
    return fmt.format(value);
  }
}
