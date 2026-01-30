/// Simple priority-based scheduler for medication reminders.
///
/// This is a small, self-contained implementation to get you started.
class Reminder {
  final String id;
  final String name;
  final DateTime time;
  final int priority; // higher value means higher priority
  final bool muted; // if true, alarm for this reminder is muted
  final String repeat; // 'none', 'daily', 'weekly'
  final int snoozeMinutes; // amount to snooze in minutes
  final String ringtone; // ringtone id or 'default'/'silent'

  Reminder({
    required this.id,
    required this.name,
    required this.time,
    required this.priority,
    this.muted = false,
    this.repeat = 'none',
    this.snoozeMinutes = 0,
    this.ringtone = 'default',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'time': time.toIso8601String(),
        'priority': priority,
        'muted': muted,
        'repeat': repeat,
        'snoozeMinutes': snoozeMinutes,
        'ringtone': ringtone,
      };

  factory Reminder.fromJson(Map<String, dynamic> json) => Reminder(
        id: json['id'] as String,
        name: json['name'] as String,
        time: DateTime.parse(json['time'] as String),
        priority: json['priority'] as int,
        muted: json['muted'] as bool? ?? false,
        repeat: json['repeat'] as String? ?? 'none',
        snoozeMinutes: json['snoozeMinutes'] as int? ?? 0,
        ringtone: json['ringtone'] as String? ?? 'default',
      );

  @override
  String toString() => '$name @ $time (p$priority)${muted ? " (muted)" : ""}';
}

class PriorityScheduler {
  /// Sort reminders by priority (desc) then by time (asc).
  List<Reminder> scheduleReminders(List<Reminder> reminders) {
    final copy = List<Reminder>.from(reminders);
    copy.sort((a, b) {
      final priorityCompare = b.priority.compareTo(a.priority);
      if (priorityCompare != 0) return priorityCompare;
      return a.time.compareTo(b.time);
    });
    return copy;
  }
}
