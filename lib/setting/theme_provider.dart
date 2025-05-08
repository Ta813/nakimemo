import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_themes.dart';

class ThemeProvider extends ChangeNotifier {
  AppTheme _theme = AppTheme.pink;

  AppTheme get theme => _theme;

  ThemeProvider() {
    _loadTheme();
  }

  void setTheme(AppTheme newTheme) {
    _theme = newTheme;
    _saveTheme();
    notifyListeners();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('theme') ?? 0;
    _theme = AppTheme.values[themeIndex];
    notifyListeners();
  }

  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme', _theme.index);
  }
}
