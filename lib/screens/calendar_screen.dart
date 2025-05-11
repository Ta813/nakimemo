// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nakimemo/setting/layout_provider.dart';
import 'package:nakimemo/setting/layout_type.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // カテゴリのリスト
  final List<Map<String, dynamic>> _categories = [
    {
      'label': 'ミルク',
      'icon': FontAwesomeIcons.prescriptionBottle,
      'color': Colors.lightBlue
    },
    {'label': 'おむつ', 'icon': FontAwesomeIcons.poo, 'color': Colors.brown},
    {'label': '眠い', 'icon': FontAwesomeIcons.moon, 'color': Colors.amber},
    {'label': '抱っこ', 'icon': FontAwesomeIcons.child, 'color': Colors.grey},
    {'label': '騒音', 'icon': FontAwesomeIcons.volumeUp, 'color': Colors.orange},
    {
      'label': '気温',
      'icon': FontAwesomeIcons.thermometerHalf,
      'color': Colors.green
    },
    {
      'label': '体調不良',
      'icon': FontAwesomeIcons.headSideCough,
      'color': Colors.red
    },
  ];

  Map<String, List<String>> _eventMap = {}; // 保存形式
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
    _loadEvents();
  }

  // SharedPreferencesからイベントを読み込む
  Future<void> _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final rawData = prefs.getString('cry_logs') ?? '{}';
    setState(() {
      _eventMap = Map<String, List<String>>.from(
        (json.decode(rawData) as Map).map(
          (key, value) => MapEntry(key, List<String>.from(value)),
        ),
      );
    });
  }

  // 選択された日のイベントを取得
  List<String> _getEventsForDay(DateTime day) {
    final key = _formatDate(day);
    final events = _eventMap[key] ?? [];

    // 時間の昇順でソート
    events.sort((a, b) {
      final timeA = a.split(' ').first; // "HH:mm" 部分を取得
      final timeB = b.split(' ').first;
      return timeA.compareTo(timeB); // 時間を文字列として比較
    });

    return events;
  }

  // 日付を "YYYY-MM-DD" 形式にフォーマット
  String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  // カテゴリに応じたアイコンを返す
  IconData _getCategoryIcon(String log) {
    if (log.contains('ミルク')) return FontAwesomeIcons.prescriptionBottle;
    if (log.contains('おむつ')) return FontAwesomeIcons.poo;
    if (log.contains('眠い')) return FontAwesomeIcons.moon;
    if (log.contains('抱っこ')) return FontAwesomeIcons.child;
    if (log.contains('騒音')) return FontAwesomeIcons.volumeUp;
    if (log.contains('気温')) return FontAwesomeIcons.thermometerHalf;
    if (log.contains('体調不良')) return FontAwesomeIcons.headSideCough;
    return Icons.help_outline;
  }

  // カテゴリに応じた色を返す
  Color _getCategoryColor(String log) {
    if (log.contains('ミルク')) return Colors.lightBlue;
    if (log.contains('おむつ')) return Colors.brown;
    if (log.contains('眠い')) return Colors.amber;
    if (log.contains('抱っこ')) return Colors.grey;
    if (log.contains('騒音')) return Colors.orange;
    if (log.contains('気温')) return Colors.green;
    if (log.contains('体調不良')) return Colors.red;
    return Colors.black45;
  }

  // イベントを削除する
  Future<void> _removeEvent(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _formatDate(_selectedDay!);
    final events = List<String>.from(_eventMap[key]!);

    events.removeAt(index);

    if (events.isEmpty) {
      _eventMap.remove(key);
      await prefs.remove('cry_logs');
      await prefs.setString('cry_logs', json.encode(_eventMap));
    } else {
      _eventMap[key] = events;
      await prefs.setString('cry_logs', json.encode(_eventMap));
    }

    setState(() {});
  }

  // ヘルプダイアログを表示
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('カレンダー画面ヘルプ'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text('・カレンダーの日付をタップすると、その日の記録が表示されます。'),
                Text('・記録の横のアイコンはカテゴリを示しています。'),
                Text('・記録をタップするとカテゴリを編集できます。'),
                Text('・記録をスワイプすると削除できます。'),
                Text('・日付の下に丸いマーカーが表示されている日は、記録が存在する日です。'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context)!.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  // カテゴリに応じたアイコンを返す
  Widget _itemBuilder(int index) {
    final log = _getEventsForDay(_selectedDay!)[index];
    return Dismissible(
      key: Key(log),
      background: Container(color: Colors.red),
      onDismissed: (direction) async {
        await _removeEvent(index);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$log を削除しました')),
        );
      },
      child: ListTile(
        leading: Icon(
          _getCategoryIcon(log),
          color: _getCategoryColor(log),
        ),
        title: Text(log),
        trailing: IconButton(
          icon: Icon(Icons.note_add),
          tooltip: 'メモを追加',
          onPressed: () => _showMemoDialog(index), // メモ追加ダイアログを表示
        ),
        onTap: () async {
          final log = _getEventsForDay(_selectedDay!)[index];
          final timeStr = log.split(' ').first;
          final categoryPart = log.split(' ')[1];

          String? tempSelectedCategory = categoryPart;

          final newLog = await showDialog<String>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(AppLocalizations.of(context)!.edit_category_title),
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
                        labelText:
                            AppLocalizations.of(context)!.edit_category_label,
                        border: OutlineInputBorder(),
                      ),
                    );
                  },
                ),
                actions: [
                  TextButton(
                    child: Text(AppLocalizations.of(context)!.cancel_button),
                    onPressed: () => Navigator.pop(context),
                  ),
                  TextButton(
                    child: Text(AppLocalizations.of(context)!.save_button),
                    onPressed: () {
                      if (tempSelectedCategory != null) {
                        Navigator.pop(
                            context, '$timeStr $tempSelectedCategory');
                      }
                    },
                  ),
                ],
              );
            },
          );

          if (newLog != null && newLog.trim().isNotEmpty) {
            final prefs = await SharedPreferences.getInstance();
            final rawData = prefs.getString('cry_logs') ?? '{}';
            final data = Map<String, dynamic>.from(json.decode(rawData));
            final key = _formatDate(_selectedDay!);
            final dayLogs = List<String>.from(data[key] ?? []);
            dayLogs[index] = newLog;
            data[key] = dayLogs;
            await prefs.setString('cry_logs', json.encode(data));
            setState(() {
              _eventMap = data.map(
                (k, v) => MapEntry(k, List<String>.from(v)),
              );
            });
          }
        },
      ),
    );
  }

  // 記録を追加するダイアログを表示
  Future<void> _showAddLogDialog() async {
    String? selectedCategory;
    TimeOfDay? selectedTime = TimeOfDay.now();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('記録を追加'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'カテゴリを選択',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      'ミルク',
                      'おむつ',
                      '眠い',
                      '抱っこ',
                      '騒音',
                      '気温',
                      '体調不良',
                    ].map((label) {
                      return DropdownMenuItem<String>(
                        value: label,
                        child: Text(label),
                      );
                    }).toList(),
                    onChanged: (value) {
                      selectedCategory = value;
                    },
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: selectedTime!,
                      );
                      if (time != null) {
                        setState(() {
                          selectedTime = time; // 時間を更新
                        });
                      }
                    },
                    child:
                        Text('時間を選択: ${selectedTime?.format(context) ?? ''}'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text('キャンセル'),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  child: Text('追加'),
                  onPressed: () {
                    if (selectedCategory != null && selectedTime != null) {
                      final now = DateTime.now();
                      final selectedDate = _selectedDay ?? now;
                      final formattedTime =
                          '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}';
                      final log = '$formattedTime:00 $selectedCategory';

                      _addLogToSelectedDate(log, selectedDate);
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 選択された日にログを追加
  Future<void> _addLogToSelectedDate(String log, DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final rawData = prefs.getString('cry_logs') ?? '{}';
    final data = Map<String, dynamic>.from(json.decode(rawData));

    final key = _formatDate(date);
    final dayLogs = List<String>.from(data[key] ?? []);
    dayLogs.add(log);
    data[key] = dayLogs;

    await prefs.setString('cry_logs', json.encode(data));

    setState(() {
      _eventMap = data.map(
        (k, v) => MapEntry(k, List<String>.from(v)),
      );
    });
  }

  // メモを追加するダイアログを表示
  Future<void> _showMemoDialog(int index) async {
    String memo = '';

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('メモを追加'),
          content: TextField(
            onChanged: (value) {
              memo = value;
            },
            decoration: InputDecoration(
              hintText: 'メモを入力してください',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              child: Text('キャンセル'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text('保存'),
              onPressed: () async {
                if (memo.isNotEmpty) {
                  await _saveMemo(index, memo);
                  Navigator.pop(context); // ダイアログを閉じる
                }
              },
            ),
          ],
        );
      },
    );
  }

  // メモを保存する
  Future<void> _saveMemo(int index, String memo) async {
    final prefs = await SharedPreferences.getInstance();
    final rawData = prefs.getString('cry_logs') ?? '{}';
    final data = Map<String, dynamic>.from(json.decode(rawData));
    final key = _formatDate(_selectedDay!);
    final dayLogs = List<String>.from(data[key] ?? []);

    if (index >= 0 && index < dayLogs.length) {
      final log = dayLogs[index];
      final updatedLog = '$log [メモ: $memo]'; // メモをログに追加
      dayLogs[index] = updatedLog;

      data[key] = dayLogs;
      await prefs.setString('cry_logs', json.encode(data));

      setState(() {
        _eventMap = data.map(
          (k, v) => MapEntry(k, List<String>.from(v)),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final layoutProvider = Provider.of<LayoutProvider>(context);
    final isGrid = layoutProvider.layoutType == LayoutType.grid;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.calendar_title),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline),
            tooltip: AppLocalizations.of(context)!.help_tooltip,
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: _getEventsForDay,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: CalendarStyle(
              markerDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const Divider(
            thickness: 1, // 線の太さ
            color: Colors.grey, // 線の色
            height: 20, // 線の上下の余白
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end, // ボタンを右寄せ
            children: [
              IconButton(
                icon: Icon(
                  Icons.add,
                  size: 15,
                ),
                tooltip: '追加',
                onPressed: () async {
                  await _showAddLogDialog();
                },
              ),
            ],
          ),
          Expanded(
            child: isGrid
                ? GridView.builder(
                    itemCount: _getEventsForDay(_selectedDay!).length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // グリッドの列数
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 2.5, // アイテムのアスペクト比
                    ),
                    itemBuilder: (context, index) {
                      return _itemBuilder(index);
                    })
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        vertical: 0.0), // リスト全体の上下余白を削除
                    itemCount: _getEventsForDay(_selectedDay!).length,
                    itemBuilder: (context, index) {
                      return _itemBuilder(index);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
