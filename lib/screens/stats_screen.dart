import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class StatsScreen extends StatefulWidget {
  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  Map<String, int> categoryCounts = {};

  @override
  void initState() {
    super.initState();
    _updateData();
  }

  Future<void> _updateData() async {
    final counts =
        await getMonthlyCategoryCounts(DateTime(selectedYear, selectedMonth));
    setState(() {
      categoryCounts = counts;
    });
  }

  Future<Map<String, List<String>>> _loadAllLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final rawData = prefs.getString('cry_logs') ?? '{}';
    final Map<String, dynamic> jsonData = json.decode(rawData);
    return jsonData
        .map((key, value) => MapEntry(key, List<String>.from(value)));
  }

  Future<Map<String, int>> getMonthlyCategoryCounts(DateTime month) async {
    final allLogs = await _loadAllLogs();
    final counts = <String, int>{};

    final targetMonth =
        '${month.year}-${month.month.toString().padLeft(2, '0')}';

    for (final entry in allLogs.entries) {
      if (entry.key.startsWith(targetMonth)) {
        for (final log in entry.value) {
          if (log.contains('ミルク')) {
            counts['ミルク'] = (counts['ミルク'] ?? 0) + 1;
          } else if (log.contains('おむつ')) {
            counts['おむつ'] = (counts['おむつ'] ?? 0) + 1;
          } else if (log.contains('夜泣き')) {
            counts['夜泣き'] = (counts['夜泣き'] ?? 0) + 1;
          } else if (log.contains('その他')) {
            counts['その他'] = (counts['その他'] ?? 0) + 1;
          }
        }
      }
    }

    return counts;
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'ミルク':
        return Colors.tealAccent;
      case 'おむつ':
        return Colors.brown;
      case '夜泣き':
        return Colors.amber;
      case 'その他':
        return Colors.grey;
      default:
        return Colors.black45;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'ミルク':
        return FontAwesomeIcons.prescriptionBottle;
      case 'おむつ':
        return FontAwesomeIcons.poo;
      case '夜泣き':
        return FontAwesomeIcons.moon;
      case 'その他':
        return FontAwesomeIcons.paw;
      default:
        return Icons.help_outline;
    }
  }

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
      throw Exception('アドバイスの取得に失敗しました: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text('統計'),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('統計画面の使い方'),
                  content: Text('この画面では、過去の育児記録をカテゴリ別に月ごとで集計し、グラフで表示します。\n\n'
                      '📌 表示カテゴリ:\n'
                      '🍼 ミルク, 💩 おむつ, 🌙 夜泣き, 🐾 その他\n\n'
                      '📆 上部で年月を切り替えることができます。\n\n'
                      '💡「AIのアドバイスを見る」ボタンで、AIからの育児ヒントも得られます。'),
                  actions: [
                    TextButton(
                      child: Text('閉じる'),
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
              children: [
                DropdownButton<int>(
                  value: selectedYear,
                  items: List.generate(5, (index) {
                    final year = DateTime.now().year - 2 + index;
                    return DropdownMenuItem(value: year, child: Text('$year年'));
                  }),
                  onChanged: (value) {
                    setState(() {
                      selectedYear = value!;
                      _updateData();
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
                            child: Text('${index + 1}月'),
                          )),
                  onChanged: (value) {
                    setState(() {
                      selectedMonth = value!;
                      _updateData();
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: categoryCounts.isEmpty
                  ? Center(child: Text('記録がありません'))
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
                        ],
                      ),
                    ),
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.lightbulb),
              label: Text('AIのアドバイスを見る'),
              onPressed: () async {
                try {
                  final advice =
                      await fetchParentingAdviceFromOpenAI(categoryCounts);
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('AIアドバイス'),
                      content: Text(advice),
                      actions: [
                        TextButton(
                          child: Text('閉じる'),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  );
                } catch (e) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('エラー'),
                      content:
                          Text('アドバイスの取得に失敗しました。ネットワークやAPIキーをご確認ください。\n\n$e'),
                      actions: [
                        TextButton(
                          child: Text('閉じる'),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  );
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
