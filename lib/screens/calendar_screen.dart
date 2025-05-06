import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
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

  List<String> _getEventsForDay(DateTime day) {
    final key = _formatDate(day);
    return _eventMap[key] ?? [];
  }

  String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

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
              child: Text('閉じる'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: Text('泣いた記録カレンダー'),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline),
            tooltip: 'ヘルプ',
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
          const SizedBox(height: 8.0),
          Expanded(
            child: ListView.builder(
              itemCount: _getEventsForDay(_selectedDay!).length,
              itemBuilder: (context, index) {
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
                    onTap: () async {
                      final log = _getEventsForDay(_selectedDay!)[index];
                      final timeStr = log.split(' ').first;
                      final categoryLabel = log.substring(timeStr.length + 1);

                      String? tempSelectedCategory = categoryLabel;

                      final newLog = await showDialog<String>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('カテゴリを編集'),
                            content: DropdownButtonFormField<String>(
                              value: tempSelectedCategory,
                              items: [
                                'ミルク',
                                'おむつ',
                                '夜泣き',
                                'その他',
                              ].map((label) {
                                return DropdownMenuItem<String>(
                                  value: label,
                                  child: Text(label),
                                );
                              }).toList(),
                              onChanged: (value) {
                                tempSelectedCategory = value;
                              },
                              decoration: InputDecoration(
                                labelText: 'カテゴリ',
                                border: OutlineInputBorder(),
                              ),
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
                                        '$timeStr $tempSelectedCategory');
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
                        final data =
                            Map<String, dynamic>.from(json.decode(rawData));
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
              },
            ),
          ),
        ],
      ),
    );
  }
}
