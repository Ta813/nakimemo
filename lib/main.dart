// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:nakimemo/screens/intro_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
import 'package:home_widget/home_widget.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'setting/monthly.dart';
import 'setting/font_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase/firebase_common.dart';
import 'screens/auth_screen.dart';

bool _isFirstLaunch = true;
Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    final prefs = await SharedPreferences.getInstance();
    _isFirstLaunch = prefs.getBool('is_first_launch') ?? true;
    final font = prefs.getString('selectedFont') ?? 'Mochiy Pop One';

    //firebase初期化
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    if (!kIsWeb) {
      await dotenv.load();
      HomeWidget.registerInteractivityCallback(interactiveCallback);
      await MobileAds.instance.initialize();

      // 定期課金の初期化
      Monthly monthly = Monthly();
      monthly.listenToPurchaseUpdates();
    }
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => FontProvider()),
        ],
        child: MyApp(selectedFont: font),
      ),
    );
  } catch (e) {
    print('Error loading environment variables: $e');
  }
}

@pragma('vm:entry-point')
void interactiveCallback(dynamic uri) async {
  // ウィジェットからのコールバックを受け取る
  print('main.dart interactiveCallback called: $uri');
  if (uri?.host == 'cry') {
    // ここで「泣いた！」の処理を実装
    final lastCryTime = uri?.queryParameters?['last_cry_time'];
    final timeStr = lastCryTime.split(' ')[1];
    final entry = '$timeStr 泣いた！';

    final todayKey = lastCryTime.split(' ')[0];

    FirebaseCommon firebaseCommon = new FirebaseCommon();
    //firebaseからデータを取得
    List<String> todayLogs =
        await firebaseCommon.loadLogsFromFirestore(todayKey);

    todayLogs.add(entry);

    //firebaseにデータを保存
    await firebaseCommon.saveLogToFirestore(todayKey, todayLogs);
  }
}

class MyApp extends StatelessWidget {
  final String selectedFont;
  const MyApp({required this.selectedFont});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final fontProvider = Provider.of<FontProvider>(context);

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
          theme: appThemeData[themeProvider.theme]!.copyWith(
            textTheme: GoogleFonts.getTextTheme(fontProvider.selectedFont),
          ),
          home: AuthGate(),
        );
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Firebase接続中
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        // 未ログイン → 認証画面へ
        if (!snapshot.hasData) {
          return AuthScreen(); // 認証画面（後述）
        }

        // ログイン済み → メイン画面へ
        return _isFirstLaunch ? IntroScreen() : HomePage(); // あなたのトップ画面
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
