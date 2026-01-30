import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._privateConstructor();
  static final NotificationService instance = NotificationService._privateConstructor();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iosInit = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    final settings = InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize(settings, onDidReceiveNotificationResponse: (response) {
      // handle notification tap if needed
    });
  }

  Future<void> requestPermissions() async {
    await _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> scheduleNotification({required int id, required String title, required String body, required DateTime dateTime, String repeat = 'none', String ringtone = 'default'}) async {
    // Decide whether sound should be played and configure platform-specific sound settings
    final playSound = ringtone != 'silent';

    AndroidNotificationSound? androidSound;
    String? iosSound;

    if (playSound && ringtone != 'default') {
      // Expecting a resource name or filename. For Android, raw resource must be without extension
      final base = ringtone.split('.').first;
      androidSound = RawResourceAndroidNotificationSound(base);
      iosSound = ringtone; // iOS expects filename in bundle e.g. 'chime.wav'
    }

    final androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'Reminders',
      channelDescription: 'Medication reminders',
      importance: Importance.max,
      priority: Priority.high,
      playSound: playSound,
      sound: androidSound,
    );

    final iosDetails = DarwinNotificationDetails(presentSound: playSound, sound: iosSound);

    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    final tzDate = tz.TZDateTime.from(dateTime, tz.local);

    if (repeat == 'daily') {
      await _plugin.zonedSchedule(id, title, body, tzDate, details, uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime, matchDateTimeComponents: DateTimeComponents.time, androidAllowWhileIdle: true);
    } else if (repeat == 'weekly') {
      // For weekly, match dayOfWeekAndTime
      await _plugin.zonedSchedule(id, title, body, tzDate, details, uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime, matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime, androidAllowWhileIdle: true);
    } else {
      await _plugin.zonedSchedule(id, title, body, tzDate, details, uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime, androidAllowWhileIdle: true);
    }
  }

  Future<void> cancel(int id) async => _plugin.cancel(id);

  Future<void> cancelAll() async => _plugin.cancelAll();
}
