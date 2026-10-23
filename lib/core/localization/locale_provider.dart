import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeStorageKey = 'selected_app_language';
  final FlutterSecureStorage _storage;

  Locale _locale = const Locale('en');

  Locale get locale => _locale;
  String get languageCode => _locale.languageCode;
  bool get isMarathi => _locale.languageCode == 'mr';
  bool get isEnglish => _locale.languageCode == 'en';

  LocaleProvider({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage() {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    try {
      final savedCode = await _storage.read(key: _localeStorageKey);
      if (savedCode != null && (savedCode == 'mr' || savedCode == 'en')) {
        _locale = Locale(savedCode);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading saved locale: $e');
    }
  }

  Future<void> setLocale(Locale newLocale) async {
    if (_locale == newLocale) return;
    if (newLocale.languageCode != 'en' && newLocale.languageCode != 'mr') return;

    _locale = newLocale;
    notifyListeners();

    try {
      await _storage.write(key: _localeStorageKey, value: newLocale.languageCode);
    } catch (e) {
      debugPrint('Error saving locale: $e');
    }
  }

  Future<void> toggleLanguage() async {
    if (isMarathi) {
      await setLocale(const Locale('en'));
    } else {
      await setLocale(const Locale('mr'));
    }
  }
}
