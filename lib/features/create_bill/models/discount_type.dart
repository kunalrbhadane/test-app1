enum DiscountType {
  percentage('percentage'),
  flat('flat');

  final String value;
  const DiscountType(this.value);

  static DiscountType fromString(String? val) {
    if (val?.toLowerCase() == 'flat') return DiscountType.flat;
    return DiscountType.percentage;
  }
}
