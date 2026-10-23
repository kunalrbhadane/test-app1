import 'package:flutter/material.dart';
import '../../home/models/bill_model.dart';
import '../models/sales_return_item_model.dart';

enum SalesReturnCustomerType { registered, walkIn }

class SalesReturnController extends ChangeNotifier {
  int _currentStep = 1;
  final int totalSteps = 3;

  // Step 1: Firm, Customer Type, Customer/Walk-in, Invoices
  String? _selectedFirm;
  String? _selectedCompanyId;
  String? _selectedCustomer;
  String? _selectedInvoice;
  BillModel? _selectedBillModel;

  SalesReturnCustomerType _customerType = SalesReturnCustomerType.registered;
  String? _selectedWalkInName;

  List<BillModel> _availableBills = [];
  List<BillModel> _walkInBills = [];
  bool _isLoadingWalkIn = false;
  bool _isSubmitting = false;

  // Step 2 & 3 State
  List<SalesReturnItemModel> _returnItems = [];
  final TextEditingController reasonController =
      TextEditingController(text: 'Damage Products');

  // Return API Response Data
  Map<String, dynamic>? _returnResponse;
  String? _returnMessage;
  BillModel? _updatedInvoice;

  int get currentStep => _currentStep;
  String? get selectedFirm => _selectedFirm;
  String? get selectedCompanyId => _selectedCompanyId;
  String? get selectedCustomer => _selectedCustomer;
  String? get selectedInvoice => _selectedInvoice;
  BillModel? get selectedBillModel => _selectedBillModel;
  SalesReturnCustomerType get customerType => _customerType;
  String? get selectedWalkInName => _selectedWalkInName;
  List<SalesReturnItemModel> get returnItems => _returnItems;
  bool get isSubmitting => _isSubmitting;
  bool get isLoadingWalkIn => _isLoadingWalkIn;
  Map<String, dynamic>? get returnResponse => _returnResponse;
  String? get returnMessage => _returnMessage;
  BillModel? get updatedInvoice => _updatedInvoice;

  void setReturnResponse(Map<String, dynamic> response) {
    _returnResponse = response;
    _returnMessage = response['message']?.toString() ?? 'Products returned successfully';
    if (response['invoice'] is Map<String, dynamic>) {
      final invMap = Map<String, dynamic>.from(response['invoice'] as Map);
      // Ensure customer/party name is preserved if customer is just an ID in response
      if (invMap['customer'] is! Map && _selectedBillModel != null) {
        invMap['walkInName'] = _selectedBillModel!.partyName;
      }
      try {
        _updatedInvoice = BillModel.fromJson(invMap);
      } catch (_) {}
    }
    notifyListeners();
  }

  String get invoiceNumber =>
      _selectedBillModel?.invoiceNumber.isNotEmpty == true
          ? _selectedBillModel!.invoiceNumber
          : (_selectedInvoice ?? '');

  String get invoiceDateTime =>
      _selectedBillModel?.date.isNotEmpty == true
          ? _selectedBillModel!.date
          : '';

  String get billType => _selectedBillModel?.typeLabel ?? 'GST Invoice';

  String get customerDetails =>
      _selectedBillModel?.partyName.isNotEmpty == true
          ? _selectedBillModel!.partyName
          : (_selectedCustomer ?? _selectedWalkInName ?? 'Customer');

  double get totalReturnAmount {
    return _returnItems.fold(0.0, (sum, item) => sum + item.returnAmount);
  }

  int get totalReturnQty {
    return _returnItems.fold(0, (sum, item) => sum + item.returnQty);
  }

  // --- Customer Type ---

  void setCustomerType(SalesReturnCustomerType type) {
    if (_customerType == type) return;
    _customerType = type;
    _selectedCustomer = null;
    _selectedWalkInName = null;
    _selectedInvoice = null;
    _selectedBillModel = null;
    _returnItems = [];
    notifyListeners();
  }

  // --- Registered Customer Bills ---

  void setAvailableBills(List<BillModel> bills) {
    _availableBills = bills;
    notifyListeners();
  }

  // --- Walk-in Customer Bills ---

  void setWalkInBills(List<BillModel> bills) {
    _walkInBills = bills;
    _isLoadingWalkIn = false;
    notifyListeners();
  }

  void setLoadingWalkIn(bool loading) {
    _isLoadingWalkIn = loading;
    notifyListeners();
  }

  /// Returns unique walk-in names from walk-in bills, filtered by company.
  List<String> getWalkInNames({String? companyId, String? companyName}) {
    return _walkInBills
        .where((b) {
          if (companyId != null && companyId.isNotEmpty && b.companyId != null && b.companyId!.isNotEmpty) {
            return b.companyId == companyId;
          }
          if (companyName != null && companyName.isNotEmpty && b.companyName != null) {
            return b.companyName?.toLowerCase() == companyName.toLowerCase();
          }
          return true;
        })
        .map((b) => b.partyName)
        .where((name) => name.trim().isNotEmpty)
        .toSet()
        .toList();
  }

