import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'pose_analyzer.dart';

class HistoryService {
  static const _key = 'formfix_scan_history';

  static Future<void> save(ScanResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await load();
    existing.insert(0, result);
    final trimmed = existing.take(90).toList();
    final encoded = trimmed.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList(_key, encoded);
  }

  static Future<List<ScanResult>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw.map((s) {
      final map = jsonDecode(s) as Map<String, dynamic>;
      return ScanResult(
        score: map['score'] as int,
        issues: [],
        scannedAt: DateTime.parse(map['scannedAt'] as String),
      );
    }).toList();
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}