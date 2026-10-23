import 'package:flutter/material.dart';
import '../../../core/services/storage_service.dart';
import '../models/customer_model.dart';
import '../services/customer_api_service.dart';

class CustomerProvider extends ChangeNotifier {
  final CustomerApiService _apiService = CustomerApiService();
  final StorageService _storageService = StorageService();

  List<CustomerModel> _customers = [];
  List<CustomerModel> _filteredCustomers = [];
  CustomerModel? _selectedCustomer;
  bool _isLoading = false;
  bool _isCreating = false;
  String? _errorMessage;

  List<CustomerModel> get customers => _customers;
  List<CustomerModel> get filteredCustomers =>
      _filteredCustomers.isNotEmpty || _customers.isEmpty
          ? _filteredCustomers
          : _customers;
  CustomerModel? get selectedCustomer => _selectedCustomer;
  bool get isLoading => _isLoading;
  bool get isCreating => _isCreating;
  String? get errorMessage => _errorMessage;

  Future<void> fetchCustomers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetched = await _apiService.getCustomers();
      _customers = fetched;
      _filteredCustomers = fetched;
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

  Future<CustomerModel> createCustomer({
    String? companyId,
    String? customerId,
    required String name,
    String? contactPerson,
    String? mobile,
    String? gstNo,
    String? address,
    String? city,
    double creditLimit = 0.0,
    double openingBalance = 0.0,
    double? outstandingBalance,
  }) async {
    _isCreating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String finalCompanyId = companyId ?? '';
      if (finalCompanyId.isEmpty) {
        final storedCompanyId = await _storageService.getCompanyId();
        if (storedCompanyId != null && storedCompanyId.isNotEmpty) {
          finalCompanyId = storedCompanyId;
        } else {
          final userData = await _storageService.getUserData();
          if (userData != null) {
            if (userData['company'] != null) {
              final comp = userData['company'];
              if (comp is Map<String, dynamic>) {
                finalCompanyId = comp['_id']?.toString() ?? comp['id']?.toString() ?? '';
              } else if (comp is String) {
                finalCompanyId = comp;
              }
            } else if (userData['companies'] != null) {
              final comps = userData['companies'];
              if (comps is List && comps.isNotEmpty) {
                final firstComp = comps.first;
                if (firstComp is Map<String, dynamic>) {
                  finalCompanyId = firstComp['_id']?.toString() ?? firstComp['id']?.toString() ?? '';
                } else if (firstComp is String) {
                  finalCompanyId = firstComp;
                }
              }
            }
          }
        }
      }

      String finalCustomerId = customerId ?? '';
      if (finalCustomerId.isEmpty) {
        final nextNum = _customers.length + 1;
        finalCustomerId = 'RKC${nextNum.toString().padLeft(3, '0')}';
      }

      final newCustomer = await _apiService.createCustomer(
        companyId: finalCompanyId,
        customerId: finalCustomerId,
        name: name,
        contactPerson: contactPerson,
        mobile: mobile,
        gstNo: gstNo,
        address: address,
        city: city,
        creditLimit: creditLimit,
        openingBalance: openingBalance,
        outstandingBalance: outstandingBalance ?? openingBalance,
      );

      _customers = [newCustomer, ..._customers];
      _filteredCustomers = _customers;
      _selectedCustomer = newCustomer;
      _isCreating = false;
      notifyListeners();
      return newCustomer;
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

  void filterCustomers(String query) {
    if (query.trim().isEmpty) {
      _filteredCustomers = _customers;
    } else {
      final lower = query.toLowerCase().trim();
      _filteredCustomers = _customers.where((c) {
        return c.name.toLowerCase().contains(lower) ||
            c.customerId.toLowerCase().contains(lower) ||
            (c.mobile != null && c.mobile!.contains(lower)) ||
            (c.city != null && c.city!.toLowerCase().contains(lower));
      }).toList();
    }
    notifyListeners();
  }

  List<CustomerModel> getCustomersForCompany({
    String? companyId,
    String? companyName,
  }) {
    if ((companyId == null || companyId.isEmpty) &&
        (companyName == null || companyName.isEmpty)) {
      return [];
    }

    final filtered = _customers.where((c) {
      if (companyId != null && companyId.isNotEmpty) {
        if (c.companyId == companyId ||
            (c.company != null && c.company!.id == companyId)) {
          return true;
        }
      }
      if (companyName != null && companyName.isNotEmpty) {
        if (c.company != null &&
            c.company!.name.toLowerCase() == companyName.toLowerCase()) {
          return true;
        }
      }
      return false;
    }).toList();

    return filtered;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
