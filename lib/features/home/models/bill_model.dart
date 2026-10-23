import 'package:intl/intl.dart';

enum BillStatus { pending, paid, partial }

enum BillType { gstInvoice, cashMemo }

class BillLineItem {
  final String productId;
  final String productName;
  final String packagingRuleKey;
  final int qty;
  final double rate;
  final double gstPercent;
  final double lineTotal;
  final int returnedQty;
  final String? reason;

  const BillLineItem({
    this.productId = '',
    required this.productName,
    this.packagingRuleKey = '',
    this.qty = 0,
    this.rate = 0.0,
    this.gstPercent = 0.0,
    this.lineTotal = 0.0,
    this.returnedQty = 0,
    this.reason,
  });

  factory BillLineItem.fromJson(Map<String, dynamic> json) {
    String pName = '';
    String pId = '';
    String ruleKey = '';
    final prod = json['product'];
    if (prod is Map<String, dynamic>) {
      pId = prod['_id']?.toString() ?? '';
      pName = prod['name']?.toString() ?? '';
      ruleKey = prod['packagingRuleKey']?.toString() ?? '';
    } else if (prod is String) {
      pId = prod;
    }

    return BillLineItem(
      productId: pId,
      productName: pName,
      packagingRuleKey: ruleKey,
      qty: (json['qty'] as num?)?.toInt() ?? 0,
      rate: (json['rate'] as num?)?.toDouble() ?? 0.0,
      gstPercent: (json['gstPercent'] as num?)?.toDouble() ?? 0.0,
      lineTotal: (json['lineTotal'] as num?)?.toDouble() ?? 0.0,
      returnedQty: (json['returnedQty'] as num?)?.toInt() ?? 0,
      reason: json['reasone']?.toString() ?? json['reason']?.toString(),
    );
  }

  int get availableToReturnQty => qty > returnedQty ? (qty - returnedQty) : 0;

  String get displayName {
    if (packagingRuleKey.isNotEmpty && productName.isNotEmpty) {
      return '$productName ($packagingRuleKey)';
    }
    return productName.isNotEmpty ? productName : 'Product';
  }
}

class BillModel {
  final String id;
  final String invoiceNumber;
  final String date;
  final String partyName;
  final BillType type;
  final double amount;
  final BillStatus status;
  final String paymentMode;
  final String? customerCity;
  final String? companyName;
  final String? companyId;
  final String? createdByName;
  final double dueAmount;
  final double subTotal;
  final double gstAmount;
  final double amountPaid;
  final int totalQty;
  final List<BillLineItem> lines;
  final bool isWalkIn;
  final String? walkInName;
  final String? customerId;

  const BillModel({
    this.id = '',
    required this.invoiceNumber,
    required this.date,
    required this.partyName,
    required this.type,
    required this.amount,
    required this.status,
    this.paymentMode = 'cash',
    this.customerCity,
    this.companyName,
    this.companyId,
    this.createdByName,
    this.dueAmount = 0,
    this.subTotal = 0,
    this.gstAmount = 0,
    this.amountPaid = 0,
    this.totalQty = 0,
    this.lines = const [],
    this.isWalkIn = false,
    this.walkInName,
    this.customerId,
  });

