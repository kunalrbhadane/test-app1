import 'dart:convert';
import 'selected_product_model.dart';

class DraftBillModel {
  final String id;
  final int currentStep;
  final String? selectedFirm;
  final String? selectedCompanyId;
  final String selectedBillType; // 'pakka' or 'kaccha'
  final String? selectedCustomer;
  final String? walkInName;
  final bool isAddingNewCustomer;
  final String? customerName;
  final String? customerContactPerson;
  final String? customerMobile;
  final String? customerGstin;
  final String? customerFssai;
  final String? customerAddress;
  final String? customerCity;
  final String? customerCreditLimit;
  final String? customerOpeningBalance;
  final String? customerOutstandingBalance;
  final List<SelectedProductItem> products;
  final String selectedPaymentMode; // 'cash', 'credit', 'upi', 'bank'
  final String? amountReceived;
  final String? paymentReference;
  final String? memoNote;
  final String discountType; // 'percentage' or 'flat'
  final double discountRate;
  final DateTime savedAt;

  const DraftBillModel({
    required this.id,
    this.currentStep = 1,
    this.selectedFirm,
    this.selectedCompanyId,
    this.selectedBillType = 'pakka',
    this.selectedCustomer,
    this.walkInName,
    this.isAddingNewCustomer = false,
    this.customerName,
    this.customerContactPerson,
    this.customerMobile,
    this.customerGstin,
    this.customerFssai,
    this.customerAddress,
    this.customerCity,
    this.customerCreditLimit,
    this.customerOpeningBalance,
    this.customerOutstandingBalance,
    this.products = const [],
    this.selectedPaymentMode = 'cash',
    this.amountReceived,
    this.paymentReference,
    this.memoNote,
    this.discountType = 'percentage',
    this.discountRate = 0.0,
    required this.savedAt,
  });

  String get partyDisplayName {
    if (walkInName != null && walkInName!.trim().isNotEmpty) {
      return walkInName!.trim();
    }
    if (selectedCustomer != null && selectedCustomer!.trim().isNotEmpty) {
      return selectedCustomer!.trim();
    }
    if (customerName != null && customerName!.trim().isNotEmpty) {
      return customerName!.trim();
    }
    return 'Walk-in Customer';
  }

  double get grandTotal {
    double subTotal = 0.0;
    double totalGst = 0.0;
    for (final p in products) {
      final lineAmount = (p.totalAmount * 100.0).round() / 100.0;
      final gst = selectedBillType == 'pakka'
          ? ((lineAmount * p.gstPercent / 100) * 100.0).round() / 100.0
          : 0.0;
      subTotal += lineAmount;
      totalGst += gst;
    }
    final totalBeforeDiscount = ((subTotal + totalGst) * 100.0).round() / 100.0;
    double discountAmount = 0.0;
    if (discountRate > 0) {
      discountAmount = discountType == 'flat'
          ? (discountRate * 100.0).round() / 100.0
          : ((subTotal * (discountRate / 100)) * 100.0).round() / 100.0;
      discountAmount = discountAmount.clamp(0.0, totalBeforeDiscount);
    }
    return ((totalBeforeDiscount - discountAmount) * 100.0).round() / 100.0;
  }

  int get totalQuantity {
    return products.fold<int>(0, (sum, item) => sum + item.quantity);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'currentStep': currentStep,
      'selectedFirm': selectedFirm,
      'selectedCompanyId': selectedCompanyId,
      'selectedBillType': selectedBillType,
      'selectedCustomer': selectedCustomer,
      'walkInName': walkInName,
      'isAddingNewCustomer': isAddingNewCustomer,
      'customerName': customerName,
      'customerContactPerson': customerContactPerson,
      'customerMobile': customerMobile,
      'customerGstin': customerGstin,
      'customerFssai': customerFssai,
      'customerAddress': customerAddress,
      'customerCity': customerCity,
      'customerCreditLimit': customerCreditLimit,
      'customerOpeningBalance': customerOpeningBalance,
      'customerOutstandingBalance': customerOutstandingBalance,
      'products': products.map((x) => x.toMap()).toList(),
      'selectedPaymentMode': selectedPaymentMode,
      'amountReceived': amountReceived,
      'paymentReference': paymentReference,
      'memoNote': memoNote,
      'discountType': discountType,
      'discountRate': discountRate,
      'savedAt': savedAt.toIso8601String(),
    };
  }

  factory DraftBillModel.fromMap(Map<String, dynamic> map) {
    return DraftBillModel(
      id: map['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      currentStep: (map['currentStep'] as num?)?.toInt() ?? 1,
      selectedFirm: map['selectedFirm']?.toString(),
      selectedCompanyId: map['selectedCompanyId']?.toString(),
      selectedBillType: map['selectedBillType']?.toString() ?? 'pakka',
      selectedCustomer: map['selectedCustomer']?.toString(),
      walkInName: map['walkInName']?.toString(),
      isAddingNewCustomer: map['isAddingNewCustomer'] == true,
      customerName: map['customerName']?.toString(),
      customerContactPerson: map['customerContactPerson']?.toString(),
      customerMobile: map['customerMobile']?.toString(),
      customerGstin: map['customerGstin']?.toString(),
      customerFssai: map['customerFssai']?.toString(),
      customerAddress: map['customerAddress']?.toString(),
      customerCity: map['customerCity']?.toString(),
      customerCreditLimit: map['customerCreditLimit']?.toString(),
      customerOpeningBalance: map['customerOpeningBalance']?.toString(),
      customerOutstandingBalance: map['customerOutstandingBalance']?.toString(),
      products: map['products'] != null
          ? List<SelectedProductItem>.from(
              (map['products'] as List).map(
                (x) => SelectedProductItem.fromMap(x as Map<String, dynamic>),
              ),
            )
          : const [],
      selectedPaymentMode: map['selectedPaymentMode']?.toString() ?? 'cash',
      amountReceived: map['amountReceived']?.toString(),
      paymentReference: map['paymentReference']?.toString(),
      memoNote: map['memoNote']?.toString(),
      discountType: map['discountType']?.toString() ?? 'percentage',
      discountRate: (map['discountRate'] as num?)?.toDouble() ?? 0.0,
      savedAt: map['savedAt'] != null
          ? DateTime.tryParse(map['savedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory DraftBillModel.fromJson(String source) =>
      DraftBillModel.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
