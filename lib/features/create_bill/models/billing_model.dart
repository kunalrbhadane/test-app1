class BillingLineItem {
  final String product;
  final int qty;
  final double rate;
  final double? gstPercent;
  final double? lineTotal;
  final String? batchNumber;

  const BillingLineItem({
    required this.product,
    required this.qty,
    required this.rate,
    this.gstPercent,
    this.lineTotal,
    this.batchNumber,
  });

  factory BillingLineItem.fromJson(Map<String, dynamic> json) {
    return BillingLineItem(
      product: json['product']?.toString() ?? '',
      qty: (json['qty'] as num?)?.toInt() ?? 0,
      rate: (json['rate'] as num?)?.toDouble() ?? 0.0,
      gstPercent: (json['gstPercent'] as num?)?.toDouble(),
      lineTotal: (json['lineTotal'] as num?)?.toDouble(),
      batchNumber: json['batchNumber']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product,
      'qty': qty,
      'rate': rate,
      if (gstPercent != null) 'gstPercent': gstPercent,
      if (lineTotal != null) 'lineTotal': lineTotal,
      if (batchNumber != null && batchNumber!.isNotEmpty) 'batchNumber': batchNumber,
    };
  }
}

class BillingModel {
  final String? id;
  final String company;
  final String invoiceNo;
  final String mode; // 'kaccha' or 'pakka'
  final String? walkInName;
  final String? customer;
  final List<BillingLineItem> lines;
  final double subTotal;
  final double gstAmount;
  final double totalAmount;
  final String paymentMode; // 'cash', 'upi', 'bank_transfer', 'cheque'
  final double amountPaid;
  final double dueAmount;
  final String? discountType; // 'flat' or 'percentage'
  final double? discountRate;
  final double? discountAmount;
  final int? totalQty;
  final String? paymentStatus;
  final String? createdBy;
  final bool? pushedToTally;
  final String? date;
  final String? createdAt;
  final String? updatedAt;

  const BillingModel({
    this.id,
    required this.company,
    required this.invoiceNo,
    required this.mode,
    this.walkInName,
    this.customer,
    required this.lines,
    this.subTotal = 0.0,
    this.gstAmount = 0.0,
    this.totalAmount = 0.0,
    required this.paymentMode,
    required this.amountPaid,
    this.dueAmount = 0.0,
    this.discountType,
    this.discountRate,
    this.discountAmount,
    this.totalQty,
    this.paymentStatus,
    this.createdBy,
    this.pushedToTally,
    this.date,
    this.createdAt,
    this.updatedAt,
  });

  factory BillingModel.fromJson(Map<String, dynamic> json) {
    return BillingModel(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      company: json['company']?.toString() ?? '',
      invoiceNo: json['invoiceNo']?.toString() ?? '',
      mode: json['mode']?.toString() ?? 'kaccha',
      walkInName: json['walkInName']?.toString(),
      customer: json['customer']?.toString(),
      lines: (json['lines'] as List<dynamic>?)
              ?.map((item) =>
                  BillingLineItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      subTotal: (json['subTotal'] as num?)?.toDouble() ?? 0.0,
      gstAmount: (json['gstAmount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      paymentMode: json['paymentMode']?.toString() ?? 'cash',
      amountPaid: (json['amountPaid'] as num?)?.toDouble() ?? 0.0,
      dueAmount: (json['dueAmount'] as num?)?.toDouble() ?? 0.0,
      discountType: json['discountType']?.toString(),
      discountRate: (json['discountRate'] as num?)?.toDouble(),
      discountAmount: (json['discountAmount'] as num?)?.toDouble(),
      totalQty: (json['totalQty'] as num?)?.toInt(),
      paymentStatus: json['paymentStatus']?.toString(),
      createdBy: json['createdBy']?.toString(),
      pushedToTally: json['pushedToTally'] as bool?,
      date: json['date']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'company': company,
      'invoiceNo': invoiceNo,
      'mode': mode,
      if (walkInName != null && walkInName!.isNotEmpty)
        'walkInName': walkInName,
      if (customer != null && customer!.isNotEmpty) 'customer': customer,
      'lines': lines.map((l) => l.toJson()).toList(),
      'paymentMode': paymentMode,
      'amountPaid': amountPaid,
      'discountType': discountType ?? 'percentage',
      'discountRate': discountRate ?? 0,
      if (subTotal > 0) 'subTotal': subTotal,
      if (gstAmount > 0) 'gstAmount': gstAmount,
      if (totalAmount > 0) 'totalAmount': totalAmount,
    };
  }
}
