import 'package:flutter/material.dart';
import 'screens/input_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/stats_screen.dart'; // 統計画面
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'setting/locale_provider.dart';
import 'setting/theme_provider.dart';
import 'screens/settings_screen.dart'; // 設定画面
import 'setting/app_themes.dart';
import 'setting/layout_provider.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    if (!kIsWeb) {
      await dotenv.load();
    }
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => LayoutProvider()),
        ],
        child: MyApp(),
      ),
    );
  } catch (e) {
    print('Error loading environment variables: $e');
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Consumer<LocaleProvider>(
      builder: (context, provider, _) {
        if (!provider.isLoaded) {
          // 初期化完了までローディング画面を表示
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        return MaterialApp(
          locale: provider.locale ?? const Locale('en', 'US'),
          supportedLocales: [
            Locale('ja', 'JP'),
            Locale('en', 'US'),
            Locale('zh', 'ZH'),
          ],
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            if (provider.locale != null) return provider.locale!;
            if (locale == null) return supportedLocales.first;
            return supportedLocales.firstWhere(
              (l) => l.languageCode == locale.languageCode,
              orElse: () => supportedLocales.first,
            );
          },
          title: "ナキメモ",
          theme: appThemeData[themeProvider.theme],
          home: HomePage(),
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    InputScreen(),
    CalendarScreen(),
    StatsScreen(), // 統計画面
    SettingsScreen(), // 設定画面
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: AppLocalizations.of(context)!.input_label,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: AppLocalizations.of(context)!.calendar_label,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: AppLocalizations.of(context)!.stats_label,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: AppLocalizations.of(context)!.setting_label,
          ),
        ],
      ),
    );
  }
}