  List<String> getAvailableInvoices({
    String? companyId,
    String? companyName,
    String? customerName,
  }) {
    return _availableBills
        .where((b) {
          bool matchCompany = true;
          if (companyId != null && companyId.isNotEmpty && b.companyId != null && b.companyId!.isNotEmpty) {
            matchCompany = b.companyId == companyId;
          } else if (companyName != null && companyName.isNotEmpty && b.companyName != null) {
            matchCompany =
                b.companyName?.toLowerCase() == companyName.toLowerCase();
          }
          bool matchCustomer = true;
          if (customerName != null && customerName.isNotEmpty) {
            matchCustomer =
                b.partyName.toLowerCase() == customerName.toLowerCase();
          }
          return matchCompany && matchCustomer && b.invoiceNumber.isNotEmpty;
        })
        .map((b) => b.invoiceNumber)
        .toSet()
        .toList();
  }

  /// Returns invoice numbers for walk-in bills filtered by company and walk-in name.
  List<String> getWalkInInvoices({
    String? companyId,
    String? companyName,
    String? walkInName,
  }) {
    return _walkInBills
        .where((b) {
          bool matchCompany = true;
          if (companyId != null && companyId.isNotEmpty && b.companyId != null && b.companyId!.isNotEmpty) {
            matchCompany = b.companyId == companyId;
          } else if (companyName != null && companyName.isNotEmpty && b.companyName != null) {
            matchCompany =
                b.companyName?.toLowerCase() == companyName.toLowerCase();
          }
          bool matchWalkIn = true;
          if (walkInName != null && walkInName.isNotEmpty) {
            matchWalkIn =
                b.partyName.toLowerCase() == walkInName.toLowerCase();
          }
          return matchCompany && matchWalkIn && b.invoiceNumber.isNotEmpty;
        })
        .map((b) => b.invoiceNumber)
        .toSet()
        .toList();
  }

  void selectFirm(String? firm, {String? companyId}) {
    _selectedFirm = firm;
    _selectedCompanyId = companyId;
    _selectedCustomer = null;
    _selectedWalkInName = null;
    _selectedInvoice = null;
    _selectedBillModel = null;
    _returnItems = [];
    notifyListeners();
  }

  void selectCustomer(String? customer) {
    _selectedCustomer = customer;
    _selectedInvoice = null;
    _selectedBillModel = null;
    _returnItems = [];
    notifyListeners();
  }

  void selectWalkInName(String? name) {
    _selectedWalkInName = name;
    _selectedInvoice = null;
    _selectedBillModel = null;
    _returnItems = [];
    notifyListeners();
  }

  void selectInvoice(String? invoice) {
    _selectedInvoice = invoice;
    if (invoice != null) {
      // Search in both registered and walk-in bills
      final allBills = _customerType == SalesReturnCustomerType.walkIn
          ? _walkInBills
          : _availableBills;
      final match =
          allBills.where((b) => b.invoiceNumber == invoice).toList();
      if (match.isNotEmpty) {
        _selectedBillModel = match.first;
        _populateReturnItemsFromBill(match.first);
      }
    } else {
      _selectedBillModel = null;
      _returnItems = [];
    }
    notifyListeners();
  }

  void _populateReturnItemsFromBill(BillModel bill) {
    if (bill.lines.isNotEmpty) {
      _returnItems = bill.lines.asMap().entries.map((entry) {
        final idx = entry.key;
        final line = entry.value;
        final maxQty = line.availableToReturnQty;
        final defaultRtn = maxQty > 0 ? (maxQty >= 1 ? 1 : maxQty) : 0;
        return SalesReturnItemModel(
          id: '${idx + 1}',
          productId: line.productId,
          name: line.displayName,
          totalQty: line.qty,
          rate: line.rate,
          gstPercent: line.gstPercent,
          amount: line.lineTotal,
          returnQty: defaultRtn,
          alreadyReturnedQty: line.returnedQty,
        );
      }).toList();
    } else {
      _returnItems = [];
    }
  }

  void updateItemReturnQty(String id, int qty) {
    _returnItems = _returnItems.map((item) {
      if (item.id == id) {
        final clampedQty = qty.clamp(0, item.maxReturnableQty);
        return item.copyWith(returnQty: clampedQty);
      }
      return item;
    }).toList();
    notifyListeners();
  }

  void incrementItemReturnQty(String id) {
    final item = _returnItems.firstWhere(
      (i) => i.id == id,
      orElse: () => _returnItems.first,
    );
    if (item.returnQty < item.maxReturnableQty) {
      updateItemReturnQty(id, item.returnQty + 1);
    }
  }

  void decrementItemReturnQty(String id) {
    final item = _returnItems.firstWhere(
      (i) => i.id == id,
      orElse: () => _returnItems.first,
    );
    if (item.returnQty > 0) {
      updateItemReturnQty(id, item.returnQty - 1);
    }
  }

  void setSubmitting(bool value) {
    _isSubmitting = value;
    notifyListeners();
  }

  bool canProceedToStep2() {
    if (_selectedFirm == null || _selectedFirm!.isEmpty) return false;
    if (_selectedInvoice == null || _selectedInvoice!.isEmpty) return false;

    if (_customerType == SalesReturnCustomerType.registered) {
      return _selectedCustomer != null && _selectedCustomer!.isNotEmpty;
    } else {
      return _selectedWalkInName != null && _selectedWalkInName!.isNotEmpty;
    }
  }

  bool canProceedToStep3() {
    return _returnItems.isNotEmpty &&
        _returnItems.any(
          (item) => item.returnQty > 0 && item.productId.isNotEmpty,
        );
  }

  void nextStep() {
    if (_currentStep < totalSteps) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 1) {
      _currentStep--;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }
}
