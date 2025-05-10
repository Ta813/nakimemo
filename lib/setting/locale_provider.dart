import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale? _locale;
  bool _isLoaded = false;

  Locale? get locale => _locale;
  bool get isLoaded => _isLoaded;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('languageCode');
    final countryCode = prefs.getString('countryCode');
    if (code != null) {
      _locale = Locale(code, countryCode);
    } else {
      // 初回：端末のロケールに基づく
      final systemLocale = PlatformDispatcher.instance.locale;
      if (['ja', 'en', 'zh'].contains(systemLocale.languageCode)) {
        String countryCode = "";
        if (systemLocale.languageCode == 'ja') {
          countryCode = 'JP';
        } else if (systemLocale.languageCode == 'en') {
          countryCode = 'US';
        } else if (systemLocale.languageCode == 'zh') {
          countryCode = 'CN';
        }
        _locale = Locale(systemLocale.languageCode, countryCode);
      } else {
        _locale = Locale('en', 'US'); // デフォルト
      }
    }
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
    await prefs.setString('countryCode', locale.countryCode ?? '');
    _locale = locale;
    notifyListeners();
  }

  void clearLocale() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('languageCode');
    await prefs.remove('countryCode');
    _locale = null;
    notifyListeners();
  }
}
