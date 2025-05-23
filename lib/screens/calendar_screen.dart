// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // カテゴリのリスト
  final List<Map<String, dynamic>> _categories = [
    {
      'label': '泣いた！',
      'icon': FontAwesomeIcons.faceSadTear,
      'color': Colors.blueAccent
    },
    {
      'label': 'ミルク',
      'icon': FontAwesomeIcons.prescriptionBottle,
      'color': Colors.lightBlue
    },
    {
      'label': 'おむつ',
      'icon': FontAwesomeIcons.toilet,
      'color': Color(0xFFF5F5DC)
    },
    {'label': '眠い', 'icon': FontAwesomeIcons.moon, 'color': Colors.amber},
    {'label': '抱っこ', 'icon': FontAwesomeIcons.child, 'color': Colors.grey},
    {'label': '不快', 'icon': FontAwesomeIcons.angry, 'color': Colors.orange},
    {
      'label': '体調不良',
      'icon': FontAwesomeIcons.headSideCough,
      'color': Colors.red
    },
  ];

  Map<String, List<String>> _eventMap = {}; // 保存形式
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  Set<int> _hoveredIndexes = {}; // カーソルが当たっている行のインデックスを追跡

  final ScrollController _scrollController =
      ScrollController(); // スクロールコントローラーを追加

  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
    _loadEvents();

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

  // SharedPreferencesからイベントを読み込む
  Future<void> _loadEvents() async {
    await SharedPreferences.getInstance(); // 1回目（キャッシュクリア用）
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
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

  // イベントを削除する
  Future<void> _removeEvent(int index) async {
    await SharedPreferences.getInstance(); // 1回目（キャッシュクリア用）
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final key = _formatDate(_selectedDay!);
    final events = List<String>.from(_eventMap[key]!);

    // リストから即座に削除
    setState(() {
      events.removeAt(index);
      _hoveredIndexes.remove(index); // ホバー状態を解除
    });

    if (events.isEmpty) {
      _eventMap.remove(key);
      await prefs.remove('cry_logs');
      await prefs.setString('cry_logs', json.encode(_eventMap));
    } else {
      _eventMap[key] = events;
      await prefs.setString('cry_logs', json.encode(_eventMap));
    }
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
    final isHovered = _hoveredIndexes.contains(index); // カーソルが当たっているかを判定
    final themeColor = Theme.of(context).colorScheme.primary; // 現在のテーマの色を取得

    return Dismissible(
      key: Key(log + index.toString()),
      background: Container(color: Colors.red),
      onDismissed: (direction) async {
        await _removeEvent(index);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$log を削除しました')),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        child: Card(
          color: isHovered ? themeColor.withOpacity(0.2) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            leading: Icon(
              _getCategoryIcon(log),
              color: _getCategoryColor(log),
            ),
            title: Text(
              log.replaceFirst(RegExp(r'\.\d{3}'), ''),
            ),
            trailing: IconButton(
              icon: Icon(Icons.note_add),
              tooltip: 'メモを追加',
              onPressed: () => _showMemoDialog(index), // メモ追加ダイアログを表示
            ),
            onTap: () async {
              String? selectedCategory = await showDialog<String>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title:
                        Text(AppLocalizations.of(context)!.edit_category_title),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _categories.map((cat) {
                        return ListTile(
                          leading: Icon(cat['icon'], color: cat['color']),
                          title: Text(cat['label']),
                          onTap: () {
                            Navigator.pop(context, cat['label']);
                          },
                        );
                      }).toList(),
                    ),
                    actions: [
                      TextButton(
                        child:
                            Text(AppLocalizations.of(context)!.cancel_button),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  );
                },
              );

              if (selectedCategory != null) {
                final timeStr = log.split(" ")[0]; // 時刻部分を取得
                final updatedLog = '$timeStr $selectedCategory';
                await SharedPreferences.getInstance(); // 1回目（キャッシュクリア用）
                final prefs = await SharedPreferences.getInstance();
                await prefs.reload();
                final raw = prefs.getString('cry_logs') ?? '{}';
                final data = Map<String, dynamic>.from(json.decode(raw));
                final selectedDay = _formatDate(_selectedDay!);
                final selectedLogs = List<String>.from(data[selectedDay] ?? []);
                selectedLogs[index] = updatedLog;

                data[selectedDay] = selectedLogs;
                await prefs.setString('cry_logs', json.encode(data));
                setState(() {
                  _eventMap = data.map(
                    (k, v) => MapEntry(k, List<String>.from(v)),
                  );
                });
              }
            },
          ),
        ),
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
                    items: _categories.map<DropdownMenuItem<String>>((cat) {
                      return DropdownMenuItem<String>(
                        value: cat['label'],
                        child: Row(
                          children: [
                            Icon(cat['icon'], color: cat['color']),
                            SizedBox(width: 8),
                            Text(cat['label']),
                          ],
                        ),
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
                    final now = DateTime.now();
                    final inputTime = DateTime(
                      _selectedDay!.year,
                      _selectedDay!.month,
                      _selectedDay!.day,
                      selectedTime!.hour,
                      selectedTime!.minute,
                    );

                    if (inputTime.isAfter(now)) {
                      _showError(context, "未来の時刻は記録できません");
                      return;
                    }

                    if (selectedCategory != null && selectedTime != null) {
                      final now = DateTime.now();
                      final selectedDate = _selectedDay ?? now;
                      final mSecond = DateFormat('SSS').format(now);
                      final formattedTime =
                          '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}';
                      final log =
                          '$formattedTime:00.$mSecond $selectedCategory';

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

  void _showError(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('エラー'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  // 選択された日にログを追加
  Future<void> _addLogToSelectedDate(String log, DateTime date) async {
    await SharedPreferences.getInstance(); // 1回目（キャッシュクリア用）
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final rawData = prefs.getString('cry_logs') ?? '{}';
    final data = Map<String, dynamic>.from(json.decode(rawData));

    final key = _formatDate(date);
    final dayLogs = List<String>.from(data[key] ?? []);
    dayLogs.add(log);
    data[key] = dayLogs;

    await prefs.setString('cry_logs', json.encode(data));

    // 時間の昇順でソート
    dayLogs.sort((a, b) {
      final timeA = a.split(' ').first; // "HH:mm" 部分を取得
      final timeB = b.split(' ').first;
      return timeA.compareTo(timeB); // 時間を文字列として比較
    });

    setState(() {
      _eventMap = data.map(
        (k, v) => MapEntry(k, List<String>.from(v)),
      );
      _hoveredIndexes.add(dayLogs.indexOf(log)); // 新規追加された行を追跡
    });

    // 新しく追加された行にスクロール
    final newIndex = dayLogs.indexOf(log);
    Future.delayed(Duration(milliseconds: 100), () {
      if (!mounted) return;
      _scrollController.animateTo(
        newIndex * 60.0, // 各行の高さ（例: 60.0）に基づいて計算
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });

    // 一定時間後にホバー状態を解除
    Future.delayed(Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _hoveredIndexes.remove(dayLogs.indexOf(log));
      });
    });
  }

  // メモを追加するダイアログを表示
  Future<void> _showMemoDialog(int index) async {
    final log = _getEventsForDay(_selectedDay!)[index];
    String existingMemo = '';

    // 既存のメモを取得
    if (log.contains('[メモ:')) {
      final startIndex = log.indexOf('[メモ:') + 4;
      final endIndex = log.lastIndexOf(']');
      existingMemo = log.substring(startIndex + 1, endIndex).trim();
    }

    String memo = existingMemo;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('メモを編集'),
          content: TextField(
            controller:
                TextEditingController(text: existingMemo), // 既存のメモを初期値に設定
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
    await SharedPreferences.getInstance(); // 1回目（キャッシュクリア用）
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final rawData = prefs.getString('cry_logs') ?? '{}';
    final data = Map<String, dynamic>.from(json.decode(rawData));
    final key = _formatDate(_selectedDay!);
    final dayLogs = List<String>.from(data[key] ?? []);

    if (index >= 0 && index < dayLogs.length) {
      final log = dayLogs[index];
      final sanitizedMemo = memo.replaceAll('\n', ' '); // 改行をスペースに置き換え

      // 既存のメモを削除して新しいメモを追加
      final updatedLog = log.contains('[メモ:')
          ? log.replaceFirst(RegExp(r'\[メモ:.*?\]'), '[メモ: $sanitizedMemo]')
          : '$log [メモ: $sanitizedMemo]';

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
            child: ListView.builder(
              controller: _scrollController, // スクロールコントローラーを設定
              padding:
                  const EdgeInsets.symmetric(vertical: 0.0), // リスト全体の上下余白を削除
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
