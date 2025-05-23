import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FontProvider with ChangeNotifier {
  static const _key = 'selectedFont';
  String _selectedFont = 'Mochiy Pop One';

  String get selectedFont => _selectedFont;

  FontProvider() {
    _loadFont();
  }

  Future<void> _loadFont() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedFont = prefs.getString(_key) ?? 'Mochiy Pop One';
    notifyListeners();
  }

  Future<void> setFont(String font) async {
    final prefs = await SharedPreferences.getInstance();
    _selectedFont = font;
    await prefs.setString(_key, font);
    notifyListeners();
  }
}
