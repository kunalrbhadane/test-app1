class SizeMasterBottleModel {
  final String id;
  final String company;
  final String productId;
  final String name;
  final String? category;
  final String? unit;
  final String? hsnCode;
  final double gstPercent;
  final double purchasePrice;
  final double salePrice;
  final String? priceBasis;
  final int minimumStock;
  final int currentStock;
  final double preformWeightGrams;
  final int pcsPerBox;
  final String? packagingRuleKey;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;

  const SizeMasterBottleModel({
    required this.id,
    required this.company,
    required this.productId,
    required this.name,
    this.category,
    this.unit,
    this.hsnCode,
    this.gstPercent = 0.0,
    this.purchasePrice = 0.0,
    this.salePrice = 0.0,
    this.priceBasis,
    this.minimumStock = 0,
    this.currentStock = 0,
    this.preformWeightGrams = 0.0,
    this.pcsPerBox = 0,
    this.packagingRuleKey,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory SizeMasterBottleModel.fromJson(Map<String, dynamic> json) {
    return SizeMasterBottleModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      company: json['company']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString(),
      unit: json['unit']?.toString(),
      hsnCode: json['hsnCode']?.toString(),
      gstPercent: (json['gstPercent'] as num?)?.toDouble() ?? 0.0,
      purchasePrice: (json['purchasePrice'] as num?)?.toDouble() ?? 0.0,
      salePrice: (json['salePrice'] as num?)?.toDouble() ?? 0.0,
      priceBasis: json['priceBasis']?.toString(),
      minimumStock: (json['minimumStock'] as num?)?.toInt() ?? 0,
      currentStock: (json['currentStock'] as num?)?.toInt() ?? 0,
      preformWeightGrams: (json['preformWeightGrams'] as num?)?.toDouble() ?? 0.0,
      pcsPerBox: (json['pcsPerBox'] as num?)?.toInt() ?? 0,
      packagingRuleKey: json['packagingRuleKey']?.toString(),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'company': company,
      'productId': productId,
      'name': name,
      if (category != null) 'category': category,
      if (unit != null) 'unit': unit,
      if (hsnCode != null) 'hsnCode': hsnCode,
      'gstPercent': gstPercent,
      'purchasePrice': purchasePrice,
      'salePrice': salePrice,
      if (priceBasis != null) 'priceBasis': priceBasis,
      'minimumStock': minimumStock,
      'currentStock': currentStock,
      'preformWeightGrams': preformWeightGrams,
      'pcsPerBox': pcsPerBox,
      if (packagingRuleKey != null) 'packagingRuleKey': packagingRuleKey,
      'isActive': isActive,
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }
}
