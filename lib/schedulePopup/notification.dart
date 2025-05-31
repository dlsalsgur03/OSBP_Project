import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin(); // 플러그인으로 알림등록 간결화

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

  final int notificationId = lastDate.millisecondsSinceEpoch ~/ 1000;

  await flutterLocalNotificationsPlugin.show(
    notificationId,
    '알람 예약 완료',
    '3일전 알람이 예약되었습니다.',
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'info_channel',
        '정보 알림',
        importance: Importance.low,
        priority: Priority.low,
      ),
    ),
  );

  await flutterLocalNotificationsPlugin.zonedSchedule(
    notificationId, // 알림 ID
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
    matchDateTimeComponents: null, // 반복 안함.
  );

  print("알람 설정 완료");
}