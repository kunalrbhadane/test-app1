class NumberToWordsHelper {
  static const List<String> _units = [
    '',
    'One',
    'Two',
    'Three',
    'Four',
    'Five',
    'Six',
    'Seven',
    'Eight',
    'Nine',
    'Ten',
    'Eleven',
    'Twelve',
    'Thirteen',
    'Fourteen',
    'Fifteen',
    'Sixteen',
    'Seventeen',
    'Eighteen',
    'Nineteen',
  ];

  static const List<String> _tens = [
    '',
    '',
    'Twenty',
    'Thirty',
    'Forty',
    'Fifty',
    'Sixty',
    'Seventy',
    'Eighty',
    'Ninety',
  ];

  static String convert(double amount) {
    if (amount == 0) return 'Zero Rupees Only';

    final int integerPart = amount.floor();
    final int decimalPart = ((amount - integerPart) * 100).round();

    String words = _convertInteger(integerPart);
    if (words.isEmpty) {
      words = 'Zero';
    }

    words = '$words Rupees';

    if (decimalPart > 0) {
      final String paiseWords = _convertInteger(decimalPart);
      words = '$words and $paiseWords Paise';
    }

    return '$words Only';
  }

  static String _convertInteger(int n) {
    if (n == 0) return '';

    if (n < 20) {
      return _units[n];
    }

    if (n < 100) {
      return '${_tens[n ~/ 10]}${n % 10 != 0 ? ' ${_units[n % 10]}' : ''}';
    }

    if (n < 1000) {
      return '${_units[n ~/ 100]} Hundred${n % 100 != 0 ? ' ${_convertInteger(n % 100)}' : ''}';
    }

    if (n < 100000) {
      return '${_convertInteger(n ~/ 1000)} Thousand${n % 1000 != 0 ? ' ${_convertInteger(n % 1000)}' : ''}';
    }

    if (n < 10000000) {
      return '${_convertInteger(n ~/ 100000)} Lakh${n % 100000 != 0 ? ' ${_convertInteger(n % 100000)}' : ''}';
    }

    return '${_convertInteger(n ~/ 10000000)} Crore${n % 10000000 != 0 ? ' ${_convertInteger(n % 10000000)}' : ''}';
  }
}
