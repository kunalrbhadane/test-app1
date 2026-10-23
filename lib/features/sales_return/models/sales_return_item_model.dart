class SalesReturnItemModel {
  final String id;
  final String productId;
  final String name;
  final int totalQty;
  final double rate;
  final double gstPercent;
  final double amount;
  final int returnQty;
  final int alreadyReturnedQty;

  const SalesReturnItemModel({
    required this.id,
    this.productId = '',
    required this.name,
    required this.totalQty,
    this.rate = 0.0,
    this.gstPercent = 0.0,
    required this.amount,
    required this.returnQty,
    this.alreadyReturnedQty = 0,
  });

  int get maxReturnableQty =>
      totalQty > alreadyReturnedQty ? (totalQty - alreadyReturnedQty) : 0;

  double get returnAmount {
    if (returnQty <= 0) return 0.0;
    if (totalQty > 0) {
      return (amount / totalQty) * returnQty;
    }
    return rate * returnQty;
  }

  SalesReturnItemModel copyWith({
    String? id,
    String? productId,
    String? name,
    int? totalQty,
    double? rate,
    double? gstPercent,
    double? amount,
    int? returnQty,
    int? alreadyReturnedQty,
  }) {
    return SalesReturnItemModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      totalQty: totalQty ?? this.totalQty,
      rate: rate ?? this.rate,
      gstPercent: gstPercent ?? this.gstPercent,
      amount: amount ?? this.amount,
      returnQty: returnQty ?? this.returnQty,
      alreadyReturnedQty: alreadyReturnedQty ?? this.alreadyReturnedQty,
    );
  }
}
