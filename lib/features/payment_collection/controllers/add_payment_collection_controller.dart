import 'package:flutter/material.dart';
import '../../create_bill/services/billing_api_service.dart';
import '../../home/models/bill_model.dart';

class AddPaymentCollectionController extends ChangeNotifier {
  final BillingApiService _apiService = BillingApiService();

  String? _selectedFirm;
  String? _selectedCompanyId;
  String? _selectedCustomer;
  String? _selectedCustomerId;

  String? _selectedInvoice;
  BillModel? _selectedBillModel;

  final TextEditingController receivedAmountController =
      TextEditingController();
  String? _selectedPaymentMode = 'Cash';

  bool _isLoadingBills = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  List<BillModel> _customerBills = [];

  final List<String> paymentModes = [
    'Cash',
    'Bank Transfer',
    'UPI / QR Code',
    'Cheque',
  ];

  AddPaymentCollectionController({BillModel? initialBill}) {
    receivedAmountController.addListener(_onAmountChanged);
    if (initialBill != null) {
      _applyInitialBill(initialBill);
    }
  }

  void _applyInitialBill(BillModel bill) {
    _selectedCompanyId = bill.companyId;
    _selectedFirm = bill.companyName;
    _selectedCustomer = bill.partyName;
    _selectedCustomerId = bill.customerId;
    _selectedBillModel = bill;
    _selectedInvoice = bill.invoiceNumber;
    _customerBills = [bill];
    receivedAmountController.text = bill.dueAmount.toStringAsFixed(2);
  }

  void _onAmountChanged() {
    notifyListeners();
  }

  // Getters
  String? get selectedFirm => _selectedFirm;
  String? get selectedCompanyId => _selectedCompanyId;
  String? get selectedCustomer => _selectedCustomer;
  String? get selectedCustomerId => _selectedCustomerId;
  String? get selectedInvoice => _selectedInvoice;
  BillModel? get selectedBillModel => _selectedBillModel;
  String? get selectedPaymentMode => _selectedPaymentMode;
  bool get isLoadingBills => _isLoadingBills;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  List<BillModel> get customerBills => _customerBills;

  List<String> get invoiceOptions {
    if (_customerBills.isEmpty) {
      return _selectedInvoice != null ? [_selectedInvoice!] : [];
    }
    return _customerBills.map((b) => b.invoiceNumber).toSet().toList();
  }

  List<BillLineItem> get productLines => _selectedBillModel?.lines ?? const [];

  // Summary Metrics for selected bill
  double get totalAmount => _selectedBillModel?.amount ?? 0.0;
  double get collectedAmount => _selectedBillModel?.amountPaid ?? 0.0;
  double get outstandingAmount => _selectedBillModel?.dueAmount ?? 0.0;

  // Financial Breakdown
  double get invoiceTotal => _selectedBillModel?.amount ?? 0.0;
  double get alreadyReceived => _selectedBillModel?.amountPaid ?? 0.0;
  double get beforePendingAmount => _selectedBillModel?.dueAmount ?? 0.0;

  double get receivingNow {
    final text = receivedAmountController.text.trim().replaceAll(',', '');
    return double.tryParse(text) ?? 0.0;
  }

  double get balanceAfterPayment {
    final pending = beforePendingAmount;
    final diff = pending - receivingNow;
    return diff > 0 ? double.parse(diff.toStringAsFixed(2)) : 0.0;
  }

  void selectFirm(String? firm, {String? companyId}) {
    _selectedFirm = firm;
    if (companyId != null) {
      _selectedCompanyId = companyId;
    }
    _selectedCustomer = null;
    _selectedCustomerId = null;
    _selectedInvoice = null;
    _selectedBillModel = null;
    _customerBills = [];
    receivedAmountController.clear();
    notifyListeners();
  }

  void selectCustomer(String? customer, {String? customerId}) {
    _selectedCustomer = customer;
    _selectedCustomerId = customerId;
    _selectedInvoice = null;
    _selectedBillModel = null;
    receivedAmountController.clear();
    notifyListeners();

    if (_selectedCompanyId != null && _selectedCompanyId!.isNotEmpty) {
      loadInvoicesForCustomer();
    }
  }

  Future<void> loadInvoicesForCustomer() async {
    _isLoadingBills = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final summary = await _apiService.fetchPaymentCollectionsSummary(
        companyId: _selectedCompanyId,
        paymentStatus: 'partially',
        customerId: _selectedCustomerId,
      );

      // Filter by customer name or ID
      _customerBills = summary.invoices.where((inv) {
        if (_selectedCustomerId != null && _selectedCustomerId!.isNotEmpty) {
          if (inv.customerId == _selectedCustomerId) return true;
        }
        if (_selectedCustomer != null && _selectedCustomer!.isNotEmpty) {
          return inv.partyName.toLowerCase() ==
              _selectedCustomer!.toLowerCase();
        }
        return true;
      }).toList();

      if (_customerBills.isNotEmpty) {
        selectInvoice(_customerBills.first.invoiceNumber);
      } else {
        _selectedInvoice = null;
        _selectedBillModel = null;
        receivedAmountController.clear();
      }

      _isLoadingBills = false;
      notifyListeners();
    } catch (e) {
      _isLoadingBills = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void selectInvoice(String? invoiceNo) {
    _selectedInvoice = invoiceNo;
    if (invoiceNo == null) {
      _selectedBillModel = null;
      receivedAmountController.clear();
    } else {
      final match = _customerBills.where((b) => b.invoiceNumber == invoiceNo);
      if (match.isNotEmpty) {
        _selectedBillModel = match.first;
        receivedAmountController.text =
            _selectedBillModel!.dueAmount.toStringAsFixed(2);
      }
    }
    notifyListeners();
  }

  void selectPaymentMode(String? mode) {
    _selectedPaymentMode = mode;
    notifyListeners();
  }

  Future<bool> recordPayment() async {
    if (_selectedBillModel == null || _selectedBillModel!.id.isEmpty) {
      _errorMessage = 'Please select a valid invoice';
      notifyListeners();
      return false;
    }

    final amount = receivingNow;
    if (amount <= 0) {
      _errorMessage = 'Please enter a valid amount greater than 0';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.recordPayment(
        billId: _selectedBillModel!.id,
        companyId: _selectedCompanyId ?? _selectedBillModel!.companyId ?? '',
        amountPaid: amount,
      );

      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isSubmitting = false;
      String err = e.toString();
      if (err.startsWith('Exception: ')) {
        err = err.substring('Exception: '.length);
      }
      _errorMessage = err;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    receivedAmountController.removeListener(_onAmountChanged);
    receivedAmountController.dispose();
    super.dispose();
  }
}

