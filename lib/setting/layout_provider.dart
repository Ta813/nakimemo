import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'layout_type.dart';

class LayoutProvider extends ChangeNotifier {
  LayoutType _layoutType = LayoutType.list;

  LayoutType get layoutType => _layoutType;

  LayoutProvider() {
    _loadLayoutType();
  }

  void setLayoutType(LayoutType type) {
    _layoutType = type;
    _saveLayoutType();
    notifyListeners();
  }

  Future<void> _loadLayoutType() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt('layoutType') ?? 0;
    _layoutType = LayoutType.values[index];
    notifyListeners();
  }

  Future<void> _saveLayoutType() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('layoutType', _layoutType.index);
  }
}
