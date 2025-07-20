import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(initSettings);
  }

  static Future<void> scheduleTaskReminderNotification({
    required int id,
    required String title,
    required DateTime createdAt,
  }) async {
    // 24 hours later
    final scheduledTime = tz.TZDateTime.from(createdAt.add(Duration(days: 1)), tz.local);

    const androidDetails = AndroidNotificationDetails(
      'task_reminder_channel',
      'Task Reminders',
      channelDescription: 'Reminds about uncompleted tasks after 1 day',
      importance: Importance.max,
      priority: Priority.high,
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      '⏰ Task Reminder',
      'You haven\'t completed the task: "$title"',
      scheduledTime,
      const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: null,
    );
  }
  static Future<void> showNotification({
  required int id,
  required String title,
  required String body,
}) async {
  const androidDetails = AndroidNotificationDetails(
    'fcm_channel',
    'FCM Notifications',
    channelDescription: 'Firebase Cloud Messaging notifications',
    importance: Importance.max,
    priority: Priority.high,
  );

  await _notificationsPlugin.show(
    id,
    title,
    body,
    const NotificationDetails(android: androidDetails),
  );
}

}

