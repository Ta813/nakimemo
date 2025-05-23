import 'package:flutter/material.dart';

enum AppTheme {
  pinkLight,
  pinkDark,
  mintLight,
  mintDark,
  lavenderLight,
  lavenderDark,
  white,
  black,
}

final appThemeData = {
  AppTheme.pinkLight: ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.pink[200],
    cardColor: Colors.white,
    scaffoldBackgroundColor: Colors.pink[50],
    colorScheme: ColorScheme.light(primary: Colors.pink[300]!),
  ),
  AppTheme.pinkDark: ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.pink[200],
    cardColor: Colors.black,
    scaffoldBackgroundColor: Colors.pink[900],
    colorScheme: ColorScheme.dark(primary: Colors.pink[300]!),
  ),
  AppTheme.mintLight: ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.teal[200],
    cardColor: Colors.white,
    scaffoldBackgroundColor: Colors.teal[50],
    colorScheme: ColorScheme.light(primary: Colors.teal[300]!),
  ),
  AppTheme.mintDark: ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.teal[200],
    cardColor: Colors.black,
    scaffoldBackgroundColor: Colors.teal[900],
    colorScheme: ColorScheme.dark(primary: Colors.teal[300]!),
  ),
  AppTheme.lavenderLight: ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.purple[200],
    cardColor: Colors.white,
    scaffoldBackgroundColor: Colors.purple[50],
    colorScheme: ColorScheme.light(primary: Colors.purple[300]!),
  ),
  AppTheme.lavenderDark: ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.purple[200],
    cardColor: Colors.black,
    scaffoldBackgroundColor: Colors.purple[900],
    colorScheme: ColorScheme.dark(primary: Colors.purple[300]!),
  ),
  AppTheme.white: ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.white,
    cardColor: Colors.white,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.light(
      primary: Colors.grey[800]!,
      secondary: Colors.grey[600]!,
    ),
  ),
  AppTheme.black: ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.black,
    cardColor: Colors.grey[800]!,
    scaffoldBackgroundColor: Colors.black,
    colorScheme: ColorScheme.dark(
      primary: Colors.grey[600]!,
      secondary: Colors.grey[600]!,
    ),
  ),
};
