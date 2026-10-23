class AvailableProductModel {
  final String id;
  final String company;
  final String productId;
  final String name;
  final String category;
  final String unit;
  final String hsnCode;
  final double gstPercent;
  final double purchasePrice;
  final double salePrice;
  final String priceBasis;
  final int minimumStock;
  final int currentStock;
  final double preformWeightGrams;
  final int pcsPerBox;
  final String packagingRuleKey;
  final bool isActive;

  const AvailableProductModel({
    required this.id,
    required this.company,
    required this.productId,
    required this.name,
    required this.category,
    required this.unit,
    required this.hsnCode,
    required this.gstPercent,
    required this.purchasePrice,
    required this.salePrice,
    required this.priceBasis,
    required this.minimumStock,
    required this.currentStock,
    required this.preformWeightGrams,
    required this.pcsPerBox,
    required this.packagingRuleKey,
    required this.isActive,
  });

  factory AvailableProductModel.fromJson(Map<String, dynamic> json) {
    return AvailableProductModel(
      id: json['_id']?.toString() ?? '',
      company: json['company']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      unit: json['unit']?.toString() ?? '',
      hsnCode: json['hsnCode']?.toString() ?? '',
      gstPercent: (json['gstPercent'] as num?)?.toDouble() ?? 0.0,
      purchasePrice: (json['purchasePrice'] as num?)?.toDouble() ?? 0.0,
      salePrice: (json['salePrice'] as num?)?.toDouble() ?? 0.0,
      priceBasis: json['priceBasis']?.toString() ?? '',
      minimumStock: (json['minimumStock'] as num?)?.toInt() ?? 0,
      currentStock: (json['currentStock'] as num?)?.toInt() ?? 0,
      preformWeightGrams: (json['preformWeightGrams'] as num?)?.toDouble() ?? 0.0,
      pcsPerBox: (json['pcsPerBox'] as num?)?.toInt() ?? 0,
      packagingRuleKey: json['packagingRuleKey']?.toString() ?? '',
      isActive: json['isActive'] == true,
    );
  }
}
