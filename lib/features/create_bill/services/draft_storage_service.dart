import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/draft_bill_model.dart';

class DraftStorageService {
  static final DraftStorageService _instance = DraftStorageService._internal();
  factory DraftStorageService() => _instance;
  DraftStorageService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const String _draftsKey = 'saved_draft_bills';

  /// Save or update a draft bill
  Future<void> saveDraft(DraftBillModel draft) async {
    final drafts = await getDrafts();
    final index = drafts.indexWhere((d) => d.id == draft.id);

    if (index != -1) {
      drafts[index] = draft;
    } else {
      drafts.insert(0, draft);
    }

    final jsonList = drafts.map((d) => d.toMap()).toList();
    await _storage.write(key: _draftsKey, value: jsonEncode(jsonList));
  }

  /// Retrieve all saved drafts sorted by saved date (newest first)
  Future<List<DraftBillModel>> getDrafts() async {
    try {
      final data = await _storage.read(key: _draftsKey);
      if (data == null || data.trim().isEmpty) {
        return [];
      }
      final decoded = jsonDecode(data) as List<dynamic>;
      final drafts = decoded
          .map((item) => DraftBillModel.fromMap(item as Map<String, dynamic>))
          .toList();
      drafts.sort((a, b) => b.savedAt.compareTo(a.savedAt));
      return drafts;
    } catch (_) {
      return [];
    }
  }

  /// Retrieve a specific draft by ID
  Future<DraftBillModel?> getDraftById(String id) async {
    final drafts = await getDrafts();
    final match = drafts.where((d) => d.id == id);
    return match.isNotEmpty ? match.first : null;
  }

  /// Retrieve the most recent draft
  Future<DraftBillModel?> getLatestDraft() async {
    final drafts = await getDrafts();
    return drafts.isNotEmpty ? drafts.first : null;
  }

  /// Delete a draft by ID
  Future<void> deleteDraft(String id) async {
    final drafts = await getDrafts();
    drafts.removeWhere((d) => d.id == id);
    final jsonList = drafts.map((d) => d.toMap()).toList();
    await _storage.write(key: _draftsKey, value: jsonEncode(jsonList));
  }

  /// Clear all saved drafts
  Future<void> clearAllDrafts() async {
    await _storage.delete(key: _draftsKey);
  }

  /// Get total count of pending drafts
  Future<int> getDraftsCount() async {
    final drafts = await getDrafts();
    return drafts.length;
  }
}
