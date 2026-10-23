import 'package:flutter/material.dart';
import '../../company/models/company_model.dart';
import '../../create_bill/models/available_product_model.dart';
import '../../create_bill/models/draft_bill_model.dart';
import '../../create_bill/services/draft_storage_service.dart';
import '../models/bill_model.dart';

class HomeController extends ChangeNotifier {
  // --- Dynamic metrics (mapped from backend company billingMetrics) ---
  int _totalInvoices = 0;
  double _totalSales = 0;
  int _totalAvailableStock = 0;
  int _lowStockCount = 0;

  int get totalInvoices => _totalInvoices;
  double get totalSales => _totalSales;
  int get totalAvailableStock => _totalAvailableStock;
  int get lowStockCount => _lowStockCount;

  // --- Drafts ---
  List<DraftBillModel> _drafts = [];
  List<DraftBillModel> get drafts => _drafts;
  int get pendingDraftsCount => _drafts.length;

  bool _isLoadingDrafts = false;
  bool get isLoadingDrafts => _isLoadingDrafts;

  // --- Recent bills (from API) ---
  List<BillModel> _recentBills = [];
  List<BillModel> get recentBills => _recentBills;

  // --- Available Stock Products (from API) ---
  List<AvailableProductModel> _availableProducts = [];
  List<AvailableProductModel> get availableProducts => _availableProducts;

  HomeController() {
    loadPendingDrafts();
  }

  Future<void> loadPendingDrafts() async {
    _isLoadingDrafts = true;
    notifyListeners();
    try {
      _drafts = await DraftStorageService().getDrafts();
    } catch (_) {
      _drafts = [];
    } finally {
      _isLoadingDrafts = false;
      notifyListeners();
    }
  }

  Future<void> deleteDraft(String id) async {
    await DraftStorageService().deleteDraft(id);
    await loadPendingDrafts();
  }

  /// Maps billing metrics directly from the backend company `billingMetrics` object.
  void setMetricsFromCompany(CompanyBillingMetrics? metrics) {
    if (metrics != null) {
      _totalInvoices = metrics.totalInvoices;
      _totalSales = metrics.totalSales;
      _totalAvailableStock = metrics.totalStock;
      _lowStockCount = metrics.lowStockAlert;
    } else {
      _totalInvoices = 0;
      _totalSales = 0.0;
      _totalAvailableStock = 0;
      _lowStockCount = 0;
    }
    notifyListeners();
  }

  /// Set the recent bills (first 5 from API).
  void loadBillsData(List<BillModel> allBills) {
    // Show latest 5 as recent bills
    _recentBills = allBills.length > 5 ? allBills.sublist(0, 5) : allBills;
    notifyListeners();
  }

  /// Set the available products.
  void loadAvailableProducts(List<AvailableProductModel> products) {
    _availableProducts = products;
    notifyListeners();
  }
}
