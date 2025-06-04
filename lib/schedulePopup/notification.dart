import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import '../reservation/transportation_popup.dart';
import 'getHolyday.dart';
import '../reservation/transportation_recommend.dart';

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
      else if(response.actionId == 'booking_train') {
        launchURL('https://www.letskorail.com/');
        int? id = response.id;
        removeId(id!); // ID 삭제
      }
    },
  );
  // 타임존 초기화
  tz.initializeTimeZones();
}

// 알림 예약 함수
Future<void> scheduleNotification(int changer, int notificationId ,String title, DateTime firstDate, DateTime lastDate) async {
  // 날짜 비교, 사이에 공휴일이 있는지 확인
  bool isHaveholiday = calculateNotificationDate(
      firstDate : firstDate,
      lastDate : lastDate,
      holidays: await loadSavedHolidays());
  // 알림 날짜 설정
  late DateTime notificationDate;
  if(isHaveholiday) {
    notificationDate = firstDate.subtract(Duration(days: 5));
  } else {
    notificationDate = firstDate.subtract(Duration(days: 3));
  }
  final int num_day = notificationDate.difference(DateTime.now()).inDays;

  final tz.TZDateTime scheduledDate = tz.TZDateTime.from(notificationDate, tz.local);
  // 알림 ID 저장
  final existedId = await isIdStored(notificationId);
  if(!existedId) {
    await storeId(notificationId);
  }
  // 확인용
  final now = DateTime.now();
  print("NOW: $now");
  print("NOTIFICATION DATE: $notificationDate");
  print("Changer : $changer");
  final rTransportaion = await findNearestStation();
  final tcategory = rTransportaion['category_name'];
  String booking = 'booking';
  if(tcategory.contains('기차역')) {
    booking = 'booking_train';
  }
  // 긴급 알람 함수
  if (DateTime.now().isAfter(notificationDate) && changer==0 && isHaveholiday==true) {
    await flutterLocalNotificationsPlugin.show(
      notificationId+1, // 알림 ID
      title, //title
      '연휴포함! 얘매 서두르세요! 추천 : ${rTransportaion['place_name']}', //body
      NotificationDetails(
        android: AndroidNotificationDetails(
            'deadline_channel',
            '긴급 알림',
            importance: Importance.high,
            priority: Priority.high,
            actions: <AndroidNotificationAction>[
              AndroidNotificationAction(
                booking,
                '예약하러 가기',
                showsUserInterface: true,
              ),
            ]
        ),
      ),
    );
  }
  else if(DateTime.now().isAfter(notificationDate) && changer==0 && isHaveholiday==false) {
    await flutterLocalNotificationsPlugin.show(
      notificationId + 1, // 알림 ID
      title, //title
      '얼마 안남았습니다! 얘매 서두르세요! 추천 : ${rTransportaion['place_name']}', //body
      const NotificationDetails(
        android: AndroidNotificationDetails(
            'deadline_channel',
            '긴급 알림',
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
  }
  else if(DateTime.now().isAfter(notificationDate)) {
    await flutterLocalNotificationsPlugin.show(
      notificationId + 1, // 알림 ID
      title, //title
      '$num_day 남았어요!', //body
      const NotificationDetails(
        android: AndroidNotificationDetails(
            'deadline_channel',
            '알림',
            importance: Importance.high,
            priority: Priority.high,
        ),
      ),
    );
  }
  else {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId, // 알림 ID
      title, //title
      '$num_day일 뒤 출발입니다!', //body
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

bool calculateNotificationDate({
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
    print("공휴일 포함");
    return true;
  } else {
    print("공휴일 미포함");
    return false; // 조건에 맞는 공휴일이 없음
  }
}