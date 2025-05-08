import 'package:flutter/material.dart';
import 'package:nakimemo/setting/layout_provider.dart';
import 'package:nakimemo/setting/layout_type.dart';
import 'package:provider/provider.dart';
import '../setting/locale_provider.dart'; // 自作したロケールクラス
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../l10n/l10n.dart';
import '../setting/theme_provider.dart';
import '../setting/app_themes.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocaleProvider>(context);
    final currentLocale = provider.locale ?? Localizations.localeOf(context);

    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentTheme = themeProvider.theme;

    final layoutProvider = Provider.of<LayoutProvider>(context);
    final currentLayout = layoutProvider.layoutType;

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
                style: Theme.of(context).textTheme.titleMedium),
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
                  child: Text(langLabel),
                );
              }).toList(),
            ),
            SizedBox(height: 10),
            Text(AppLocalizations.of(context)!.theme,
                style: Theme.of(context).textTheme.titleMedium),
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
                  child: Text(_getThemeLabel(theme)),
                );
              }).toList(),
            ),
            SizedBox(height: 10),
            Text(AppLocalizations.of(context)!.layout,
                style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 10),
            DropdownButton<LayoutType>(
              value: currentLayout,
              onChanged: (LayoutType? newLayout) {
                if (newLayout != null) {
                  layoutProvider.setLayoutType(newLayout);
                }
              },
              items: LayoutType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_getLayoutLabel(type)),
                );
              }).toList(),
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

  String _getThemeLabel(AppTheme theme) {
    switch (theme) {
      case AppTheme.pink:
        return '🌸 ピンク';
      case AppTheme.mint:
        return '🌿 ミント';
      case AppTheme.lavender:
        return '💜 ラベンダー';
      default:
        return theme.toString();
    }
  }

  String _getLayoutLabel(LayoutType type) {
    switch (type) {
      case LayoutType.list:
        return '📋 リスト表示';
      case LayoutType.grid:
        return '🔲 グリッド表示';
      default:
        return type.toString();
    }
  }
}
