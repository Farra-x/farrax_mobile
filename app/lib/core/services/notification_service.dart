import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings android =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings =
        InitializationSettings(android: android);
    await _plugin.initialize(settings);
  }

  static Future<void> scheduleWithdrawalAlert({
    required int id,
    required String animalTag,
    required String drugName,
    required DateTime clearDate,
    required bool isMeat,
  }) async {
    final String type = isMeat ? 'meat' : 'milk';
    await _plugin.zonedSchedule(
      id,
      'Withdrawal Period Ending — $animalTag',
      '$drugName $type withdrawal clears on ${_fmt(clearDate)}',
      tz.TZDateTime.from(clearDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'withdrawal',
          'Withdrawal Alerts',
          channelDescription: 'Alerts for drug withdrawal periods',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> scheduleTbDueAlert({
    required int id,
    required String farmName,
    required DateTime dueDate,
    required int daysBefore,
  }) async {
    final DateTime fireDate = dueDate.subtract(Duration(days: daysBefore));
    if (fireDate.isBefore(DateTime.now())) return;
    await _plugin.zonedSchedule(
      id,
      'TB Test Due${daysBefore > 0 ? ' in $daysBefore days' : ' Today'}',
      '$farmName TB test due on ${_fmt(dueDate)}',
      tz.TZDateTime.from(fireDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'tb_tests',
          'TB Test Reminders',
          channelDescription: 'Reminders for upcoming TB tests',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelAlert(int id) => _plugin.cancel(id);
  static Future<void> cancelAll() => _plugin.cancelAll();

  static String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
