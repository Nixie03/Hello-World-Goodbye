import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DoseLog {
  final String reminderId;
  final String reminderName;
  final DateTime timestamp;
  final bool taken;
  final String? notes;

  DoseLog({
    required this.reminderId,
    required this.reminderName,
    required this.timestamp,
    required this.taken,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'reminderId': reminderId,
    'reminderName': reminderName,
    'timestamp': timestamp.toIso8601String(),
    'taken': taken,
    'notes': notes,
  };

  factory DoseLog.fromJson(Map<String, dynamic> json) => DoseLog(
    reminderId: json['reminderId'],
    reminderName: json['reminderName'],
    timestamp: DateTime.parse(json['timestamp']),
    taken: json['taken'],
    notes: json['notes'],
  );
}

class DoseHistoryService {
  static final DoseHistoryService instance = DoseHistoryService._();
  DoseHistoryService._();

  static const String _keyDoseHistory = 'dose_history';

  // Log a dose
  Future<void> logDose({
    required String reminderId,
    required String reminderName,
    required bool taken,
    String? notes,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getDoseHistory();
    
    final log = DoseLog(
      reminderId: reminderId,
      reminderName: reminderName,
      timestamp: DateTime.now(),
      taken: taken,
      notes: notes,
    );
    
    history.add(log);
    
    // Keep only last 90 days
    final cutoffDate = DateTime.now().subtract(const Duration(days: 90));
    history.removeWhere((log) => log.timestamp.isBefore(cutoffDate));
    
    final jsonList = history.map((log) => jsonEncode(log.toJson())).toList();
    await prefs.setStringList(_keyDoseHistory, jsonList);
  }

  // Get all dose history
  Future<List<DoseLog>> getDoseHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_keyDoseHistory) ?? [];
    return jsonList.map((json) => DoseLog.fromJson(jsonDecode(json))).toList();
  }

  // Get history for specific reminder
  Future<List<DoseLog>> getHistoryForReminder(String reminderId) async {
    final history = await getDoseHistory();
    return history.where((log) => log.reminderId == reminderId).toList();
  }

  // Get adherence rate for last 7 days
  Future<double> getAdherenceRate({int days = 7}) async {
    final history = await getDoseHistory();
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    final recentLogs = history.where((log) => log.timestamp.isAfter(cutoffDate)).toList();
    
    if (recentLogs.isEmpty) return 0.0;
    
    final taken = recentLogs.where((log) => log.taken).length;
    return taken / recentLogs.length;
  }

  // Get statistics
  Future<Map<String, dynamic>> getStatistics({int days = 7}) async {
    final history = await getDoseHistory();
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    final recentLogs = history.where((log) => log.timestamp.isAfter(cutoffDate)).toList();
    
    final taken = recentLogs.where((log) => log.taken).length;
    final missed = recentLogs.where((log) => !log.taken).length;
    
    return {
      'total': recentLogs.length,
      'taken': taken,
      'missed': missed,
      'adherenceRate': recentLogs.isEmpty ? 0.0 : taken / recentLogs.length,
      'days': days,
    };
  }

  // Clear history
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyDoseHistory);
  }
}
