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

  BannerAd? _bannerAd;

  bool isDark = false;

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
          title: Text(AppLocalizations.of(context)!.calendar_help_title,
              style: TextStyle(color: isDark ? Colors.white : Colors.black)),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text(AppLocalizations.of(context)!.calendar_help_1,
                    style:
                        TextStyle(color: isDark ? Colors.white : Colors.black)),
                Text(AppLocalizations.of(context)!.calendar_help_2,
                    style:
                        TextStyle(color: isDark ? Colors.white : Colors.black)),
                Text(AppLocalizations.of(context)!.calendar_help_3,
                    style:
                        TextStyle(color: isDark ? Colors.white : Colors.black)),
                Text(AppLocalizations.of(context)!.calendar_help_4,
                    style:
                        TextStyle(color: isDark ? Colors.white : Colors.black)),
                Text(AppLocalizations.of(context)!.calendar_help_5,
                    style:
                        TextStyle(color: isDark ? Colors.white : Colors.black)),
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

    final logDeletedText = AppLocalizations.of(context)!.log_deleted;

    return Dismissible(
      key: Key(log + index.toString()),
      background: Container(color: Colors.red),
      onDismissed: (direction) async {
        await _removeEvent(index);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_getLog(log)}$logDeletedText')),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        child: Card(
          color: isHovered
              ? themeColor.withOpacity(0.2)
              : Theme.of(context).cardColor,
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
              _getLog(log) ?? log,
            ),
            trailing: IconButton(
              icon: Icon(Icons.note_add),
              tooltip: AppLocalizations.of(context)!.edit_memo,
              onPressed: () => _showMemoDialog(index), // メモ追加ダイアログを表示
            ),
            onTap: () async {
              String? selectedCategory = await showDialog<String>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(
                        AppLocalizations.of(context)!.edit_category_title,
                        style: TextStyle(
                            color: isDark ? Colors.white : Colors.black)),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _categories.map((cat) {
                        return ListTile(
                          leading: Icon(cat['icon'], color: cat['color']),
                          title:
                              Text(_getCategory(cat['label']) ?? cat['label']),
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

                final logUpdatedText =
                    AppLocalizations.of(context)!.log_updated;

                // スナックバーでカテゴリ変更を通知
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('${_getLog(updatedLog)}$logUpdatedText')),
                );
              }
            },
          ),
        ),
      ),
    );
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

  // ログのカテゴリに応じて表示を整形するメソッド
  // ログの形式: "HH:mm:ss.SSS カテゴリ"
  String? _getLog(String log) {
    String category = log.split(" ")[1];
    String resultLog = "";

    if (category == '泣いた！') {
      resultLog = log.replaceFirst('泣いた！', AppLocalizations.of(context)!.cry);
    } else if (category == 'ミルク') {
      resultLog = log.replaceFirst('ミルク', AppLocalizations.of(context)!.milk);
    } else if (category == 'おむつ') {
      resultLog = log.replaceFirst('おむつ', AppLocalizations.of(context)!.diaper);
    } else if (category == '眠い') {
      resultLog = log.replaceFirst('眠い', AppLocalizations.of(context)!.sleepy);
    } else if (category == '抱っこ') {
      resultLog = log.replaceFirst('抱っこ', AppLocalizations.of(context)!.hold);
    } else if (category == '不快') {
      resultLog =
          log.replaceFirst('不快', AppLocalizations.of(context)!.uncomfortable);
    } else if (category == '体調不良') {
      resultLog = log.replaceFirst('体調不良', AppLocalizations.of(context)!.sick);
    }

    final memoLabel = '[${AppLocalizations.of(context)!.memo}:';
    return resultLog
        .replaceFirst(RegExp(r'\.\d{3}'), '')
        .replaceAll('[メモ:', memoLabel);
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
              title: Text(AppLocalizations.of(context)!.add_record,
                  style:
                      TextStyle(color: isDark ? Colors.white : Colors.black)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.select_category,
                      border: OutlineInputBorder(),
                    ),
                    items: _categories.map<DropdownMenuItem<String>>((cat) {
                      return DropdownMenuItem<String>(
                        value: cat['label'],
                        child: Row(
                          children: [
                            Icon(cat['icon'], color: cat['color']),
                            SizedBox(width: 8),
                            Text(_getCategory(cat['label']) ?? cat['label']),
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
                    child: Text(
                        '${AppLocalizations.of(context)!.select_time} ${selectedTime?.format(context) ?? ''}'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text(AppLocalizations.of(context)!.cancel_button),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  child: Text(AppLocalizations.of(context)!.add_button),
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
                      _showError(context,
                          AppLocalizations.of(context)!.future_time_error);
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
        title: Text(AppLocalizations.of(context)!.error),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.ok),
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

    // 一定時間後にホバー状態を解除
    Future.delayed(Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _hoveredIndexes.remove(dayLogs.indexOf(log));
      });
    });

    // スナックバーで追加を通知
    final logAddedText = AppLocalizations.of(context)!.log_added;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_getLog(log)}$logAddedText')),
    );
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
          title: Text(AppLocalizations.of(context)!.edit_memo,
              style: TextStyle(color: isDark ? Colors.white : Colors.black)),
          content: TextField(
            controller:
                TextEditingController(text: existingMemo), // 既存のメモを初期値に設定
            onChanged: (value) {
              memo = value;
            },
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.enter_memo,
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
              child: Text(AppLocalizations.of(context)!.save_button),
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

      final savedMemoText = AppLocalizations.of(context)!.saved_memo;

      // スナックバーで追加を通知
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_getLog(log)}$savedMemoText')),
      );
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
      body: Stack(
        children: [
          // 背景のカレンダー（常に表示）
          Positioned.fill(
            child: Column(
              children: [
                Container(
                  height: 392, // 任意の高さ
                  child: TableCalendar(
                    locale: Localizations.localeOf(context).languageCode,
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
                ),
                Expanded(child: Container()), // カレンダーの下を埋める
              ],
            ),
          ),

          // 上からかぶさるリスト
          DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.2,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              final events = _getEventsForDay(_selectedDay!);

              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // これ重要
                    children: [
                      // 上のバー（つかみ用）
                      Container(
                        width: 40,
                        height: 6,
                        margin: EdgeInsets.only(top: 10, bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      // 追加ボタン
                      Container(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: IconButton(
                          icon: Icon(Icons.add),
                          tooltip: AppLocalizations.of(context)!.add_button,
                          onPressed: _showAddLogDialog,
                        ),
                      ),
                      Divider(height: 1),
                      // イベントリスト
                      ListView.builder(
                        controller: scrollController,
                        physics: NeverScrollableScrollPhysics(), // 二重スクロール防止
                        shrinkWrap: true, // Column の中でサイズを自動調整
                        itemCount: events.length,
                        itemBuilder: (context, index) => _itemBuilder(index),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
