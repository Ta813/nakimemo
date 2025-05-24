// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../setting/monthly.dart';

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

  @override
  void initState() {
    super.initState();
    _updateCategoryCounts();

    if (!kIsWeb) {
      // バナー広告の初期化
      _bannerAd = BannerAd(
        adUnitId:
            'ca-app-pub-3940256099942544/6300978111', // ご自身のAdMobバナーIDに置き換えてください
        size: AdSize.banner,
        request: AdRequest(),
        listener: BannerAdListener(),
      )..load();
    }
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
    await SharedPreferences.getInstance(); // 1回目（キャッシュクリア用）
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final rawData = prefs.getString('cry_logs') ?? '{}';
    final Map<String, dynamic> jsonData = json.decode(rawData);
    return jsonData
        .map((key, value) => MapEntry(key, List<String>.from(value)));
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
              child: Text('$year年',
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
                  child: Text('${index + 1}月',
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
              child: Text('$year年',
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
                  child: Text('${index + 1}月',
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
            child: Text('第${week}週',
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
                child: Text('$year年',
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
                    child: Text('${index + 1}月',
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
                    child: Text('${index + 1}日',
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
以下の育児統計データに基づいて、親に対する短く実用的なアドバイスを日本語で1つ提示してください。
データ: ${categoryCounts.entries.map((e) => '${e.key}: ${e.value}回').join(', ')}。
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
          {'role': 'system', 'content': 'あなたは親にやさしく的確なアドバイスをする保育士です。'},
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
      return 'アドバイスの取得に失敗しました: ${response.statusCode}';
    }
  }

  /// OpenAI APIを使用して育児の励ましメッセージを取得する
  Future<String> fetchEncouragementFromAI() async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    final uri = Uri.parse('https://api.openai.com/v1/chat/completions');

    final prompt = '''
育児で疲れている親を励ます短いメッセージを日本語で1つ提供してください。
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
          {'role': 'system', 'content': 'あなたは親を励ます優しいAIです。'},
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
      return '励ましメッセージの取得に失敗しました: ${response.statusCode}';
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
            title: Text("AIに相談する",
                style: TextStyle(color: isDark ? Colors.white : Colors.black)),
            content: TextField(
              onChanged: (value) {
                userInput = value;
              },
              decoration: InputDecoration(
                hintText: "相談内容を入力してください",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            actions: [
              TextButton(
                child: Text("キャンセル"),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text("送信"),
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
      _showSubscribedDialog(monthly);
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
          title: Text("AIの回答",
              style: TextStyle(color: isDark ? Colors.white : Colors.black)),
          content: SingleChildScrollView(
            child: Text(response,
                style: TextStyle(
                    color:
                        isDark ? Colors.white : Colors.black)), // 結果をスクロール可能にする
          ),
          actions: [
            TextButton(
              child: Text("閉じる"),
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
          title: Text("エラー",
              style: TextStyle(color: isDark ? Colors.white : Colors.black)),
          content: Text("AIの回答を取得できませんでした。\n\n$e",
              style: TextStyle(color: isDark ? Colors.white : Colors.black)),
          actions: [
            TextButton(
              child: Text("閉じる"),
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
          {'role': 'system', 'content': 'あなたは親切で知識豊富なアシスタントです。'},
          {'role': 'user', 'content': '$question 150文字以内で答えてください。'},
        ],
        'max_tokens': 200,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return data['choices'][0]['message']['content'].trim();
    } else {
      return 'AIの回答取得に失敗しました: ${response.statusCode}';
    }
  }

  Future<void> _showSubscribedDialog(Monthly monthly) async {
    // ダイアログで課金を促す
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("プレミアムにアップグレード",
            style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        content: Text("5回の無料利用が終了しました。月額プランをご検討ください。",
            style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        actions: [
          TextButton(
            child: Text("キャンセル"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text("購入"),
            onPressed: () {
              Navigator.pop(context);
              monthly.initIAP(); // 課金処理を開始
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
                _buildUnitRadio(DisplayUnit.day, '日'),
                _buildUnitRadio(DisplayUnit.week, '週'),
                _buildUnitRadio(DisplayUnit.month, '月'),
                _buildUnitRadio(DisplayUnit.all, '全体'),
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
                                    title: '${entry.key}\n${entry.value}',
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
                                title: Text(e.key),
                                trailing: Text('${e.value} 件'),
                              )),
                          SizedBox(height: 20),
                          Text('時間帯ごとの泣く傾向',
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
              "AI機能",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isDark ? Colors.white : Colors.black), // タイトルのスタイル
            ),
            const SizedBox(height: 10),
            Row(spacing: 5, children: [
              ElevatedButton.icon(
                icon: Icon(Icons.lightbulb),
                label: Text(AppLocalizations.of(context)!.adviceButton),
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
                              AppLocalizations.of(context)!.ai_advice_title),
                          content: Text(advice),
                          actions: [
                            TextButton(
                              child: Text(AppLocalizations.of(context)!.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      );
                    } else {
                      _showSubscribedDialog(monthly);
                    }
                  } catch (e) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(AppLocalizations.of(context)!.error_title),
                        content: Text(
                            AppLocalizations.of(context)!.advice_fetch_failed +
                                '\n\n$e'),
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
                label: Text("励まし"),
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
                          title: Text("AIからの励まし",
                              style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black)),
                          content: Text(encouragement,
                              style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black)),
                          actions: [
                            TextButton(
                              child: Text("閉じる"),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      );
                    } else {
                      _showSubscribedDialog(monthly);
                    }
                  } catch (e) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("エラー",
                            style: TextStyle(
                                color: isDark ? Colors.white : Colors.black)),
                        content: Text("励ましメッセージの取得に失敗しました。\n\n$e",
                            style: TextStyle(
                                color: isDark ? Colors.white : Colors.black)),
                        actions: [
                          TextButton(
                            child: Text("閉じる"),
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
                label: Text("相談"),
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
