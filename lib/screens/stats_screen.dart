// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../setting/monthly.dart';
import '../firebase/firebase_common.dart';
import '../setting/rewarded_ad_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatsScreen extends StatefulWidget {
  @override
  _StatsScreenState createState() => _StatsScreenState();
}

enum DisplayUnit { month, week, day, all }

class _StatsScreenState extends State<StatsScreen> {
  DisplayUnit _selectedUnit = DisplayUnit.day;

  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  int selectedWeek = ((DateTime.now().day - 1) / 7).floor() + 1;
  int selectedDay = DateTime.now().day;
  Map<String, int> categoryCounts = {};
  Map<String, List<String>> selectedLogs = {};

  bool isDark = false;

  BannerAd? _bannerAd;

  final adManager = RewardedAdManager();

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      adManager.loadAd();
      // バナー広告の初期化
      _bannerAd = BannerAd(
        adUnitId:
            'ca-app-pub-2333753292729105/6235645365', // ご自身のAdMobバナーIDに置き換えてください
        size: AdSize.banner,
        request: AdRequest(),
        listener: BannerAdListener(),
      )..load();
    }
    _updateCategoryCounts();
  }

  /// カテゴリ別の件数を更新する
  void _updateCategoryCounts() async {
    if (_selectedUnit == DisplayUnit.month) {
      final counts =
          await getMonthlyCategoryCounts(DateTime(selectedYear, selectedMonth));
      setState(() {
        categoryCounts = counts;
      });
    } else if (_selectedUnit == DisplayUnit.week) {
      final counts = await getWeeklyCategoryCounts(
          selectedYear, selectedMonth, selectedWeek);

      setState(() {
        categoryCounts = counts;
      });
    } else if (_selectedUnit == DisplayUnit.day) {
      final counts = await getDailyCategoryCounts(
          selectedYear, selectedMonth, selectedDay);
      setState(() {
        categoryCounts = counts;
      });
    } else if (_selectedUnit == DisplayUnit.all) {
      final counts = await getAllCategoryCounts();
      setState(() {
        categoryCounts = counts;
      });
    }
  }

  /// ログを全て読み込む
  /// [key] : YYYY-MM形式の文字列
  Future<Map<String, List<String>>> _loadAllLogs() async {
    FirebaseCommon firebaseCommon = new FirebaseCommon();

    //firebaseからデータを取得
    return await firebaseCommon.getAllLogs();
  }

  /// 月ごとのカテゴリ別の件数を取得する
  /// [month] : YYYY-MM形式の文字列
  Future<Map<String, int>> getMonthlyCategoryCounts(DateTime month) async {
    final allLogs = await _loadAllLogs();
    final counts = <String, int>{};
    final logs = Map<String, List<String>>();

    final targetMonth =
        '${month.year}-${month.month.toString().padLeft(2, '0')}';

    for (final entry in allLogs.entries) {
      if (entry.key.startsWith(targetMonth)) {
        for (final log in entry.value) {
          if (log.contains('泣いた！')) {
            counts['泣いた！'] = (counts['泣いた！'] ?? 0) + 1;
          } else if (log.contains('ミルク')) {
            counts['ミルク'] = (counts['ミルク'] ?? 0) + 1;
          } else if (log.contains('おむつ')) {
            counts['おむつ'] = (counts['おむつ'] ?? 0) + 1;
          } else if (log.contains('眠い')) {
            counts['眠い'] = (counts['眠い'] ?? 0) + 1;
          } else if (log.contains('抱っこ')) {
            counts['抱っこ'] = (counts['抱っこ'] ?? 0) + 1;
          } else if (log.contains('不快')) {
            counts['不快'] = (counts['不快'] ?? 0) + 1;
          } else if (log.contains('体調不良')) {
            counts['体調不良'] = (counts['体調不良'] ?? 0) + 1;
          }
        }
        logs[entry.key] = List<String>.from(entry.value);
      }
    }
    setState(() {
      selectedLogs = logs;
    });
    return counts;
  }

  /// 週ごとのカテゴリ別の件数を取得する
  /// [year] : 年
  /// [month] : 月
  /// [week] : 週
  Future<Map<String, int>> getWeeklyCategoryCounts(
      int year, int month, int week) async {
    final allLogs = await _loadAllLogs();
    final counts = <String, int>{};
    final logs = Map<String, List<String>>();

    // 指定された月の最初の日付
    final firstDayOfMonth = DateTime(year, month, 1);

    // 指定された週の開始日と終了日を計算
    final firstDayOfWeek = firstDayOfMonth.add(Duration(days: (week - 1) * 7));
    final lastDayOfWeek = firstDayOfWeek.add(const Duration(days: 6));

    for (final entry in allLogs.entries) {
      // ログの日付を解析
      final logDate = DateTime.tryParse(entry.key);
      if (logDate == null) continue;

      // ログの日付が指定された週に該当するか確認
      if (logDate.isAfter(lastDayOfWeek) || logDate.isBefore(firstDayOfWeek)) {
        continue;
      }

      for (final log in entry.value) {
        if (log.contains('泣いた！')) {
          counts['泣いた！'] = (counts['泣いた！'] ?? 0) + 1;
        } else if (log.contains('ミルク')) {
          counts['ミルク'] = (counts['ミルク'] ?? 0) + 1;
        } else if (log.contains('おむつ')) {
          counts['おむつ'] = (counts['おむつ'] ?? 0) + 1;
        } else if (log.contains('眠い')) {
          counts['眠い'] = (counts['眠い'] ?? 0) + 1;
        } else if (log.contains('抱っこ')) {
          counts['抱っこ'] = (counts['抱っこ'] ?? 0) + 1;
        } else if (log.contains('不快')) {
          counts['不快'] = (counts['不快'] ?? 0) + 1;
        } else if (log.contains('体調不良')) {
          counts['体調不良'] = (counts['体調不良'] ?? 0) + 1;
        }
      }
      logs[entry.key] = List<String>.from(entry.value);
    }

    setState(() {
      selectedLogs = logs;
    });
    return counts;
  }

  /// 週ごとのカテゴリ別の件数を取得する
  Future<Map<String, int>> getDailyCategoryCounts(
      int year, int month, int day) async {
    final allLogs = await _loadAllLogs();
    final counts = <String, int>{};
    final logs = Map<String, List<String>>();

    final targetDay =
        '${year}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

    for (final entry in allLogs.entries) {
      if (entry.key.startsWith(targetDay)) {
        for (final log in entry.value) {
          if (log.contains('泣いた！')) {
            counts['泣いた！'] = (counts['泣いた！'] ?? 0) + 1;
          } else if (log.contains('ミルク')) {
            counts['ミルク'] = (counts['ミルク'] ?? 0) + 1;
          } else if (log.contains('おむつ')) {
            counts['おむつ'] = (counts['おむつ'] ?? 0) + 1;
          } else if (log.contains('眠い')) {
            counts['眠い'] = (counts['眠い'] ?? 0) + 1;
          } else if (log.contains('抱っこ')) {
            counts['抱っこ'] = (counts['抱っこ'] ?? 0) + 1;
          } else if (log.contains('不快')) {
            counts['不快'] = (counts['不快'] ?? 0) + 1;
          } else if (log.contains('体調不良')) {
            counts['体調不良'] = (counts['体調不良'] ?? 0) + 1;
          }
        }
        logs[entry.key] = List<String>.from(entry.value);
      }
    }
    setState(() {
      selectedLogs = logs;
    });
    return counts;
  }

  /// 全てのカテゴリ別の件数を取得する
  /// [key] : YYYY-MM形式の文字列
  /// [month] : 月
  /// [year] : 年
  Future<Map<String, int>> getAllCategoryCounts() async {
    final allLogs = await _loadAllLogs();
    final counts = <String, int>{};
    final logs = Map<String, List<String>>();

    for (final entry in allLogs.entries) {
      for (final log in entry.value) {
        if (log.contains('泣いた！')) {
          counts['泣いた！'] = (counts['泣いた！'] ?? 0) + 1;
        } else if (log.contains('ミルク')) {
          counts['ミルク'] = (counts['ミルク'] ?? 0) + 1;
        } else if (log.contains('おむつ')) {
          counts['おむつ'] = (counts['おむつ'] ?? 0) + 1;
        } else if (log.contains('眠い')) {
          counts['眠い'] = (counts['眠い'] ?? 0) + 1;
        } else if (log.contains('抱っこ')) {
          counts['抱っこ'] = (counts['抱っこ'] ?? 0) + 1;
        } else if (log.contains('不快')) {
          counts['不快'] = (counts['不快'] ?? 0) + 1;
        } else if (log.contains('体調不良')) {
          counts['体調不良'] = (counts['体調不良'] ?? 0) + 1;
        }
      }
      logs[entry.key] = List<String>.from(entry.value);
    }
    setState(() {
      selectedLogs = logs;
    });
    return counts;
  }

  // カテゴリに応じたアイコンを返す
  IconData _getCategoryIcon(String log) {
    if (log.contains('泣いた！')) return FontAwesomeIcons.faceSadTear;
    if (log.contains('ミルク')) return FontAwesomeIcons.prescriptionBottle;
    if (log.contains('おむつ')) return FontAwesomeIcons.toilet;
    if (log.contains('眠い')) return FontAwesomeIcons.moon;
    if (log.contains('抱っこ')) return FontAwesomeIcons.child;
    if (log.contains('不快')) return FontAwesomeIcons.angry;
    if (log.contains('体調不良')) return FontAwesomeIcons.headSideCough;
    return Icons.help_outline;
  }

  // カテゴリに応じた色を返す
  Color _getCategoryColor(String log) {
    if (log.contains('泣いた！')) return Colors.blueAccent;
    if (log.contains('ミルク')) return Colors.lightBlue;
    if (log.contains('おむつ')) return Colors.lightGreen;
    if (log.contains('眠い')) return Colors.amber;
    if (log.contains('抱っこ')) return Colors.grey;
    if (log.contains('不快')) return Colors.orange;
    if (log.contains('体調不良')) return Colors.red;
    return Colors.black45;
  }

  /// 時間帯別統計を取得する
  Future<Map<String, int>> getHourlyStats() async {
    final result = {
      '0-4H': 0,
      '4-8H': 0,
      '8-12H': 0,
      '12-16H': 0,
      '16-20H': 0,
      '20-24H': 0
    };

    for (final entry in selectedLogs.entries) {
      for (final log in entry.value) {
        final hour = int.parse(log.substring(0, 2));
        String timeRange = '';
        if (hour >= 0 && hour < 4) {
          timeRange = '0-4H';
        } else if (hour < 8) {
          timeRange = '4-8H';
        } else if (hour < 12) {
          timeRange = '8-12H';
        } else if (hour < 16) {
          timeRange = '12-16H';
        } else if (hour < 20) {
          timeRange = '16-20H';
        } else {
          timeRange = '20-24H';
        }
        result[timeRange] = result[timeRange]! + 1;
      }
    }
    return result;
  }

  /// カテゴリごとの件数を取得する
  Widget _buildUnitRadio(DisplayUnit unit, String label) {
    return Row(
      children: [
        Radio<DisplayUnit>(
          value: unit,
          groupValue: _selectedUnit,
          onChanged: (value) {
            setState(() {
              _selectedUnit = value!;
              _updateCategoryCounts();
            });
          },
        ),
        Text(label,
            style: TextStyle(color: isDark ? Colors.white : Colors.black)),
      ],
    );
  }

  /// カテゴリごとの件数を取得する
  Widget _buildDateSelector() {
    switch (_selectedUnit) {
      case DisplayUnit.month:
        return _buildMonthSelector();
      case DisplayUnit.week:
        return _buildWeekSelector();
      case DisplayUnit.day:
        return _buildDaySelector();
      case DisplayUnit.all:
        return Container();
    }
  }

  /// カテゴリごとの件数を取得する
  Widget _buildMonthSelector() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      DropdownButton<int>(
        value: selectedYear,
        items: List.generate(5, (index) {
          final year = DateTime.now().year - 2 + index;
          return DropdownMenuItem(
              value: year,
              child: Text(AppLocalizations.of(context)!.year_label(year),
                  style:
                      TextStyle(color: isDark ? Colors.white : Colors.black)));
        }),
        onChanged: (value) {
          setState(() {
            selectedYear = value!;
            _updateCategoryCounts();
          });
        },
      ),
      SizedBox(width: 10),
      DropdownButton<int>(
        value: selectedMonth,
        items: List.generate(
            12,
            (index) => DropdownMenuItem(
                  value: index + 1,
                  child: Text(
                      AppLocalizations.of(context)!.month_label(index + 1),
                      style: TextStyle(
                          color: isDark ? Colors.white : Colors.black)),
                )),
        onChanged: (value) {
          setState(() {
            selectedMonth = value!;
            _updateCategoryCounts();
          });
        },
      ),
    ]);
  }

  /// カテゴリごとの件数を取得する
  Widget _buildWeekSelector() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      DropdownButton<int>(
        value: selectedYear,
        items: List.generate(5, (index) {
          final year = DateTime.now().year - 2 + index;
          return DropdownMenuItem(
              value: year,
              child: Text(AppLocalizations.of(context)!.year_label(year),
                  style:
                      TextStyle(color: isDark ? Colors.white : Colors.black)));
        }),
        onChanged: (value) {
          setState(() {
            selectedYear = value!;
            _updateCategoryCounts();
          });
        },
      ),
      SizedBox(width: 10),
      DropdownButton<int>(
        value: selectedMonth,
        items: List.generate(
            12,
            (index) => DropdownMenuItem(
                  value: index + 1,
                  child: Text(
                      AppLocalizations.of(context)!.month_label(index + 1),
                      style: TextStyle(
                          color: isDark ? Colors.white : Colors.black)),
                )),
        onChanged: (value) {
          setState(() {
            selectedMonth = value!;
            _updateCategoryCounts();
          });
        },
      ),
      SizedBox(width: 10),
      DropdownButton<int>(
        value: selectedWeek,
        items: List.generate(6, (i) => i + 1).map((week) {
          return DropdownMenuItem(
            value: week,
            child: Text(AppLocalizations.of(context)!.week_label(week),
                style: TextStyle(color: isDark ? Colors.white : Colors.black)),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedWeek = value!;
            _updateCategoryCounts();
          });
        },
      )
    ]);
  }

  /// カテゴリごとの件数を取得する
  Widget _buildDaySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DropdownButton<int>(
          value: selectedYear,
          items: List.generate(5, (index) {
            final year = DateTime.now().year - 2 + index;
            return DropdownMenuItem(
                value: year,
                child: Text(AppLocalizations.of(context)!.year_label(year),
                    style: TextStyle(
                        color: isDark ? Colors.white : Colors.black)));
          }),
          onChanged: (value) {
            setState(() {
              selectedYear = value!;
              _updateCategoryCounts();
            });
          },
        ),
        SizedBox(width: 10),
        DropdownButton<int>(
          value: selectedMonth,
          items: List.generate(
              12,
              (index) => DropdownMenuItem(
                    value: index + 1,
                    child: Text(
                        AppLocalizations.of(context)!.month_label(index + 1),
                        style: TextStyle(
                            color: isDark ? Colors.white : Colors.black)),
                  )),
          onChanged: (value) {
            setState(() {
              selectedMonth = value!;
              _updateCategoryCounts();
            });
          },
        ),
        SizedBox(width: 10),
        DropdownButton<int>(
          value: selectedDay,
          items: List.generate(
              DateUtils.getDaysInMonth(selectedYear, selectedMonth),
              (index) => DropdownMenuItem(
                    value: index + 1,
                    child: Text(
                        AppLocalizations.of(context)!.day_label(index + 1),
                        style: TextStyle(
                            color: isDark ? Colors.white : Colors.black)),
                  )),
          onChanged: (value) {
            setState(() {
              selectedDay = value!;
              _updateCategoryCounts();
            });
          },
        ),
      ],
    );
  }

  /// OpenAI APIを使用して育児アドバイスを取得する
  /// [categoryCounts] : カテゴリごとの件数
  Future<String> fetchParentingAdviceFromOpenAI(
      Map<String, int> categoryCounts) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    final uri = Uri.parse('https://api.openai.com/v1/chat/completions');

    final prompt = '''

${AppLocalizations.of(context)!.promptAdviceFromData}
${AppLocalizations.of(context)!.data}: ${categoryCounts.entries.map((e) => '${e.key}: ${e.value}${AppLocalizations.of(context)!.times}').join(', ')}。
''';

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: json.encode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            'role': 'system',
            'content': AppLocalizations.of(context)!.roleNurseryTeacher
          },
          {'role': 'user', 'content': prompt}
        ],
        'max_tokens': 200,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return data['choices'][0]['message']['content'].trim();
    } else {
      return '${AppLocalizations.of(context)!.advice_fetch_error} ${response.statusCode}';
    }
  }

  /// OpenAI APIを使用して育児の励ましメッセージを取得する
  Future<String> fetchEncouragementFromAI() async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    final uri = Uri.parse('https://api.openai.com/v1/chat/completions');

    final prompt = '''
${AppLocalizations.of(context)!.promptEncouragement}
''';

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: json.encode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            'role': 'system',
            'content': AppLocalizations.of(context)!.roleEncouragingAI
          },
          {'role': 'user', 'content': prompt}
        ],
        'max_tokens': 100,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return data['choices'][0]['message']['content'].trim();
    } else {
      return '${AppLocalizations.of(context)!.encouragement_fetch_error}: ${response.statusCode}';
    }
  }

  /// OpenAI APIを使用して相談内容を取得する
  Future<void> _showConsultationDialog() async {
    String userInput = '';
    Monthly monthly = Monthly();
    final canUse = await monthly.canUseFeature();
    if (canUse) {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.ai_consultation_title,
                style: TextStyle(color: isDark ? Colors.white : Colors.black)),
            content: TextField(
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              onChanged: (value) {
                userInput = value;
              },
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.consultation_input_hint,
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            actions: [
              TextButton(
                child: Text(AppLocalizations.of(context)!.cancel_button),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text(AppLocalizations.of(context)!.send_button),
                onPressed: () async {
                  Navigator.pop(context); // ダイアログを閉じる
                  if (userInput.isNotEmpty) {
                    await _fetchAIResponse(userInput);
                  }
                },
              ),
            ],
          );
        },
      );
    } else {
      // 課金を促すダイアログを表示
      _showSubscribedDialog();
    }
  }

  /// OpenAI APIを使用して質問に対する回答を取得する
  Future<void> _fetchAIResponse(String question) async {
    try {
      // ローディングインジケーターを表示
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(),
        ),
      );

      // AIからの回答を取得
      final response = await fetchAIResponse(question);

      // ローディングインジケーターを閉じる
      Navigator.pop(context);

      // 回答を表示
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.ai_response_title,
              style: TextStyle(color: isDark ? Colors.white : Colors.black)),
          content: SingleChildScrollView(
            child: Text(response,
                style: TextStyle(
                    color:
                        isDark ? Colors.white : Colors.black)), // 結果をスクロール可能にする
          ),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context)!.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    } catch (e) {
      // ローディングインジケーターを閉じる
      Navigator.pop(context);

      // エラーダイアログを表示
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.error,
              style: TextStyle(color: isDark ? Colors.white : Colors.black)),
          content: Text(
              "${AppLocalizations.of(context)!.ai_response_failed}\n\n$e",
              style: TextStyle(color: isDark ? Colors.white : Colors.black)),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context)!.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  /// OpenAI APIを使用して質問に対する回答を取得する
  Future<String> fetchAIResponse(String question) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    final uri = Uri.parse('https://api.openai.com/v1/chat/completions');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: json.encode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            'role': 'system',
            'content': AppLocalizations.of(context)!.roleHelpfulAssistant
          },
          {
            'role': 'user',
            'content':
                '$question ${AppLocalizations.of(context)!.limitCharacters150}'
          },
        ],
        'max_tokens': 200,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return data['choices'][0]['message']['content'].trim();
    } else {
      return '${AppLocalizations.of(context)!.ai_response_failed}: ${response.statusCode}';
    }
  }

  // カテゴリ名をローカライズするメソッド
  String? _getCategory(String category) {
    switch (category) {
      case '泣いた！':
        return AppLocalizations.of(context)!.cry;
      case 'ミルク':
        return AppLocalizations.of(context)!.milk;
      case 'おむつ':
        return AppLocalizations.of(context)!.diaper;
      case '眠い':
        return AppLocalizations.of(context)!.sleepy;
      case '抱っこ':
        return AppLocalizations.of(context)!.hold;
      case '不快':
        return AppLocalizations.of(context)!.uncomfortable;
      case '体調不良':
        return AppLocalizations.of(context)!.sick;
      default:
        return null;
    }
  }

  // ユーザーに報酬を与えるメソッド
  void giveRewardToUser() async {
    // ユーザーに何か特典を与える（例：アプリ内ポイント、機能解放など）
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('usage_count', 0);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.reward,
            style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        content: Text(AppLocalizations.of(context)!.aiUsesAdded,
            style: TextStyle(color: isDark ? Colors.white : Colors.black)),
      ),
    );
  }

  /// 課金を促すダイアログを表示する
  Future<void> _showSubscribedDialog() async {
    // ダイアログで課金を促す
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("",
            style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        content: Text(AppLocalizations.of(context)!.watchAdToUseAI,
            style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        actions: [
          TextButton(
            child: Text(AppLocalizations.of(context)!.cancel_button),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text(AppLocalizations.of(context)!.watchAd),
            onPressed: () {
              Navigator.pop(context);
              adManager.showAd(context, giveRewardToUser); // リワード処理を開始
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (!kIsWeb && _bannerAd != null)
            Container(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(AppLocalizations.of(context)!.stats_help_title,
                      style: TextStyle(
                          color: isDark ? Colors.white : Colors.black)),
                  content: Text(
                      AppLocalizations.of(context)!.stats_help_content,
                      style: TextStyle(
                          color: isDark ? Colors.white : Colors.black)),
                  actions: [
                    TextButton(
                      child: Text(AppLocalizations.of(context)!.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildUnitRadio(
                    DisplayUnit.day, AppLocalizations.of(context)!.day),
                _buildUnitRadio(
                    DisplayUnit.week, AppLocalizations.of(context)!.week),
                _buildUnitRadio(
                    DisplayUnit.month, AppLocalizations.of(context)!.month),
                _buildUnitRadio(
                    DisplayUnit.all, AppLocalizations.of(context)!.overall),
              ],
            ),
            SizedBox(height: 10),
            _buildDateSelector(),
            SizedBox(height: 20),
            Expanded(
              child: categoryCounts.isEmpty
                  ? Center(
                      child: Text(AppLocalizations.of(context)!.noRecords,
                          style: TextStyle(
                              color: isDark ? Colors.white : Colors.black)))
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 200,
                            child: PieChart(
                              PieChartData(
                                sections: categoryCounts.entries.map((entry) {
                                  return PieChartSectionData(
                                    title:
                                        '${_getCategory(entry.key)}\n${entry.value}',
                                    value: entry.value.toDouble(),
                                    color: _getCategoryColor(entry.key),
                                    radius: 60,
                                    titleStyle: TextStyle(
                                        fontSize: 14, color: Colors.white),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          ...categoryCounts.entries.map((e) => ListTile(
                                leading: Icon(_getCategoryIcon(e.key),
                                    color: _getCategoryColor(e.key)),
                                title: Text(_getCategory(e.key) ?? e.key),
                                trailing: Text(
                                    '${e.value} ${AppLocalizations.of(context)!.itemCount}'),
                              )),
                          SizedBox(height: 20),
                          Text(AppLocalizations.of(context)!.cryingTrendByTime,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black)),
                          FutureBuilder<Map<String, int>>(
                            future: getHourlyStats(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) return SizedBox.shrink();
                              final data = snapshot.data!;
                              final timeRanges = [
                                '0-4H',
                                '4-8H',
                                '8-12H',
                                '12-16H',
                                '16-20H',
                                '20-24H'
                              ];

                              return SizedBox(
                                height: 300,
                                width: double.infinity,
                                child: BarChart(
                                  BarChartData(
                                    barGroups:
                                        timeRanges.asMap().entries.map((entry) {
                                      final timeIndex = entry.key;
                                      final timeLabel = entry.value;
                                      final count = data[timeLabel] ?? 0;

                                      return BarChartGroupData(
                                        x: timeIndex,
                                        barRods: [
                                          BarChartRodData(
                                            toY: count.toDouble(),
                                            width: 20,
                                            color: Colors.blueAccent,
                                            borderRadius:
                                                BorderRadius.circular(0),
                                          ),
                                        ],
                                        barsSpace: 4,
                                      );
                                    }).toList(),
                                    titlesData: FlTitlesData(
                                      leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          return Text(
                                            value.toInt().toString(),
                                            style: TextStyle(fontSize: 10),
                                          );
                                        },
                                      )),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (value, _) {
                                            if (value.toInt() >= 0 &&
                                                value.toInt() <
                                                    timeRanges.length) {
                                              return Text(
                                                  timeRanges[value.toInt()],
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      color: isDark
                                                          ? Colors.white
                                                          : Colors.black));
                                            }
                                            return Text('');
                                          },
                                        ),
                                      ),
                                      topTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                            showTitles: false), // 上軸の数字非表示
                                      ),
                                      rightTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                            showTitles: false), // 右軸の数字非表示
                                      ),
                                    ),
                                    gridData: FlGridData(show: true),
                                    borderData: FlBorderData(show: false),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
            ),
            Text(
              AppLocalizations.of(context)!.aiFeature,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isDark ? Colors.white : Colors.black), // タイトルのスタイル
            ),
            const SizedBox(height: 10),
            Wrap(spacing: 5, children: [
              ElevatedButton.icon(
                icon: Icon(Icons.lightbulb),
                label: Text(
                  AppLocalizations.of(context)!.adviceButton,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
                onPressed: () async {
                  try {
                    Monthly monthly = Monthly();
                    final canUse = await monthly.canUseFeature();
                    if (canUse) {
                      // ローディングインジケーターを表示
                      showDialog(
                        context: context,
                        barrierDismissible: false, // ダイアログ外をタップしても閉じない
                        builder: (context) => Center(
                          child: CircularProgressIndicator(),
                        ),
                      );

                      final advice =
                          await fetchParentingAdviceFromOpenAI(categoryCounts);

                      // ローディングインジケーターを閉じる
                      Navigator.pop(context);

                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(
                              AppLocalizations.of(context)!.ai_advice_title,
                              style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black)),
                          content: Text(advice,
                              style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black)),
                          actions: [
                            TextButton(
                              child: Text(AppLocalizations.of(context)!.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      );
                    } else {
                      _showSubscribedDialog();
                    }
                  } catch (e) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(AppLocalizations.of(context)!.error_title,
                            style: TextStyle(
                                color: isDark ? Colors.white : Colors.black)),
                        content: Text(
                            AppLocalizations.of(context)!.advice_fetch_failed +
                                '\n\n$e',
                            style: TextStyle(
                                color: isDark ? Colors.white : Colors.black)),
                        actions: [
                          TextButton(
                            child: Text(AppLocalizations.of(context)!.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
              ElevatedButton.icon(
                icon: Icon(Icons.sentiment_satisfied_alt),
                label: Text(AppLocalizations.of(context)!.encouragement,
                    softWrap: true, overflow: TextOverflow.visible),
                onPressed: () async {
                  try {
                    Monthly monthly = Monthly();
                    final canUse = await monthly.canUseFeature();
                    if (canUse) {
                      // ローディングインジケーターを表示
                      showDialog(
                        context: context,
                        barrierDismissible: false, // ダイアログ外をタップしても閉じない
                        builder: (context) => Center(
                          child: CircularProgressIndicator(),
                        ),
                      );

                      final encouragement = await fetchEncouragementFromAI();

                      // ローディングインジケーターを閉じる
                      Navigator.pop(context);

                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(
                              AppLocalizations.of(context)!.encouragementFromAI,
                              style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black)),
                          content: Text(encouragement,
                              style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black)),
                          actions: [
                            TextButton(
                              child: Text(AppLocalizations.of(context)!.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      );
                    } else {
                      _showSubscribedDialog();
                    }
                  } catch (e) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(AppLocalizations.of(context)!.error,
                            style: TextStyle(
                                color: isDark ? Colors.white : Colors.black)),
                        content: Text(
                            "${AppLocalizations.of(context)!.encouragement_fetch_error}\n\n$e",
                            style: TextStyle(
                                color: isDark ? Colors.white : Colors.black)),
                        actions: [
                          TextButton(
                            child: Text(AppLocalizations.of(context)!.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
              ElevatedButton.icon(
                icon: Icon(Icons.chat),
                label: Text(AppLocalizations.of(context)!.consultation,
                    softWrap: true, overflow: TextOverflow.visible),
                onPressed: () async {
                  await _showConsultationDialog();
                },
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
