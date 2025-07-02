void main() {
  // GTIN checksum validation
  bool isValidGTIN(String gtin) {
    if (gtin.isEmpty) return false;

    try {
      List<int> digits = gtin.split('').map((e) => int.parse(e)).toList();

      int sum = 0;
      bool multiply3 = gtin.length % 2 == 0;

      for (int i = 0; i < digits.length - 1; i++) {
        if (multiply3) {
          sum += digits[i] * 3;
        } else {
          sum += digits[i] * 1;
        }
        multiply3 = !multiply3;
      }

      int checkDigit = (10 - (sum % 10)) % 10;
      return checkDigit == digits.last;
    } catch (e) {
      return false;
    }
  }

  List<String> testGtins = [
    '2102000140000',
    '8850124024725',
    '9506000140445',
    '6285561001275',
  ];

  for (String gtin in testGtins) {
    print('GTIN: $gtin - Valid: ${isValidGTIN(gtin)}');
  }
}
