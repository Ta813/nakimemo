import 'package:flutter/material.dart';

enum AppTheme {
  pink,
  mint,
  lavender,
}

final appThemeData = {
  AppTheme.pink: ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.pink[200],
    scaffoldBackgroundColor: Colors.pink[50],
    colorScheme: ColorScheme.light(primary: Colors.pink[300]!),
  ),
  AppTheme.mint: ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.teal[200],
    scaffoldBackgroundColor: Colors.teal[50],
    colorScheme: ColorScheme.light(primary: Colors.teal[300]!),
  ),
  AppTheme.lavender: ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.purple[200],
    scaffoldBackgroundColor: Colors.purple[50],
    colorScheme: ColorScheme.light(primary: Colors.purple[300]!),
  ),
};
