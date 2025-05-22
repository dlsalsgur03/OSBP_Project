import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

// 알림 초기화 함수
Future<void> initializeNotifications() async {
  const AndroidInitializationSettings androidInitSettings =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings = InitializationSettings(
    android: androidInitSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // 타임존 초기화
  tz.initializeTimeZones();
}

// 알림 예약 함수
Future<void> scheduleNotification(DateTime lastDate) async {
  // 마감일 3일 전 오전 9시
  final notificationDate = lastDate
      .subtract(Duration(days: 3))
      .copyWith(hour: 0, minute: 0, second: 0);

  // 알림 예약 시간이 과거면 알람 안받기
  if (notificationDate.isBefore(DateTime.now())) return;

  final tz.TZDateTime scheduledDate =
  tz.TZDateTime.from(notificationDate, tz.local);

  await flutterLocalNotificationsPlugin.zonedSchedule(
    0, // 알림 ID
    '마감 임박 알림', //title
    '3일 뒤 마감일입니다!', //body
    scheduledDate,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'deadline_channel',
        '마감 알림',
        importance: Importance.high,
        priority: Priority.high,
      ),
    ),
    androidAllowWhileIdle: true, // 절전모드에서도 작동
    uiLocalNotificationDateInterpretation:
    UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time, // 반복용이면 사용
  );
}