  factory BillModel.fromJson(Map<String, dynamic> json) {
    // --- Party Name & Walk-In Detection ---
    final customer = json['customer'];
    String? walkInName = json['walkInName']?.toString();
    if (walkInName != null && walkInName.trim().isEmpty) {
      walkInName = null;
    }

    String partyName = 'Walk-in Customer';
    String? customerId;
    String? customerCity;
    bool isWalkIn = false;

    if (customer is Map<String, dynamic>) {
      customerId = customer['_id']?.toString() ?? customer['id']?.toString();
      if (customer['name'] != null &&
          customer['name'].toString().trim().isNotEmpty) {
        partyName = customer['name'].toString().trim();
        isWalkIn = false;
      }
      if (customer['city'] != null) {
        customerCity = customer['city'].toString();
      }
    } else if (customer is String && customer.trim().isNotEmpty) {
      customerId = customer.trim();
    }

    if (walkInName != null && walkInName.trim().isNotEmpty) {
      partyName = walkInName.trim();
      isWalkIn = true;
    } else if (customer == null ||
        (customer is Map &&
            (customer['name'] == null ||
                customer['name'].toString().trim().isEmpty))) {
      isWalkIn = true;
    }

    // --- Bill Type: pakka → GST Invoice, kaccha → Cash Memo ---
    final mode = json['mode']?.toString().toLowerCase() ?? '';
    final type = mode == 'pakka' ? BillType.gstInvoice : BillType.cashMemo;

    final double totalAmount = (json['totalAmount'] as num?)?.toDouble() ?? 0.0;
    final double amountPaid = (json['amountPaid'] as num?)?.toDouble() ?? 0.0;
    final double rawDue = (json['dueAmount'] as num?)?.toDouble() ??
        (totalAmount > amountPaid ? (totalAmount - amountPaid) : 0.0);
    final double dueAmount = double.parse(rawDue.toStringAsFixed(2));

    // --- Payment Status ---
    final paymentStatusStr =
        json['paymentStatus']?.toString().toLowerCase().trim() ?? '';
    final BillStatus status;
    if (paymentStatusStr == 'paid' ||
        (totalAmount > 0 && dueAmount <= 0 && amountPaid >= totalAmount)) {
      status = BillStatus.paid;
    } else if (paymentStatusStr == 'partial' ||
        paymentStatusStr == 'partially' ||
        paymentStatusStr == 'partially_paid' ||
        (amountPaid > 0 && dueAmount > 0)) {
      status = BillStatus.partial;
    } else {
      status = BillStatus.pending;
    }

    // --- Date & Time formatting (prefer createdAt for exact time) ---
    String formattedDate = '';
    final dateStr = json['createdAt']?.toString() ?? json['date']?.toString();
    if (dateStr != null && dateStr.isNotEmpty) {
      try {
        final dt = DateTime.parse(dateStr).toLocal();
        formattedDate = DateFormat('dd-MM-yyyy | hh:mm a').format(dt);
      } catch (_) {
        formattedDate = dateStr;
      }
    }

    // --- Company name & ID ---
    String? companyName;
    String? companyId;
    final company = json['company'];
    if (company is Map<String, dynamic>) {
      if (company['name'] != null) {
        companyName = company['name'].toString();
      }
      companyId = company['_id']?.toString() ?? company['id']?.toString();
    } else if (company is String) {
      companyId = company;
    }

    // --- Created by name ---
    String? createdByName;
    final createdBy = json['createdBy'];
    if (createdBy is Map<String, dynamic> && createdBy['name'] != null) {
      createdByName = createdBy['name'].toString();
    } else if (createdBy is String) {
      createdByName = createdBy;
    }

    // --- Line Items ---
    List<BillLineItem> lines = [];
    if (json['lines'] is List) {
      lines = (json['lines'] as List)
          .whereType<Map<String, dynamic>>()
          .map((item) => BillLineItem.fromJson(item))
          .toList();
    }

    return BillModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      invoiceNumber: json['invoiceNo']?.toString() ?? '',
      date: formattedDate,
      partyName: partyName,
      type: type,
      amount: totalAmount,
      status: status,
      paymentMode: json['paymentMode']?.toString() ?? 'cash',
      customerCity: customerCity,
      companyName: companyName,
      companyId: companyId,
      createdByName: createdByName,
      dueAmount: dueAmount,
      subTotal: (json['subTotal'] as num?)?.toDouble() ?? 0.0,
      gstAmount: (json['gstAmount'] as num?)?.toDouble() ?? 0.0,
      amountPaid: amountPaid,
      totalQty: (json['totalQty'] as num?)?.toInt() ?? 0,
      lines: lines,
      isWalkIn: isWalkIn,
      walkInName: walkInName,
      customerId: customerId,
    );
  }

  String get typeLabel =>
      type == BillType.gstInvoice ? 'GST Invoice' : 'Cash Memo';

  String get statusLabel {
    switch (status) {
      case BillStatus.paid:
        return '• Paid';
      case BillStatus.partial:
        return '• Partially';
      case BillStatus.pending:
        return '• Pending';
    }
  }

  String get formattedPaymentMode {
    final mode = paymentMode.toLowerCase().trim();
    switch (mode) {
      case 'upi':
        return 'UPI';
      case 'credit':
        return 'Credit';
      case 'bank':
      case 'bank_transfer':
      case 'bank transfer':
      case 'neft':
      case 'rtgs':
        return 'Bank Transfer';
      case 'cheque':
        return 'Cheque';
      case 'card':
        return 'Card';
      case 'cash':
      default:
        return 'Cash';
    }
  }

  String get itemsSummary {
    if (lines.isEmpty) {
      return totalQty > 0 ? '$totalQty Items' : '';
    }
    if (lines.length == 1) {
      final first = lines.first;
      return '${first.displayName} × ${first.qty}';
    }
    final first = lines.first;
    return '${first.displayName} +${lines.length - 1} more (${totalQty > 0 ? totalQty : lines.length} pcs)';
  }

  bool get hasReturns => lines.any((l) => l.returnedQty > 0);

  int get totalReturnedQty =>
      lines.fold(0, (sum, l) => sum + l.returnedQty);

  double get totalReturnedAmount => lines.fold(0.0, (sum, l) {
        if (l.returnedQty <= 0) return sum;
        final lineTotal = l.rate * l.returnedQty;
        final gst = lineTotal * (l.gstPercent / 100);
        return sum + lineTotal + gst;
      });
}
