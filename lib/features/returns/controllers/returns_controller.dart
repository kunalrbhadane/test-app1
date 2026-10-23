import 'package:flutter/material.dart';
import '../../home/models/bill_model.dart';
import '../models/return_model.dart';

class ReturnsController extends ChangeNotifier {
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

  List<ReturnModel> _allReturns = [];
  List<ReturnModel> _filteredReturns = [];
  List<ReturnModel> get filteredReturns => _filteredReturns;

  /// Load and convert bills with returns from backend data
  void setBills(List<BillModel> bills) {
    _allReturns = bills
        .where((b) => b.hasReturns)
        .map((b) => ReturnModel.fromBillModel(b))
        .toList();
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

    _filteredReturns = _allReturns.where((item) {
      final matchesQuery = query.isEmpty ||
          item.partyName.toLowerCase().contains(query) ||
          item.invoiceNumber.toLowerCase().contains(query);

      bool matchesFilter = true;
      if (filter == 'Pakka Bill') {
        matchesFilter = item.billType == ReturnBillType.pakkaBill;
      } else if (filter == 'Kaccha Bill') {
        matchesFilter = item.billType == ReturnBillType.kacchaBill;
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
