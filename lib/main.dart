import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'reservation/transportation_popup.dart';
import 'reservation/reading_json.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'weather/weather.dart'; // weather.dart 파일 추가

void main() async {
  await dotenv.load();
  initializeDateFormatting().then((_) => runApp(const MyApp()));
}

String getApiKey() {
  return dotenv.env['MY_API_KEY'] ?? "";
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'), // 한국어 지원
        Locale('en', ''),   // 영어 기본
      ],
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu), // 햄버거 메뉴 아이콘으로 변경
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return const SettingsPopup();
              },
            );
          },
        ),
        centerTitle: true,
        title: const Text("Miri Calendar"),
        titleTextStyle: const TextStyle(
          fontSize: 30, color: Color(0xffffffff), fontWeight: FontWeight.bold,
        ),
        backgroundColor: const Color(0xffa7385c),
        shadowColor: const Color(0xff8e2d4d),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Calendar(), // 달력 위치
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 팝업창 호출
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return SchedulePopup();
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  final WeatherService weatherService = WeatherService(); // weather.dart 연동
  DateTime selectedDay = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  DateTime focusDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      focusedDay: focusDay,
      firstDay: DateTime(2025, 1, 1),
      lastDay: DateTime(2025, 12, 31),
      locale: 'ko-KR',
      daysOfWeekHeight: 30,
      calendarBuilders: CalendarBuilders(
        dowBuilder: (context, day) {
          switch (day.weekday) {
            case 1:
              return const Center(child: Text('월'));
            case 2:
              return const Center(child: Text('화'));
            case 3:
              return const Center(child: Text('수'));
            case 4:
              return const Center(child: Text('목'));
            case 5:
              return const Center(child: Text('금'));
            case 6:
              return const Center(
                child: Text('토', style: TextStyle(color: Color(0xffa7385c))),
              );
            case 7:
              return const Center(
                child: Text('일', style: TextStyle(color: Color(0xffa7385c))),
              );
          }
          return const Center();
        },
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
      calendarStyle: CalendarStyle(
        defaultTextStyle: const TextStyle(color: Color(0xff000000)),
        weekendTextStyle: const TextStyle(color: Color(0xffa7385c)),
        outsideDaysVisible: true,
        outsideTextStyle: const TextStyle(color: Colors.grey),
        isTodayHighlighted: true,
        todayDecoration: BoxDecoration(
          color: Color(0xfff5d5db),
          shape: BoxShape.circle,
          border: Border.all(color: Color(0xfff5d5db), width: 1.5),
        ),
        todayTextStyle: const TextStyle(
            fontWeight: FontWeight.bold, color: Color(0xffa7385c)),
        selectedDecoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(color: Color(0xffa7385c), width: 1.5),
        ),
        selectedTextStyle: const TextStyle(
            fontWeight: FontWeight.bold, color: Color(0xffa7385c)),
      ),
      calendarFormat: CalendarFormat.month,
      onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
        setState(() {
          this.selectedDay = selectedDay;
          focusDay = focusedDay;
        });

        DateTime today = DateTime.now();
        DateTime yesterday = today.subtract(const Duration(days: 1));

        if (selectedDay.isBefore(yesterday)) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("알림"),
              content: const Text("과거는 지원하지 않습니다."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("닫기"),
                ),
              ],
            ),
          );
        } else {
          fetchWeatherOrRecommendation(context, selectedDay);
        }
      },
      selectedDayPredicate: (DateTime day) {
        return isSameDay(selectedDay, day);
      },
    );
  }

  void fetchWeatherOrRecommendation(BuildContext context, DateTime selectedDay) {
    if (selectedDay.difference(DateTime.now()).inDays > 4) {
      weatherService.showRecommendationByMonth(context, selectedDay);
    } else {
      weatherService.fetchWeather(context, selectedDay);
    }
  }
}

class SettingsPopup extends StatefulWidget {
  const SettingsPopup({super.key});

  @override
  _SettingsPopupState createState() => _SettingsPopupState();
}

