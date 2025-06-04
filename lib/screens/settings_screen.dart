import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../setting/locale_provider.dart'; // 自作したロケールクラス
import '../l10n/app_localizations.dart';
import '../l10n/l10n.dart';
import '../setting/theme_provider.dart';
import '../setting/app_themes.dart';
import '../screens/intro_screen.dart';
import '../setting/font_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocaleProvider>(context);
    final currentLocale = provider.locale ?? Localizations.localeOf(context);

    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentTheme = themeProvider.theme;

    final fontProvider = Provider.of<FontProvider>(context);
    final currentFont = fontProvider.selectedFont;

    final fontOptions = [
      'Mochiy Pop One',
      'Kosugi Maru',
      'Yusei Magic',
      'RocknRoll One',
      'Roboto',
      'Poppins',
      'Pacifico',
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settingsTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.language,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: isDark ? Colors.white : Colors.black)),
            SizedBox(height: 10),
            DropdownButton<Locale>(
              value: currentLocale,
              onChanged: (Locale? locale) {
                if (locale != null) {
                  provider.setLocale(locale);
                }
              },
              items: L10n.supportedLocales.map((locale) {
                final langLabel = _getLocaleLabel(locale.languageCode);
                return DropdownMenuItem(
                  value: locale,
                  child: Text(langLabel,
                      style: TextStyle(
                          color: isDark ? Colors.white : Colors.black)),
                );
              }).toList(),
            ),
            SizedBox(height: 10),
            Text(AppLocalizations.of(context)!.theme,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: isDark ? Colors.white : Colors.black)),
            SizedBox(height: 10),
            DropdownButton<AppTheme>(
              value: currentTheme,
              onChanged: (AppTheme? newTheme) {
                if (newTheme != null) {
                  themeProvider.setTheme(newTheme);
                }
              },
              items: AppTheme.values.map((theme) {
                return DropdownMenuItem(
                  value: theme,
                  child: Text(_getThemeLabel(theme, context),
                      style: TextStyle(
                          color: isDark ? Colors.white : Colors.black)),
                );
              }).toList(),
            ),
            SizedBox(height: 10),
            Text(AppLocalizations.of(context)!.font,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: isDark ? Colors.white : Colors.black)),
            SizedBox(height: 10),
            DropdownButton<String>(
              value: currentFont,
              onChanged: (String? font) {
                if (font != null) {
                  fontProvider.setFont(font);
                }
              },
              items: fontOptions.map((font) {
                return DropdownMenuItem<String>(
                  value: font,
                  child: Text('あいう ABC',
                      style: GoogleFonts.getFont(font).copyWith(
                          color: isDark ? Colors.white : Colors.black)),
                );
              }).toList(),
            ),
            SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(AppLocalizations.of(context)!.show_guide),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => IntroScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getLocaleLabel(String code) {
    switch (code) {
      case 'ja':
        return '🇯🇵 日本語';
      case 'en':
        return '🇺🇸 English';
      case 'zh':
        return '🇨🇳 中文';
      default:
        return code;
    }
  }

  String _getThemeLabel(AppTheme theme, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (theme) {
      case AppTheme.pinkLight:
        return l10n.theme_pinkLight;
      case AppTheme.pinkDark:
        return l10n.theme_pinkDark;
      case AppTheme.mintLight:
        return l10n.theme_mintLight;
      case AppTheme.mintDark:
        return l10n.theme_mintDark;
      case AppTheme.lavenderLight:
        return l10n.theme_lavenderLight;
      case AppTheme.lavenderDark:
        return l10n.theme_lavenderDark;
      case AppTheme.white:
        return l10n.theme_white;
      case AppTheme.black:
        return l10n.theme_black;
    }
  }
}
