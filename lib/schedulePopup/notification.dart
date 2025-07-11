import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import '../reservation/transportation_popup.dart';
import 'getHolyday.dart';
import '../reservation/transportation_recommend.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin(); // 플러그인으로 알림등록 간결화

// 알람 알림 id 생성 함수
int notification_Id(DateTime lastDate, String title) {
  int notificaionId = (lastDate.hashCode + title.hashCode) % 2147483647;
  return notificaionId;
}

// 알림 초기화 함수
Future<void> initializeNotifications() async {
  const AndroidInitializationSettings androidInitSettings = AndroidInitializationSettings('@mipmap/splash_icon');
  const InitializationSettings initSettings = InitializationSettings(
    android: androidInitSettings,
  );
  final NotificationAppLaunchDetails? details = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: handleNotificationAction,
  );
  if (details?.didNotificationLaunchApp ?? false) {
    final response = details!.notificationResponse;
    if (response != null) {
      handleNotificationAction(response);
    }
  }
  // 타임존 초기화
  tz.initializeTimeZones();
}

// notification url 설정 및 notification 제거 함수
void handleNotificationAction(NotificationResponse response) {
  String? url;
  switch (response.actionId) {
    case 'booking':
      url = 'https://www.bustago.or.kr/newweb/kr/index.do';
      print("버스 예약 URL 열기 시도");
      break;
    case 'booking_train':
      url = 'https://www.letskorail.com/';
      print("기차 예약 URL 열기 시도");
      break;
  }
  if (url != null) {
    launchURL(url);
  }
  // 알림 ID 삭제 및 취소
  final id = response.id;
  if (id != null) {
    removeId(id);
    flutterLocalNotificationsPlugin.cancel(id);
  }
}

// 알림 예약 및 제공 함수
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
  final int num_day = (firstDate.difference(DateTime.now()).inDays).abs();

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
  // 긴급 알람 기능
  if (DateTime.now().isAfter(notificationDate) && changer==0 && isHaveholiday==true) {
    await flutterLocalNotificationsPlugin.show(
      notificationId+1, // 알림 ID
      title, //title
      '연휴포함! 얘매 서두르세요!\n 추천 : ${rTransportaion['place_name']}', //body
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
      '$num_day일 남았습니다! 얘매 서두르세요!\n 추천 : ${rTransportaion['place_name']}', //body
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
      '일정 시작이 $num_day일 남음', //body
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
  await flutterLocalNotificationsPlugin.zonedSchedule(
    notificationId, // 알림 ID
    title, //title
    '$num_day일 뒤 일정 시작입니다!', //body
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

  await flutterLocalNotificationsPlugin.show(
    notificationId,
    '알람 예약 완료 $num_day일 남음',
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
// 알람 Id 저장 함수
Future<void> storeId(int id) async {
  final prefs = await SharedPreferences.getInstance();
  List<String> ids = prefs.getStringList('ids') ?? [];
  if(!ids.contains(id.toString())) {
    ids.add(id.toString());
    await prefs.setStringList('notification_ids', ids);
  }
}
// 알람 Id 존재 확인 함수
Future<bool> isIdStored(int id) async {
  final prefs = await SharedPreferences.getInstance();
  List<String> ids = prefs.getStringList('notification_ids') ?? [];
  return ids.contains(id.toString());
}
// 알람 Id 삭제 함수
Future<void> removeId(int id) async {
  final prefs = await SharedPreferences.getInstance();
  List<String> ids = prefs.getStringList('notification_ids') ?? [];
  ids.remove(id.toString());
  await prefs.setStringList('notification_ids', ids);
}

// 예약 일정 사이에 공휴일 유무 확인 함수
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