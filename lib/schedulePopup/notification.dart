import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import '../reservation/transportation_popup.dart';
import 'getHolyday.dart';

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
Future<void> scheduleNotification(int notificationId ,String title, DateTime firstDate, DateTime lastDate) async {
  // 마감일 3일 전 오전 9시
  final notificationDate = calculateNotificationDate(
      firstDate : firstDate,
      lastDate : lastDate,
      holidays: await loadSavedHolidays());

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

DateTime calculateNotificationDate({
  required DateTime firstDate,
  required DateTime lastDate,
  required List<DateTime> holidays,
}) {
  // firstDate와 lastDate의 시간 부분을 0시 0분 0초로 통일 (날짜만 비교하기 위해)
  final cleanFirstDate = DateTime(firstDate.year, firstDate.month, firstDate.day);
  final cleanLastDate = DateTime(lastDate.year, lastDate.month, lastDate.day);

  bool holidayInRange = false;
  for (DateTime holiday in holidays) {
    // holiday도 시간 부분을 0시 0분 0초로 통일
    final cleanHoliday = DateTime(holiday.year, holiday.month, holiday.day);

    // 공휴일이 firstDate (포함) 와 lastDate (포함) 사이에 있는지 확인
    if (!cleanHoliday.isBefore(cleanFirstDate) && !cleanHoliday.isAfter(cleanLastDate)) {
      holidayInRange = true;
      break;
    }
  }

  if (holidayInRange) {
    // firstDate를 기준으로 5일 전 날짜 계산
    return firstDate.subtract(Duration(days: 5));
  } else {
    return firstDate.subtract(Duration(days: 3)); // 조건에 맞는 공휴일이 없음
  }
}