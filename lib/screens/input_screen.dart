import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // 時刻整形に使用
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class InputScreen extends StatefulWidget {
  @override
  _InputScreenState createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  List<String> _logs = [];

  final List<Map<String, dynamic>> _categories = [
    {
      'label': 'ミルク',
      'icon': FontAwesomeIcons.prescriptionBottle,
      'color': Colors.tealAccent
    },
    {'label': 'おむつ', 'icon': FontAwesomeIcons.poo, 'color': Colors.brown},
    {'label': '夜泣き', 'icon': FontAwesomeIcons.moon, 'color': Colors.amber},
    {'label': 'その他', 'icon': FontAwesomeIcons.paw, 'color': Colors.grey},
  ];

  @override
  void initState() {
    super.initState();
    _loadTodayLogs();
  }

  String _getTodayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _loadTodayLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('cry_logs') ?? '{}';
    final data = json.decode(raw) as Map<String, dynamic>;
    final todayKey = _getTodayKey();
    final todayLogs = List<String>.from(data[todayKey] ?? []);
    setState(() {
      _logs = todayLogs;
    });
  }

  Future<void> _addLog(String category) async {
    final now = DateTime.now();
    final timeStr = DateFormat('HH:mm:ss').format(now);
    final entry = '$timeStr $category';

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('cry_logs') ?? '{}';
    final data = Map<String, dynamic>.from(json.decode(raw));
    final todayKey = _getTodayKey();
    final todayLogs = List<String>.from(data[todayKey] ?? []);
    todayLogs.add(entry);
    data[todayKey] = todayLogs;
    await prefs.setString('cry_logs', json.encode(data));
    setState(() {
      _logs = todayLogs;
    });
  }

  Future<void> _clearTodayLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('cry_logs') ?? '{}';
    final data = Map<String, dynamic>.from(json.decode(raw));
    final todayKey = _getTodayKey();
    data.remove(todayKey);
    await prefs.setString('cry_logs', json.encode(data));
    setState(() {
      _logs = [];
    });
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('入力画面ヘルプ'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text('・「ミルク」「おむつ」などのボタンを押すと、その時刻で記録されます。'),
                Text('・記録は1日単位で自動的に保存されます。'),
                Text('・リストをスワイプで削除、タップでカテゴリ編集ができます。'),
                Text('・画面右上のゴミ箱アイコンで当日の全記録を削除できます。'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('閉じる'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  IconData _getCategoryIcon(String log) {
    if (log.contains('ミルク')) return FontAwesomeIcons.prescriptionBottle;
    if (log.contains('おむつ')) return FontAwesomeIcons.poo;
    if (log.contains('夜泣き')) return FontAwesomeIcons.moon;
    if (log.contains('その他')) return FontAwesomeIcons.paw;
    return Icons.help_outline;
  }

  Color _getCategoryColor(String log) {
    if (log.contains('ミルク')) return Colors.tealAccent;
    if (log.contains('おむつ')) return Colors.brown;
    if (log.contains('夜泣き')) return Colors.amber;
    if (log.contains('その他')) return Colors.grey;
    return Colors.black45;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50], // 背景画像を見せるために透明
      appBar: AppBar(
        title: Text('ボタンを押してね！'),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline),
            tooltip: 'ヘルプ',
            onPressed: _showHelpDialog,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _logs.isNotEmpty ? _clearTodayLogs : null,
            tooltip: '今日の記録を削除',
          ),
        ],
      ),
      body: Column(
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10, // これで縦方向に段を分ける
            children: _categories.map((cat) {
              return SizedBox(
                width: MediaQuery.of(context).size.width / 2 - 20, // 幅を調整して2列に
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cat['color'],
                  ),
                  icon: Icon(cat['icon'], color: Colors.white),
                  label:
                      Text(cat['label'], style: TextStyle(color: Colors.white)),
                  onPressed: () => _addLog(cat['label']),
                ),
              );
            }).toList(),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                final log = _logs[index];
                return Dismissible(
                  key: Key(log + index.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) async {
                    final prefs = await SharedPreferences.getInstance();
                    final raw = prefs.getString('cry_logs') ?? '{}';
                    final data = Map<String, dynamic>.from(json.decode(raw));
                    final todayKey = _getTodayKey();
                    final todayLogs = List<String>.from(data[todayKey] ?? []);
                    todayLogs.removeAt(index);
                    data[todayKey] = todayLogs;
                    await prefs.setString('cry_logs', json.encode(data));
                    setState(() {
                      _logs = todayLogs;
                    });
                  },
                  child: ListTile(
                    leading: Icon(
                      _getCategoryIcon(log),
                      color: _getCategoryColor(log),
                    ),
                    title: Text(log),
                    onTap: () async {
                      final timePart = log.split(' ').first;
                      final categoryPart = _categories.firstWhere(
                        (cat) => log.contains(cat['label']),
                        orElse: () => _categories.last,
                      )['label'];

                      String? tempSelectedCategory = categoryPart;

                      final newCategory = await showDialog<String>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('カテゴリを編集'),
                            content: StatefulBuilder(
                              builder: (context, setState) {
                                return DropdownButtonFormField<String>(
                                  value: tempSelectedCategory,
                                  items: _categories.map((cat) {
                                    return DropdownMenuItem<String>(
                                      value: cat['label'],
                                      child: Text(cat['label']),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      tempSelectedCategory = value;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'カテゴリ',
                                    border: OutlineInputBorder(),
                                  ),
                                );
                              },
                            ),
                            actions: [
                              TextButton(
                                child: Text('キャンセル'),
                                onPressed: () => Navigator.pop(context),
                              ),
                              TextButton(
                                child: Text('保存'),
                                onPressed: () {
                                  if (tempSelectedCategory != null) {
                                    Navigator.pop(context,
                                        '$timePart $tempSelectedCategory');
                                  }
                                },
                              ),
                            ],
                          );
                        },
                      );

                      if (newCategory != null &&
                          newCategory.trim().isNotEmpty) {
                        final prefs = await SharedPreferences.getInstance();
                        final raw = prefs.getString('cry_logs') ?? '{}';
                        final data =
                            Map<String, dynamic>.from(json.decode(raw));
                        final todayKey = _getTodayKey();
                        final todayLogs =
                            List<String>.from(data[todayKey] ?? []);
                        todayLogs[index] = newCategory;
                        data[todayKey] = todayLogs;
                        await prefs.setString('cry_logs', json.encode(data));
                        setState(() {
                          _logs = todayLogs;
                        });
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
