import 'package:flutter/material.dart';
import '../../../core/services/storage_service.dart';
import '../models/size_master_bottle_model.dart';
import '../models/size_master_model.dart';
import '../services/size_master_api_service.dart';

class SizeMasterProvider extends ChangeNotifier {
  final SizeMasterApiService _apiService = SizeMasterApiService();
  final StorageService _storageService = StorageService();

  // Available bottle sizes from /size-masters
  List<SizeMasterModel> _sizeMasters = [];
  List<SizeMasterModel> get sizeMasters => _sizeMasters;

  // Products from /get/good/bottels
  List<SizeMasterBottleModel> _bottles = [];
  SizeMasterBottleModel? _selectedBottle;
  String? _selectedSizeKey;
  bool _isLoading = false;
  String? _errorMessage;

  List<SizeMasterBottleModel> get bottles => _bottles;
  SizeMasterBottleModel? get selectedBottle => _selectedBottle;
  String? get selectedSizeKey => _selectedSizeKey;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Get the list of distinct bottle sizes from /size-masters API
  List<String> get availableSizes {
    return _sizeMasters
        .map((s) => s.bottleSize)
        .where((s) => s.trim().isNotEmpty)
        .toSet()
        .toList();
  }

  /// Resolve company ID from storage if not provided.
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
          } else if (firstComp is String) {
            return firstComp;
          }
        }
      }
    }
    return '';
  }

  /// Fetch available bottle sizes from /api/size-masters?company=<companyId>
  Future<void> fetchSizeMasters({String? companyId}) async {
    try {
      final finalCompanyId = await _resolveCompanyId(companyId);
      debugPrint('[SizeMasterProvider] fetchSizeMasters => companyId: $finalCompanyId');

      if (finalCompanyId.isEmpty) {
        debugPrint('[SizeMasterProvider] companyId is empty, skipping size-masters fetch');
        return;
      }

      final fetched = await _apiService.getSizeMasters(
        companyId: finalCompanyId,
      );

      _sizeMasters = fetched;
      debugPrint('[SizeMasterProvider] fetched ${fetched.length} sizes: ${fetched.map((s) => s.bottleSize).toList()}');

      // Auto-select first size if none selected and fetch its products
      if (_sizeMasters.isNotEmpty && _selectedSizeKey == null) {
        _selectedSizeKey = _sizeMasters.first.bottleSize;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('[SizeMasterProvider] fetchSizeMasters ERROR: $e');
    }
  }

  /// Fetch products from /api/size-masters/get/good/bottels?company=<companyId>&sizeKey=<sizeKey>
  Future<void> fetchGoodBottles({
    String? companyId,
    String? sizeKey,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _bottles = [];
    _selectedBottle = null;
    if (sizeKey != null) {
      _selectedSizeKey = sizeKey.isNotEmpty ? sizeKey : null;
    }
    notifyListeners();

    try {
      final finalCompanyId = await _resolveCompanyId(companyId);
      debugPrint('[SizeMasterProvider] fetchGoodBottles => companyId: $finalCompanyId, sizeKey: $_selectedSizeKey');

      if (finalCompanyId.isEmpty) {
        debugPrint('[SizeMasterProvider] companyId is empty, skipping good-bottles fetch');
        _isLoading = false;
        notifyListeners();
        return;
      }

      final fetched = await _apiService.getGoodBottles(
        companyId: finalCompanyId,
        sizeKey: _selectedSizeKey,
      );

      debugPrint('[SizeMasterProvider] fetched ${fetched.length} products');

      _bottles = fetched;
      if (_bottles.isNotEmpty) {
        _selectedBottle = _bottles.first;
      } else {
        _selectedBottle = null;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      String error = e.toString();
      debugPrint('[SizeMasterProvider] fetchGoodBottles ERROR: $error');
      if (error.startsWith('Exception: ')) {
        error = error.substring('Exception: '.length);
      }
      _errorMessage = error;
      notifyListeners();
    }
  }

  /// Fetch both sizes and products in one call
  Future<void> fetchAll({String? companyId}) async {
    await fetchSizeMasters(companyId: companyId);
    await fetchGoodBottles(companyId: companyId, sizeKey: _selectedSizeKey);
  }

  void selectSizeKey(String? sizeKey, {String? companyId}) {
    _selectedSizeKey = sizeKey;
    fetchGoodBottles(companyId: companyId, sizeKey: sizeKey);
  }

  void selectBottle(SizeMasterBottleModel? bottle) {
    _selectedBottle = bottle;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
