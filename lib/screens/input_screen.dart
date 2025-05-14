// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // 時刻整形に使用
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class InputScreen extends StatefulWidget {
  @override
  _InputScreenState createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  List<String> _logs = [];
  Set<int> _newlyAddedIndexes = {}; // 新規追加された行のインデックスを追跡

  // カテゴリの定義
  final List<Map<String, dynamic>> _categories = [
    {
      'label': 'ミルク',
      'icon': FontAwesomeIcons.prescriptionBottle,
      'color': Colors.lightBlue
    },
    {
      'label': 'おむつ',
      'icon': FontAwesomeIcons.toilet,
      'color': Colors.lightGreen
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

  @override
  void initState() {
    super.initState();
    _loadTodayLogs();
  }

  // 今日の日付をキーにしたログの取得
  // 形式: YYYY-MM-DD
  // 例: 2023-10-01
  String _getTodayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  // 今日のログをSharedPreferencesから取得
  // 取得したログは降順にソートして表示
  Future<void> _loadTodayLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('cry_logs') ?? '{}';
    final data = json.decode(raw) as Map<String, dynamic>;
    final todayKey = _getTodayKey();
    final todayLogs = List<String>.from(data[todayKey] ?? []);

    todayLogs.sort((a, b) {
      final timeA = a.split(' ').first;
      final timeB = b.split(' ').first;
      return timeB.compareTo(timeA); // 降順
    });

    setState(() {
      _logs = todayLogs;
    });
  }

  // ログを追加するメソッド
  // 引数はカテゴリ名
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

    todayLogs.sort((a, b) {
      final timeA = a.split(' ').first;
      final timeB = b.split(' ').first;
      return timeB.compareTo(timeA); // 降順
    });

    setState(() {
      _logs = todayLogs;
      _newlyAddedIndexes.add(0); // 新規追加された行のインデックスを追跡
    });

    // 一定時間後に色をリセット
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _newlyAddedIndexes.remove(0); // 色をリセット
      });
    });
  }

  // 今日のログを削除するメソッド
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

  // ヘルプダイアログを表示するメソッド
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.help_title),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text(AppLocalizations.of(context)!.help_text_1),
                Text(AppLocalizations.of(context)!.help_text_2),
                Text(AppLocalizations.of(context)!.help_text_3),
                Text(AppLocalizations.of(context)!.help_text_4),
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
  IconData _getCategoryIcon(String log) {
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
    if (log.contains('ミルク')) return Colors.lightBlue;
    if (log.contains('おむつ')) return Colors.lightGreen;
    if (log.contains('眠い')) return Colors.amber;
    if (log.contains('抱っこ')) return Colors.grey;
    if (log.contains('不快')) return Colors.orange;
    if (log.contains('体調不良')) return Colors.red;
    return Colors.black45;
  }

  // 今日のログを表示するウィジェット
  Widget _itemBuilder(int index) {
    final log = _logs[index];
    final isNew = _newlyAddedIndexes.contains(index); // 新規追加された行かどうかを判定
    final themeColor = Theme.of(context).colorScheme.primary; // 現在のテーマの色を取得

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
        // リストから即座に削除
        setState(() {
          _logs.removeAt(index);
          _newlyAddedIndexes.remove(index); // 削除された行を追跡から除外
        });

        // 永続ストレージからも削除
        final prefs = await SharedPreferences.getInstance();
        final raw = prefs.getString('cry_logs') ?? '{}';
        final data = Map<String, dynamic>.from(json.decode(raw));
        final todayKey = _getTodayKey();
        final todayLogs = List<String>.from(data[todayKey] ?? []);
        if (index >= 0 && index < todayLogs.length) {
          todayLogs.removeAt(index);

          // リストを降順にソート
          todayLogs.sort((a, b) {
            final timeA = a.split(' ').first;
            final timeB = b.split(' ').first;
            return timeB.compareTo(timeA); // 降順
          });

          data[todayKey] = todayLogs;
          await prefs.setString('cry_logs', json.encode(data));
        }
      },
      child: GestureDetector(
        onTap: () async {
          String? selectedCategory = await showDialog<String>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('カテゴリを選択'),
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
              );
            },
          );

          if (selectedCategory != null) {
            final timeStr = log.split(" ")[0]; // 時刻部分を取得
            final updatedLog = '$timeStr $selectedCategory';
            final prefs = await SharedPreferences.getInstance();
            final raw = prefs.getString('cry_logs') ?? '{}';
            final data = Map<String, dynamic>.from(json.decode(raw));
            final todayKey = _getTodayKey();
            final todayLogs = List<String>.from(data[todayKey] ?? []);
            todayLogs[index] = updatedLog;
            data[todayKey] = todayLogs;
            await prefs.setString('cry_logs', json.encode(data));
            setState(() {
              _logs = todayLogs;
            });
          }
        },
        child: Container(
          color: isNew
              ? themeColor.withOpacity(0.3)
              : Colors.transparent, // 新規行にテーマ色を適用
          child: ListTile(
            leading: Icon(
              _getCategoryIcon(log),
              color: _getCategoryColor(log),
            ),
            title: Text(log),
            trailing: IconButton(
              icon: Icon(Icons.note_add),
              onPressed: () => _showMemoDialog(index), // メモ追加ダイアログを表示
            ),
          ),
        ),
      ),
    );
  }

  // メモ追加ダイアログを表示するメソッド
  Future<void> _showMemoDialog(int index) async {
    final log = _logs[index];
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

  // メモを保存するメソッド
  Future<void> _saveMemo(int index, String memo) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('cry_logs') ?? '{}';
    final data = Map<String, dynamic>.from(json.decode(raw));
    final todayKey = _getTodayKey();
    final todayLogs = List<String>.from(data[todayKey] ?? []);

    if (index >= 0 && index < todayLogs.length) {
      // リストを降順にソート
      todayLogs.sort((a, b) {
        final timeA = a.split(' ').first;
        final timeB = b.split(' ').first;
        return timeB.compareTo(timeA); // 昇順
      });

      final log = todayLogs[index];
      final sanitizedMemo = memo.replaceAll('\n', ' '); // 改行をスペースに置き換え

      // 既存のメモを削除して新しいメモを追加
      final updatedLog = log.contains('[メモ:')
          ? log.replaceFirst(RegExp(r'\[メモ:.*?\]'), '[メモ: $sanitizedMemo]')
          : '$log [メモ: $sanitizedMemo]';

      todayLogs[index] = updatedLog;

      data[todayKey] = todayLogs;
      await prefs.setString('cry_logs', json.encode(data));

      setState(() {
        _logs = todayLogs;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.input_title),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline),
            tooltip: AppLocalizations.of(context)!.help_tooltip,
            onPressed: _showHelpDialog,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _logs.isNotEmpty ? _clearTodayLogs : null,
            tooltip: AppLocalizations.of(context)!.delete_today_tooltip,
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              elevation: 5,
            ),
            onPressed: () => _addLog('泣いた！'),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text(
                '泣いた！',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _logs.length,
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
