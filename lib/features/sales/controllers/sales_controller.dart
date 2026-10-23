import 'package:flutter/material.dart';
import '../../home/models/bill_model.dart';

class SalesController extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();
  String _selectedFilter = 'All';
  String _searchQuery = '';

  String get selectedFilter => _selectedFilter;
  String get searchQuery => _searchQuery;

  final List<String> filterOptions = const [
    'All',
    'Pakka Bill',
    'Kaccha Bill',
  ];

  List<BillModel> _allBills = [];
  List<BillModel> _filteredBills = [];
  List<BillModel> get allBills => _allBills;
  List<BillModel> get filteredBills => _filteredBills;

  /// Set bills from API data and apply current filters.
  void setBills(List<BillModel> bills) {
    _allBills = bills;
    _applyFilters();
  }

  void onFilterChanged(String filter) {
    _selectedFilter = filter;
    _applyFilters();
  }

  void onSearchChanged(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void _applyFilters() {
    final query = _searchQuery.toLowerCase().trim();
    final filter = _selectedFilter;

    _filteredBills = _allBills.where((bill) {
      final matchesQuery = query.isEmpty ||
          bill.partyName.toLowerCase().contains(query) ||
          bill.invoiceNumber.toLowerCase().contains(query) ||
          (bill.customerCity != null &&
              bill.customerCity!.toLowerCase().contains(query)) ||
          bill.paymentMode.toLowerCase().contains(query) ||
          bill.formattedPaymentMode.toLowerCase().contains(query) ||
          bill.statusLabel.toLowerCase().contains(query) ||
          bill.status.name.toLowerCase().contains(query) ||
          (query.contains('partial') && bill.status == BillStatus.partial) ||
          bill.lines.any((l) =>
              l.productName.toLowerCase().contains(query) ||
              l.packagingRuleKey.toLowerCase().contains(query));

      bool matchesFilter = true;
      if (filter == 'Pakka Bill') {
        matchesFilter = bill.type == BillType.gstInvoice;
      } else if (filter == 'Kaccha Bill') {
        matchesFilter = bill.type == BillType.cashMemo;
      }

      return matchesQuery && matchesFilter;
    }).toList();
    notifyListeners();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
