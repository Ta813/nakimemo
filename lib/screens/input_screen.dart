// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nakimemo/setting/layout_provider.dart';
import 'package:nakimemo/setting/layout_type.dart';
import 'package:provider/provider.dart';
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

    todayLogs.sort((a, b) {
      final timeA = a.split(' ').first;
      final timeB = b.split(' ').first;
      return timeB.compareTo(timeA); // 降順
    });

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

    todayLogs.sort((a, b) {
      final timeA = a.split(' ').first;
      final timeB = b.split(' ').first;
      return timeB.compareTo(timeA); // 降順
    });

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

  Widget _itemBuilder(int index) {
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
        // リストから即座に削除
        setState(() {
          _logs.removeAt(index);
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
                            context, '$timePart $tempSelectedCategory');
                      }
                    },
                  ),
                ],
              );
            },
          );

          if (newCategory != null && newCategory.trim().isNotEmpty) {
            final prefs = await SharedPreferences.getInstance();
            final raw = prefs.getString('cry_logs') ?? '{}';
            final data = Map<String, dynamic>.from(json.decode(raw));
            final todayKey = _getTodayKey();
            final todayLogs = List<String>.from(data[todayKey] ?? []);
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
  }

  @override
  Widget build(BuildContext context) {
    final layoutProvider = Provider.of<LayoutProvider>(context);
    final isGrid = layoutProvider.layoutType == LayoutType.grid;

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
          Wrap(
            spacing: 20,
            runSpacing: 20, // これで縦方向に段を分ける
            children: _categories.map((cat) {
              return SizedBox(
                width: MediaQuery.of(context).size.width / 2 - 20, // 幅を調整して2列に
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cat['color'], // 背景色
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // ボタンを丸くする
                    ),
                    elevation: 5, // 影を追加
                  ),
                  onPressed: () => _addLog(cat['label']),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(cat['icon'],
                          color: Colors.white, size: 30), // アイコンを大きく
                      const SizedBox(height: 20),
                      Text(
                        cat['label'],
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const Divider(),
          Expanded(
            child: isGrid
                ? GridView.builder(
                    itemCount: _logs.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // グリッドの列数
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 2.5,
                    ),
                    itemBuilder: (context, index) {
                      return _itemBuilder(index);
                    },
                  )
                : ListView.builder(
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
