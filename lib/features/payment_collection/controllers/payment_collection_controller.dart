import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../create_bill/services/billing_api_service.dart';
import '../models/payment_collection_model.dart';

class PaymentCollectionController extends ChangeNotifier {
  final BillingApiService _apiService = BillingApiService();

  final TextEditingController searchController = TextEditingController();
  String _searchQuery = '';

  String get searchQuery => _searchQuery;

  double _totalOutstanding = 0.0;
  double _totalCollected = 0.0;
  bool _isLoading = false;
  String? _errorMessage;

  double get totalOutstanding => _totalOutstanding;
  double get totalCollected => _totalCollected;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<PaymentCollectionModel> _allCollections = [];

  List<PaymentCollectionModel> get allCollections => _allCollections;

  Future<void> loadCollections({
    String? companyId,
    String paymentStatus = 'partially',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final summary = await _apiService.fetchPaymentCollectionsSummary(
        companyId: companyId,
        paymentStatus: paymentStatus,
      );

      _totalOutstanding = summary.totalDue;
      _totalCollected = summary.totalCollection;

      // Map invoices to PaymentCollectionModel with human friendly dateSection
      final now = DateTime.now();
      final todayStr = DateFormat('yyyy-MM-dd').format(now);
      final yesterdayStr =
          DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 1)));

      _allCollections = summary.invoices.map((inv) {
        String dateSection = 'Other';
        try {
          // BillModel date or createdAt
          DateTime? dt;
          // Try parsing formatted date or raw
          if (inv.date.isNotEmpty) {
            try {
              // format: 'dd-MM-yyyy | hh:mm a'
              dt = DateFormat('dd-MM-yyyy | hh:mm a').parse(inv.date);
            } catch (_) {
              dt = DateTime.tryParse(inv.date);
            }
          }

          if (dt != null) {
            final itemDayStr = DateFormat('yyyy-MM-dd').format(dt);
            final formattedDateLong = DateFormat('dd MMMM yyyy').format(dt);
            if (itemDayStr == todayStr) {
              dateSection = 'Today, $formattedDateLong';
            } else if (itemDayStr == yesterdayStr) {
              dateSection = 'Yesterday, $formattedDateLong';
            } else {
              dateSection = formattedDateLong;
            }
          }
        } catch (_) {}

        return PaymentCollectionModel.fromBillModel(inv, dateSection: dateSection);
      }).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      String err = e.toString();
      if (err.startsWith('Exception: ')) {
        err = err.substring('Exception: '.length);
      }
      _errorMessage = err;
      notifyListeners();
    }
  }

  void onSearchChanged(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<String> get availableSections {
    final query = _searchQuery.trim().toLowerCase();
    final filtered = _allCollections.where((item) {
      if (query.isEmpty) return true;
      return item.customerName.toLowerCase().contains(query) ||
          item.invoiceNumber.toLowerCase().contains(query);
    });

    final Set<String> seen = {};
    final List<String> sections = [];
    for (final item in filtered) {
      if (seen.add(item.dateSection)) {
        sections.add(item.dateSection);
      }
    }
    return sections;
  }

  List<PaymentCollectionModel> getItemsForSection(String section) {
    final query = _searchQuery.trim().toLowerCase();
    return _allCollections.where((item) {
      final matchesSection = item.dateSection == section;
      final matchesQuery = query.isEmpty ||
          item.customerName.toLowerCase().contains(query) ||
          item.invoiceNumber.toLowerCase().contains(query);
      return matchesSection && matchesQuery;
    }).toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}

