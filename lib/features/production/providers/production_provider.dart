import 'package:flutter/material.dart';
import '../../../core/services/storage_service.dart';
import '../models/production_batch_model.dart';
import '../services/production_api_service.dart';

class ProductionProvider extends ChangeNotifier {
  final ProductionApiService _apiService = ProductionApiService();
  final StorageService _storageService = StorageService();

  List<ProductionBatchModel> _batches = [];
  bool _isLoading = false;
  String? _errorMessage;
  ProductionBatchModel? _selectedBatch;
  String _searchQuery = '';

  List<ProductionBatchModel> get batches => _batches;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ProductionBatchModel? get selectedBatch => _selectedBatch;
  String get searchQuery => _searchQuery;

  /// Dynamic resolution of company ID (no hardcoded fallbacks)
  Future<String> _resolveCompanyId(String? companyId) async {
    if (companyId != null && companyId.isNotEmpty) return companyId;

    final stored = await _storageService.getCompanyId();
    if (stored != null && stored.isNotEmpty) return stored;

    final userData = await _storageService.getUserData();
    if (userData != null) {
      if (userData['company'] != null) {
        final comp = userData['company'];
        if (comp is Map<String, dynamic>) {
          return comp['_id']?.toString() ?? comp['id']?.toString() ?? '';
        } else if (comp is String) {
          return comp;
        }
      } else if (userData['companies'] != null) {
        final comps = userData['companies'];
        if (comps is List && comps.isNotEmpty) {
          final firstComp = comps.first;
          if (firstComp is Map<String, dynamic>) {
            return firstComp['_id']?.toString() ??
                firstComp['id']?.toString() ??
                '';
          }
        }
      }
    }
    return '';
  }

  /// Fetch unique batches from /api/production/unique/batch
  Future<void> fetchUniqueBatches({
    String? companyId,
    String? query,
    bool showLoading = true,
  }) async {
    final resolvedCompanyId = await _resolveCompanyId(companyId);
    if (resolvedCompanyId.isEmpty) {
      debugPrint('[ProductionProvider] No company ID found. Skipping batch fetch.');
      _batches = [];
      _errorMessage = 'No company ID found.';
      notifyListeners();
      return;
    }

    if (showLoading) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      _searchQuery = query ?? '';
      final results = await _apiService.getUniqueBatches(
        companyId: resolvedCompanyId,
        query: query,
      );
      _batches = results;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _batches = [];
      debugPrint('[ProductionProvider] fetchUniqueBatches error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Search batches dynamically with query string
  Future<void> searchBatches(
    String query, {
    String? companyId,
  }) async {
    _searchQuery = query;
    await fetchUniqueBatches(
      companyId: companyId,
      query: query,
      showLoading: false,
    );
  }

  /// Select a batch
  void selectBatch(ProductionBatchModel? batch) {
    _selectedBatch = batch;
    notifyListeners();
  }

  /// Filter current batches by sizeKey (e.g. "1L")
  List<ProductionBatchModel> getBatchesForSizeKey(String sizeKey) {
    return _batches
        .where((b) => b.sizeKey.toLowerCase() == sizeKey.toLowerCase())
        .toList();
  }

  /// Clear state
  void clear() {
    _batches = [];
    _selectedBatch = null;
    _errorMessage = null;
    _isLoading = false;
    _searchQuery = '';
    notifyListeners();
  }
}
