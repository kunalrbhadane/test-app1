import 'package:flutter/material.dart';
import '../../../core/services/storage_service.dart';
import '../models/company_model.dart';
import '../services/company_api_service.dart';

class CompanyProvider extends ChangeNotifier {
  final CompanyApiService _apiService = CompanyApiService();
  final StorageService _storageService = StorageService();

  List<CompanyModel> _companies = [];
  CompanyModel? _selectedCompany;
  bool _isLoading = false;
  String? _errorMessage;

  List<CompanyModel> get companies => _companies;
  CompanyModel? get selectedCompany => _selectedCompany;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchCompanies() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetched = await _apiService.getCompanies();
      _companies = fetched;

      // Restore previously saved company or select the first one
      final savedCompanyId = await _storageService.getCompanyId();
      if (savedCompanyId != null && savedCompanyId.isNotEmpty) {
        final match = _companies.where((c) => c.id == savedCompanyId).toList();
        if (match.isNotEmpty) {
          _selectedCompany = match.first;
        } else if (_companies.isNotEmpty) {
          _selectedCompany = _companies.first;
          await _storageService.saveCompanyId(_selectedCompany!.id);
        }
      } else if (_companies.isNotEmpty) {
        _selectedCompany = _companies.first;
        await _storageService.saveCompanyId(_selectedCompany!.id);
      }

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

  void selectCompany(CompanyModel? company) {
    _selectedCompany = company;
    if (company != null) {
      _storageService.saveCompanyId(company.id);
    }
    notifyListeners();
  }

  void selectCompanyByName(String? companyName) {
    if (companyName == null) {
      _selectedCompany = null;
    } else {
      final match = _companies.where((c) => c.name == companyName).toList();
      if (match.isNotEmpty) {
        selectCompany(match.first);
        return;
      }
    }
    notifyListeners();
  }

  void selectCompanyById(String? companyId) {
    if (companyId == null) {
      _selectedCompany = null;
    } else {
      final match = _companies.where((c) => c.id == companyId).toList();
      if (match.isNotEmpty) {
        selectCompany(match.first);
        return;
      }
    }
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
