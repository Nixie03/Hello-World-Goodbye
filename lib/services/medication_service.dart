import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../priority_scheduler.dart';
import 'notification_service.dart';

/// Simple service managing reminders and scheduling logic, persistence, and notifications.
class MedicationService extends ChangeNotifier {
  MedicationService._privateConstructor() {
    _loadFromStorage();
    NotificationService.instance.init();
  }
  static final MedicationService instance = MedicationService._privateConstructor();

  final PriorityScheduler _scheduler = PriorityScheduler();
  final List<Reminder> _reminders = [];
  static const _prefsKey = 'reminders';
  static const _settingsKeyDefaultRingtone = 'default_ringtone';
  static const _onboardingKey = 'onboarding_seen';
  final _uuid = const Uuid();

  String _defaultRingtone = 'default';

  List<Reminder> get reminders => List.unmodifiable(_reminders);

  List<Reminder> get scheduled => _scheduler.scheduleReminders(_reminders);

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _defaultRingtone = prefs.getString(_settingsKeyDefaultRingtone) ?? 'default';
    final list = prefs.getStringList(_prefsKey) ?? [];
    _reminders
      ..clear()
      ..addAll(list.map((s) => Reminder.fromJson(json.decode(s) as Map<String, dynamic>)));
    // Reschedule notifications for loaded reminders
    for (final r in _reminders) {
      _scheduleReminderNotification(r);
    }
    notifyListeners();
  }

  String get defaultRingtone => _defaultRingtone;

  Future<void> setDefaultRingtone(String name) async {
    _defaultRingtone = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKeyDefaultRingtone, name);
    notifyListeners();
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _reminders.map((r) => json.encode(r.toJson())).toList();
    await prefs.setStringList(_prefsKey, list);
  }

  // Exposed helper to read default ringtone directly when needed
  Future<String?> loadPrefsForSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_settingsKeyDefaultRingtone);
  }

  // Onboarding helper: whether the tips/onboarding has been seen
  Future<bool> onboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  Future<void> setOnboardingSeen(bool seen) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, seen);
  }

  int _idFor(Reminder r) => r.id.hashCode.abs() % 0x7FFFFFFF;

  Future<void> _scheduleReminderNotification(Reminder r) async {
    final id = _idFor(r);
    await NotificationService.instance.cancel(id);
    if (!r.muted && r.time.isAfter(DateTime.now())) {
      await NotificationService.instance.scheduleNotification(id: id, title: r.name, body: 'Time to take ${r.name}', dateTime: r.time, repeat: r.repeat, ringtone: r.ringtone);
    }
  }

  Future<void> add(Reminder reminder) async {
    final r = reminder.id.isEmpty ? Reminder(id: _uuid.v4(), name: reminder.name, time: reminder.time, priority: reminder.priority, muted: reminder.muted, repeat: reminder.repeat, snoozeMinutes: reminder.snoozeMinutes, ringtone: reminder.ringtone) : reminder;
    _reminders.add(r);
    await _saveToStorage();
    await _scheduleReminderNotification(r);
    notifyListeners();
  }

  Future<void> addAll(List<Reminder> reminders) async {
    for (var r in reminders) {
      if (r.id.isEmpty) r = Reminder(id: _uuid.v4(), name: r.name, time: r.time, priority: r.priority, muted: r.muted, repeat: r.repeat, snoozeMinutes: r.snoozeMinutes, ringtone: r.ringtone);
      _reminders.add(r);
      await _scheduleReminderNotification(r);
    }
    await _saveToStorage();
    notifyListeners();
  }

  Future<void> update(Reminder updated) async {
    final i = _reminders.indexWhere((r) => r.id == updated.id);
    if (i != -1) {
      _reminders[i] = updated;
      await _saveToStorage();
      await _scheduleReminderNotification(updated);
      notifyListeners();
    }
  }

  Future<void> remove(String id) async {
    final i = _reminders.indexWhere((r) => r.id == id);
    if (i != -1) {
      final r = _reminders.removeAt(i);
      await _saveToStorage();
      await NotificationService.instance.cancel(_idFor(r));
      notifyListeners();
    }
  }

  Future<void> clear() async {
    for (final r in _reminders) {
      await NotificationService.instance.cancel(_idFor(r));
    }
    _reminders.clear();
    await _saveToStorage();
    notifyListeners();
  }

  // Sample reminders removed by request - encourage users to create their own reminders.
}