class _SettingsPopupState extends State<SettingsPopup> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.2,
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: Text(
                "설정",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const Divider(thickness: 2.0),
            ListTile(
              title: const Center(
                child: Text(
                  "개발자",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const DeveloperInfoPopup();
                  },
                );
              },
            ),
            const Divider(thickness: 2.0),
            ListTile(
              title: const Center(
                child: Text(
                  "알림",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const NotificationSettingsPopup();
                  },
                );
              },
            ),
            const Divider(thickness: 2.0),
            ListTile(
              title: const Center(
                child: Text(
                  "오류 신고",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("오류 신고"),
                      content: const Text(
                        "juwankim03@gmail.com\n문의 시 빠른 시일 내에 답변 드리겠습니다.",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "닫기",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const Divider(thickness: 2.0),
            ListTile(
              title: const Center(
                child: Text(
                  "공지사항",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("공지사항"),
                      content: const Text(
                        "공지사항이 없습니다.",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "닫기",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const Divider(thickness: 2.0),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "닫기",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DeveloperInfoPopup extends StatelessWidget {
  const DeveloperInfoPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("민혁의 카피바라들"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text("인민혁"),
          Text("김주완"),
          Text("김윤태"),
          Text("박민석"),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("닫기"),
        ),
      ],
    );
  }
}

class NotificationSettingsPopup extends StatefulWidget {
  const NotificationSettingsPopup({super.key});

  @override
  _NotificationSettingsPopupState createState() =>
      _NotificationSettingsPopupState();
}

class _NotificationSettingsPopupState extends State<NotificationSettingsPopup> {
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("알림 설정"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CheckboxListTile(
            title: const Text("더 이상 알림을 받지 않음"),
            value: !notificationsEnabled,
            onChanged: (bool? value) {
              setState(() {
                notificationsEnabled = !(value ?? true);
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            "닫기",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class SchedulePopup extends StatefulWidget {
  const SchedulePopup({super.key});

  @override
  State<SchedulePopup> createState() => _SchedulePopupState();
}
class _SchedulePopupState extends State<SchedulePopup> {
  DateTime? startDate;
  DateTime? endDate;

  @override
  Widget build(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController locationController = TextEditingController();
    final TextEditingController startDateController = TextEditingController();
    final TextEditingController endDateController = TextEditingController();
    final TextEditingController memoController = TextEditingController();
    final TextEditingController emojiController = TextEditingController();

    return AlertDialog(
      title: const Text("일정 추가"),
      content: SizedBox(
        width: 300,
        height: 350,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "일정 제목",
              ),
            ),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: "장소",
              ),
            ),
            TextField(
              controller: startDateController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "일정 시작",
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () async{
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if(pickedDate != null){
                  startDate = pickedDate; //선택한 날짜를 Datetime 변수로 저장
                  startDateController.text = "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                }
              },
            ),
            TextField(
              controller: endDateController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "일정 종료",
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () async{
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if(pickedDate != null){
                  endDate = pickedDate; //선택한 날짜를 Datetime 변수로 저장
                  endDateController.text = "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                }
              },
            ),
            TextField(
              controller: memoController,
              decoration: const InputDecoration(
                labelText: "메모",
              ),
            ),
            Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: emojiController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: "이모티콘",
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.emoji_emotions),
                    onPressed: () {
                      _showEmojiPicker(context, emojiController);
                    },
                  )
                ]
            )
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // 팝업창 닫기
          },
          child: const Text("취소"),
        ),
        TextButton(
          onPressed: () async {
            // 입력 데이터 처리 로직
            //print("제목: ${titleController.text}");
            final String title = titleController.text;
            print("장소: ${locationController.text}");
            final String location = locationController.text;
            print("일정 시작: ${startDateController.text}");
            final String firstdate = startDateController.text;
            print("일정 종료: ${endDateController.text}");
            final String lastdate = endDateController.text;
            print("메모: ${titleController.text}");

            await save_schedule_web(
              title : title,
              location : location,
              firstdate : firstdate,
              lastdate : lastdate,
              emoji: '',
            );
            read_data();

            Navigator.of(context).pop(); // 팝업창 닫기
            showBookingOptions(context);
          },
          child: const Text("다음"),
        ),
      ],
    );
  }
  void _showEmojiPicker(BuildContext context, TextEditingController controller) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return GridView.count(
          crossAxisCount: 5,
          padding: const EdgeInsets.all(8.0),
          children: List.generate(emojiList.length, (index) {
            return IconButton(
              onPressed: () {
                controller.text = emojiList[index];
                Navigator.pop(context);
              },
              icon: Text(emojiList[index], style: const TextStyle(fontSize: 24)),
            );
          }),
        );
      },
    );
  }

  final List<String> emojiList = ["🌟"]; // 이모티콘란. 향후 더 추가 예정
}