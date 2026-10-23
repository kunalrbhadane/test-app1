class SelectedProductItem {
  final String id;
  final String? productId;
  final String name;
  final int quantity;
  final double rate;
  final double totalAmount;
  final String? hsnCode;
  final String? unit;
  final double gstPercent;
  final int pcsPerBox;
  final String? packagingRuleKey;
  final String? category;
  final int currentStock;
  final String? batchNumber;

  const SelectedProductItem({
    required this.id,
    this.productId,
    required this.name,
    required this.quantity,
    required this.rate,
    required this.totalAmount,
    this.hsnCode,
    this.unit,
    this.gstPercent = 0.0,
    this.pcsPerBox = 0,
    this.packagingRuleKey,
    this.category,
    this.currentStock = 0,
    this.batchNumber,
  });

  SelectedProductItem copyWith({
    String? id,
    String? productId,
    String? name,
    int? quantity,
    double? rate,
    double? totalAmount,
    String? hsnCode,
    String? unit,
    double? gstPercent,
    int? pcsPerBox,
    String? packagingRuleKey,
    String? category,
    int? currentStock,
    String? batchNumber,
  }) {
    return SelectedProductItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      rate: rate ?? this.rate,
      totalAmount: totalAmount ?? this.totalAmount,
      hsnCode: hsnCode ?? this.hsnCode,
      unit: unit ?? this.unit,
      gstPercent: gstPercent ?? this.gstPercent,
      pcsPerBox: pcsPerBox ?? this.pcsPerBox,
      packagingRuleKey: packagingRuleKey ?? this.packagingRuleKey,
      category: category ?? this.category,
      currentStock: currentStock ?? this.currentStock,
      batchNumber: batchNumber ?? this.batchNumber,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'name': name,
      'quantity': quantity,
      'rate': rate,
      'totalAmount': totalAmount,
      'hsnCode': hsnCode,
      'unit': unit,
      'gstPercent': gstPercent,
      'pcsPerBox': pcsPerBox,
      'packagingRuleKey': packagingRuleKey,
      'category': category,
      'currentStock': currentStock,
      'batchNumber': batchNumber,
    };
  }

  factory SelectedProductItem.fromMap(Map<String, dynamic> map) {
    return SelectedProductItem(
      id: map['id']?.toString() ?? '',
      productId: map['productId']?.toString(),
      name: map['name']?.toString() ?? '',
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      rate: (map['rate'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      hsnCode: map['hsnCode']?.toString(),
      unit: map['unit']?.toString(),
      gstPercent: (map['gstPercent'] as num?)?.toDouble() ?? 0.0,
      pcsPerBox: (map['pcsPerBox'] as num?)?.toInt() ?? 0,
      packagingRuleKey: map['packagingRuleKey']?.toString(),
      category: map['category']?.toString(),
      currentStock: (map['currentStock'] as num?)?.toInt() ?? 0,
      batchNumber: map['batchNumber']?.toString(),
    );
  }
}

