import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import '../reservation/transportation_popup.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin(); // 플러그인으로 알림등록 간결화

int notification_Id(DateTime lastDate, String title) {
  int notificaionId = (lastDate.hashCode + title.hashCode) % 2147483647;
  return notificaionId;
}


// 알림 초기화 함수
Future<void> initializeNotifications() async {
  const AndroidInitializationSettings androidInitSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings = InitializationSettings(
    android: androidInitSettings,
  );
  await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
      if(response.actionId == 'booking') {
        launchURL('https://www.kobus.co.kr/main.do');
        int? id = response.id;
        removeId(id!); // ID 삭제
      }
    },
  );

  // 타임존 초기화
  tz.initializeTimeZones();
}

// 알림 예약 함수
Future<void> scheduleNotification(int notificationId ,String title, DateTime firstDate) async {
  // 마감일 3일 전 오전 9시
  final notificationDate = firstDate
      .subtract(Duration(days: 3))
      .copyWith(hour: 9, minute: 0, second: 0);

  final tz.TZDateTime scheduledDate = tz.TZDateTime.from(notificationDate, tz.local);
  // 알림 ID 저장
  final existedId = await isIdStored(notificationId);
  if(!existedId) {
    await storeId(notificationId);
  }

  final now = DateTime.now();
  print("NOW: $now");
  print("NOTIFICATION DATE: $notificationDate");

  if (DateTime.now().isAfter(notificationDate)) {
    await flutterLocalNotificationsPlugin.show(
      notificationId+1, // 알림 ID
      title, //title
      '3일도 안남았습니다!', //body
      const NotificationDetails(
        android: AndroidNotificationDetails(
            'deadline_channel',
            '예약 알림',
            importance: Importance.high,
            priority: Priority.high,
            actions: <AndroidNotificationAction>[
              AndroidNotificationAction(
                'booking',
                '예약하러 가기',
                showsUserInterface: true,
              ),
            ]
        ),
      ),
    );
    removeId(notificationId);
  } else {
    print("Not showing notification");
  }

  await flutterLocalNotificationsPlugin.show(
    notificationId,
    '알람 예약 완료',
    title,
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
    title, //title
    '3일 뒤 출발입니다!', //body
    scheduledDate,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'deadline_channel',
        '예약 알림',
        importance: Importance.high,
        priority: Priority.high,
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction(
            'booking',
            '예약하러 가기',
            showsUserInterface: true,
          ),
        ]
      ),
    ),
    androidAllowWhileIdle: true, // 절전모드에서도 작동
    uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time, // 1일마다 반복
  );
}

Future<void> storeId(int id) async {
  final prefs = await SharedPreferences.getInstance();
  List<String> ids = prefs.getStringList('ids') ?? [];
  if(!ids.contains(id.toString())) {
    ids.add(id.toString());
    await prefs.setStringList('notification_ids', ids);
  }
}

Future<bool> isIdStored(int id) async {
  final prefs = await SharedPreferences.getInstance();
  List<String> ids = prefs.getStringList('notification_ids') ?? [];
  return ids.contains(id.toString());
}

Future<void> removeId(int id) async {
  final prefs = await SharedPreferences.getInstance();
  List<String> ids = prefs.getStringList('notification_ids') ?? [];
  ids.remove(id.toString());
  await prefs.setStringList('notification_ids', ids);
}