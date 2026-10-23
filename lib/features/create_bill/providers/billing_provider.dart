import 'package:flutter/material.dart';
import '../../../core/services/storage_service.dart';
import '../../home/models/bill_model.dart';
import '../models/available_product_model.dart';
import '../models/billing_model.dart';
import '../services/billing_api_service.dart';

class BillingProvider extends ChangeNotifier {
  final BillingApiService _apiService = BillingApiService();
  final StorageService _storageService = StorageService();

  // --- Legacy billing list (raw BillingModel) ---
  List<BillingModel> _bills = [];
  BillingModel? _createdBill;
  bool _isLoading = false;
  bool _isCreating = false;
  String? _errorMessage;

  List<BillingModel> get bills => _bills;
  BillingModel? get createdBill => _createdBill;
  bool get isLoading => _isLoading;
  bool get isCreating => _isCreating;
  String? get errorMessage => _errorMessage;

  // --- New: UI-friendly bill models ---
  List<BillModel> _billModels = [];
  bool _isLoadingBills = false;
  String? _billsError;

  List<BillModel> get billModels => _billModels;
  bool get isLoadingBills => _isLoadingBills;
  String? get billsError => _billsError;

  // --- Today's Bill Models (for Home Dashboard) ---
  List<BillModel> _todayBillModels = [];
  bool _isLoadingTodayBills = false;
  String? _todayBillsError;

  List<BillModel> get todayBillModels => _todayBillModels;
  bool get isLoadingTodayBills => _isLoadingTodayBills;
  String? get todayBillsError => _todayBillsError;

  /// Fetches today's bills for the Home Dashboard.
  Future<void> fetchTodayBillModels({String? companyId}) async {
    _isLoadingTodayBills = true;
    _todayBillsError = null;
    notifyListeners();

    try {
      final fetched = await _apiService.fetchBills(
        companyId: companyId,
        period: 'today',
      );
      _todayBillModels = fetched;
      _isLoadingTodayBills = false;
      notifyListeners();
    } catch (e) {
      _todayBillModels = [];
      _isLoadingTodayBills = false;
      String error = e.toString();
      if (error.startsWith('Exception: ')) {
        error = error.substring('Exception: '.length);
      }
      _todayBillsError = error;
      notifyListeners();
    }
  }

  /// Fetches bills as UI-friendly `BillModel` list from the API.
  /// Optionally filter by [companyId], [mode], [customerType], and [period] (e.g. `'today'`).
  Future<void> fetchBillModels({
    String? companyId,
    String? mode,
    String? customerType,
    String? period,
  }) async {
    _isLoadingBills = true;
    _billsError = null;
    notifyListeners();

    try {
      final fetched = await _apiService.fetchBills(
        companyId: companyId,
        mode: mode,
        customerType: customerType,
        period: period,
      );
      _billModels = fetched;
      _isLoadingBills = false;
      notifyListeners();
    } catch (e) {
      _billModels = [];
      _isLoadingBills = false;
      String error = e.toString();
      if (error.startsWith('Exception: ')) {
        error = error.substring('Exception: '.length);
      }
      _billsError = error;
      notifyListeners();
    }
  }

  // --- Walk-in Bill Models ---
  List<BillModel> _walkInBillModels = [];
  bool _isLoadingWalkInBills = false;
  String? _walkInBillsError;

  List<BillModel> get walkInBillModels => _walkInBillModels;
  bool get isLoadingWalkInBills => _isLoadingWalkInBills;
  String? get walkInBillsError => _walkInBillsError;

  /// Fetches walk-in customer bills from the API with `customerType=walk_in`.
  Future<void> fetchWalkInBills({String? companyId}) async {
    _isLoadingWalkInBills = true;
    _walkInBillsError = null;
    notifyListeners();

    try {
      final fetched = await _apiService.fetchBills(
        companyId: companyId,
        customerType: 'walk_in',
      );
      _walkInBillModels = fetched;
      _isLoadingWalkInBills = false;
      notifyListeners();
    } catch (e) {
      _walkInBillModels = [];
      _isLoadingWalkInBills = false;
      String error = e.toString();
      if (error.startsWith('Exception: ')) {
        error = error.substring('Exception: '.length);
      }
      _walkInBillsError = error;
      notifyListeners();
    }
  }

  // --- Available Products ---
  List<AvailableProductModel> _availableProducts = [];
  bool _isLoadingProducts = false;
  String? _productsError;

  List<AvailableProductModel> get availableProducts => _availableProducts;
  bool get isLoadingProducts => _isLoadingProducts;
  String? get productsError => _productsError;

  Future<void> fetchAvailableProducts({String? companyId}) async {
    _isLoadingProducts = true;
    _productsError = null;
    notifyListeners();

    try {
      final fetched = await _apiService.fetchAvailableProducts(
        companyId: companyId,
      );
      _availableProducts = fetched;
      _isLoadingProducts = false;
      notifyListeners();
    } catch (e) {
      _availableProducts = [];
      _isLoadingProducts = false;
      String error = e.toString();
      if (error.startsWith('Exception: ')) {
        error = error.substring('Exception: '.length);
      }
      _productsError = error;
      notifyListeners();
    }
  }

