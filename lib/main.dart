import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'reservation/transportation_popup.dart';
import 'reservation/reading_json.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async{
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
        centerTitle: true,
        title: const Text("Miri Calendar"),
        titleTextStyle: TextStyle(
            fontSize: 30, color: Color(0xffffffff), fontWeight: FontWeight.bold
        ),
        backgroundColor: Color(0xffa7385c),
        shadowColor: Color(0xff8e2d4d),
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
    );
  }
}

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  final String apiKey = getApiKey();
  DateTime selectedDay = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  DateTime focusDay = DateTime.now();
  Map<String, String> weatherData = {};
  bool isRainyDay = false;

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
        outsideTextStyle: TextStyle(color: Colors.grey),
        isTodayHighlighted: true,
        todayDecoration: BoxDecoration(
          color: Color(0xfff5d5db),
          shape: BoxShape.circle,
          border: Border.all(color: Color(0xfff5d5db), width: 1.5),
        ),
        todayTextStyle: TextStyle(
            fontWeight: FontWeight.bold, color: Color(0xffa7385c)),
        selectedDecoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(color: Color(0xffa7385c), width: 1.5),
        ),
        selectedTextStyle: TextStyle(
            fontWeight: FontWeight.bold, color: Color(0xffa7385c)),
      ),
      calendarFormat: CalendarFormat.month,
      onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
        setState(() {
          this.selectedDay = selectedDay;
          focusDay = focusedDay;
        });
        DateTime today = DateTime.now();
        DateTime yesterday = today.subtract(Duration(days: 1));

        if (selectedDay.isBefore(yesterday)) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("알림"),
              content: Text("과거는 지원하지 않습니다."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("닫기"),
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
      showRecommendationByMonth(context, selectedDay);
    } else {
      fetchWeather(context, selectedDay);
    }
  }

  Future<void> fetchWeather(BuildContext context, DateTime day) async {
    final String weatherUrl =
        'https://api.openweathermap.org/data/2.5/forecast?q=Seoul&appid=$apiKey&units=metric';
    final String airQualityUrl =
        'https://api.openweathermap.org/data/2.5/air_pollution?lat=37.5665&lon=126.9780&appid=$apiKey';

    try {
      final weatherResponse = await http.get(Uri.parse(weatherUrl));
      final airQualityResponse = await http.get(Uri.parse(airQualityUrl));

      if (weatherResponse.statusCode == 200) {
        final weatherData = json.decode(weatherResponse.body);
        final airQualityData = json.decode(airQualityResponse.body);
        isRainyDay = false;
        String selectedDateKey = selectedDay.toIso8601String().split("T")[0];
        String todayKey = DateTime.now().toIso8601String().split("T")[0];

        double tempMin = double.infinity;
        double tempMax = double.negativeInfinity;
        String weatherDescription = "";
        int cloudCoverage = 0;

        for (var entry in weatherData['list']) {
          DateTime dateTime = DateTime.parse(entry['dt_txt']);
          String dateKey = dateTime.toIso8601String().split("T")[0];
          weatherData[dateKey] = entry['weather'][0]['main'].toLowerCase();
          if (dateKey == selectedDateKey && weatherData[dateKey]?.contains("rain") == true) {
            isRainyDay = true;
          }
          if (selectedDateKey == todayKey && !weatherData[todayKey]?.contains("rain")) {
            isRainyDay = false;
          }

          if (isSameDay(dateTime, selectedDay) && weatherData[dateKey]?.contains("rain") == true) {
            isRainyDay = true;
          }
          if (isSameDay(dateTime, day)) {
            double temp = entry['main']['temp'];
            tempMin = temp < tempMin ? temp : tempMin;
            tempMax = temp > tempMax ? temp : tempMax;
            weatherDescription = entry['weather'][0]['description'];
            cloudCoverage = entry['clouds']['all'];
          }
        }

        int airQualityIndex = airQualityData['list'][0]['main']['aqi'];
        String airQuality = getAirQualityDescription(airQualityIndex);
        String recommendation =
        getRecommendation(tempMin, tempMax, weatherDescription, cloudCoverage, airQuality);
        showWeatherDialog(context, tempMin, tempMax, airQuality, recommendation);
      } else {
        print('Failed to fetch weather');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  String getAirQualityDescription(int aqi) {
    if(aqi == 1) return "좋음";
    else if(aqi == 2) return "보통";
    else if(aqi == 3) return "약간나쁨";
    else if(aqi == 4) return "나쁨";
    else return "매우나쁨";
  }

  String getRecommendation(double tempMin, double tempMax, String weatherDescription, int cloudCoverage, String airQuality) {
    String baseRecommendation = "";

    if (weatherDescription.contains("rain")) {
      if (tempMin <= 10 && tempMax <= 15) {
        baseRecommendation = "우산, 따뜻한 외투";
      } else if (tempMin >= 9) {
        baseRecommendation = "우산, 가벼운 겉옷";
      } else if (tempMin >= 20) {
        baseRecommendation = "우산, 반팔";
      } else if (tempMax <= 10) {
        baseRecommendation = "우산, 패딩";
      } else {
        baseRecommendation = "우산";
      }
    } else {
      if (tempMin <= 10 && tempMax <= 15) {
        baseRecommendation = "따뜻한 외투";
      } else if (tempMin >= 9) {
        baseRecommendation = "가벼운 겉옷";
      } else if (tempMin >= 16) {
        baseRecommendation = "반팔, 선크림";
      } else if (tempMax <= 5) {
        baseRecommendation = "패딩";
      } else {
        baseRecommendation = "";
      }
    }

    if (cloudCoverage <= 25) {
      baseRecommendation += ", 선크림";
    }
    if (cloudCoverage < 10) {
      baseRecommendation += ", 양산";
    }
    if(airQuality != "좋음" && airQuality != "보통") {
      baseRecommendation += ", 마스크";
    }

    return baseRecommendation;
  }

  void showWeatherDialog(BuildContext context, double tempMin, double tempMax, String airQuality, String recommendation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isRainyDay ? Color(0xffd0eaff) : Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("날씨 정보"), // 원래 제목
            if (isRainyDay) const SizedBox(width: 8),
            if (isRainyDay) const Text("☔", style: TextStyle(fontSize: 24)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("최저 온도: ${tempMin.toStringAsFixed(1)}℃"),
            Text("최고 온도: ${tempMax.toStringAsFixed(1)}℃"),
            const SizedBox(height: 20),
            Text("미세먼지 상태: $airQuality"),
            const SizedBox(height: 20),
            const Text("추천 준비물"),
            Text(recommendation),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("닫기"),
          ),
        ],
      ),
    );
  }

  void showRecommendationByMonth(BuildContext context, DateTime selectedDay) {
    String recommendation = "";
    switch (selectedDay.month) {
      case 1:
      case 12:
        recommendation = "패딩";
        break;
      case 2:
      case 11:
        recommendation = "따뜻한 외투";
        break;
      case 3:
      case 10:
        recommendation = "따뜻한 외투 또는 가벼운 겉옷";
        break;
      case 4:
      case 5:
        recommendation = "가벼운 겉옷";
        break;
      case 6:
      case 7:
      case 8:
      case 9:
        recommendation = "반팔";
        break;
      default:
        recommendation = "알 수 없음";
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("추천 준비물"),
        content: Text(recommendation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("닫기"),
          ),
        ],
      ),
    );
  }
}

class Event {
  final String title;
  final String location;
  Event(this.title, this.location);

  @override
  String toString() => title;
}

Map<DateTime, List<Event>> events = {}; // 날짜별 일정 저장
class SchedulePopup extends StatelessWidget {
  SchedulePopup({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController locationController = TextEditingController();
    final TextEditingController startDateController = TextEditingController();
    final TextEditingController endDateController = TextEditingController();
    final TextEditingController memoController = TextEditingController();
    final TextEditingController emojiController = TextEditingController();

    DateTime? startDate;
    DateTime? endDate;

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
          onPressed: () {
            // 입력 데이터 처리 로직
            print("제목: ${titleController.text}");
            final String title = titleController.text;
            print("장소: ${locationController.text}");
            final String location = locationController.text;
            print("일정 시작: ${startDateController.text}");
            final String firstdate = startDateController.text;
            print("일정 종료: ${endDateController.text}");
            final String lastdate = endDateController.text;
            print("메모: ${titleController.text}");
            save_schedule_web(
              title : title,
              location : location,
              firstdate : firstdate,
              lastdate : lastdate,
              emoji: '',
            );

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