  // --- Legacy methods (unchanged) ---

  Future<void> fetchBills() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetched = await _apiService.getBills();
      _bills = fetched;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      String error = e.toString();
      if (error.startsWith('Exception: ')) {
        error = error.substring('Exception: '.length);
      }
      _errorMessage = error;
      notifyListeners();
    }
  }

  Future<BillingModel> createBill({
    String? companyId,
    String? invoiceNo,
    required String mode, // 'kaccha' or 'pakka'
    String? walkInName,
    String? customerId,
    required List<BillingLineItem> lines,
    required String paymentMode, // 'cash', 'upi', 'bank_transfer', 'cheque'
    required double amountPaid,
    String? discountType, // 'flat' or 'percentage'
    double? discountRate,
  }) async {
    _isCreating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String finalCompanyId = companyId ?? '';
      if (finalCompanyId.isEmpty) {
        final stored = await _storageService.getCompanyId();
        if (stored != null && stored.isNotEmpty) {
          finalCompanyId = stored;
        } else {
          final userData = await _storageService.getUserData();
          if (userData != null) {
            if (userData['company'] != null) {
              final comp = userData['company'];
              if (comp is Map<String, dynamic>) {
                finalCompanyId =
                    comp['_id']?.toString() ?? comp['id']?.toString() ?? '';
              } else if (comp is String) {
                finalCompanyId = comp;
              }
            } else if (userData['companies'] != null) {
              final comps = userData['companies'];
              if (comps is List && comps.isNotEmpty) {
                final firstComp = comps.first;
                if (firstComp is Map<String, dynamic>) {
                  finalCompanyId = firstComp['_id']?.toString() ??
                      firstComp['id']?.toString() ??
                      '';
                } else if (firstComp is String) {
                  finalCompanyId = firstComp;
                }
              }
            }
          }
        }
      }

      String finalInvoiceNo = invoiceNo ?? '';
      if (finalInvoiceNo.isEmpty) {
        final randomSuffix =
            (DateTime.now().millisecondsSinceEpoch % 10000)
                .toString()
                .padLeft(4, '0');
        finalInvoiceNo = 'INV-$randomSuffix';
      }

      final billPayload = BillingModel(
        company: finalCompanyId,
        invoiceNo: finalInvoiceNo,
        mode: mode.toLowerCase(),
        walkInName: walkInName,
        customer: customerId,
        lines: lines,
        paymentMode: paymentMode.toLowerCase(),
        amountPaid: amountPaid,
        discountType: discountType ?? 'percentage',
        discountRate: discountRate ?? 0,
      );

      final newBill = await _apiService.createBill(billPayload);
      _createdBill = newBill;
      _bills = [newBill, ..._bills];
      _isCreating = false;
      notifyListeners();
      return newBill;
    } catch (e) {
      _isCreating = false;
      String error = e.toString();
      if (error.startsWith('Exception: ')) {
        error = error.substring('Exception: '.length);
      }
      _errorMessage = error;
      notifyListeners();
      rethrow;
    }
  }

  // --- Record Payment ---
  bool _isRecordingPayment = false;
  String? _recordPaymentError;

  bool get isRecordingPayment => _isRecordingPayment;
  String? get recordPaymentError => _recordPaymentError;

  /// Records a partial/full payment on an existing bill.
  /// Updates the local [billModels] list in-place so the UI reflects changes
  /// without a full re-fetch.
  Future<BillModel> recordPayment({
    required String billId,
    required String companyId,
    required double amountPaid,
  }) async {
    _isRecordingPayment = true;
    _recordPaymentError = null;
    notifyListeners();

    try {
      final updated = await _apiService.recordPayment(
        billId: billId,
        companyId: companyId,
        amountPaid: amountPaid,
      );

      // Update local list in-place
      final index = _billModels.indexWhere((b) => b.id == billId);
      if (index != -1) {
        _billModels[index] = updated;
      }
      final todayIndex = _todayBillModels.indexWhere((b) => b.id == billId);
      if (todayIndex != -1) {
        _todayBillModels[todayIndex] = updated;
      }

      _isRecordingPayment = false;
      notifyListeners();
      return updated;
    } catch (e) {
      _isRecordingPayment = false;
      String error = e.toString();
      if (error.startsWith('Exception: ')) {
        error = error.substring('Exception: '.length);
      }
      _recordPaymentError = error;
      notifyListeners();
      rethrow;
    }
  }

  /// Returns products for an existing invoice via `POST /api/billing/return`.
  Future<Map<String, dynamic>> returnProducts({
    required String companyId,
    required String invoiceNo,
    required List<Map<String, dynamic>> lines,
  }) async {
    try {
      final res = await _apiService.returnProducts(
        companyId: companyId,
        invoiceNo: invoiceNo,
        lines: lines,
      );
      // Refresh bills list
      await fetchBillModels(companyId: companyId);
      await fetchTodayBillModels(companyId: companyId);
      return res;
    } catch (e) {
      rethrow;
    }
  }

  void clearError() {
    _errorMessage = null;
    _billsError = null;
    _todayBillsError = null;
    _recordPaymentError = null;
    notifyListeners();
  }
}
