import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'reservation/transportation_popup.dart';
import 'reservation/readtocsv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// API 키 정의
const String apiKey = '2bb7d1d04a4a7cd6b226ce87c31a0ece';

void main() {
  initializeDateFormatting().then((_) => runApp(const MyApp()));
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
        title: const Text("캘린더 앱"),
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
              return const SchedulePopup();
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
        outsideTextStyle: TextStyle(color: Colors.grey),
        isTodayHighlighted: false,
        todayDecoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(color: Color(0xffa7385c), width: 1.5),
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

        if (selectedDay.isBefore(DateTime.now())) {
          showDialog(
            context: context,
            builder: (context) => const AlertDialog(
              title: Text("알림"),
              content: Text("과거입니다"),
              actions: [
                TextButton(
                  onPressed: null,
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
    final String url =
        'https://api.openweathermap.org/data/2.5/forecast?q=Seoul&appid=$apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        double tempMin = double.infinity;
        double tempMax = double.negativeInfinity;
        String weatherDescription = "";
        int cloudCoverage = 0;

        for (var entry in data['list']) {
          DateTime dateTime = DateTime.parse(entry['dt_txt']);
          if (isSameDay(dateTime, day)) {
            double temp = entry['main']['temp'];
            tempMin = temp < tempMin ? temp : tempMin;
            tempMax = temp > tempMax ? temp : tempMax;
            weatherDescription = entry['weather'][0]['description'];
            cloudCoverage = entry['clouds']['all'];
          }
        }

        String recommendation =
        getRecommendation(tempMin, tempMax, weatherDescription, cloudCoverage);
        showWeatherDialog(context, tempMin, tempMax, recommendation);
      } else {
        print('Failed to fetch weather');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  String getRecommendation(
      double tempMin, double tempMax, String weatherDescription, int cloudCoverage) {
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
      } else if (tempMin >= 20) {
        baseRecommendation = "반팔, 선크림";
      } else if (tempMax <= 10) {
        baseRecommendation = "패딩";
      } else {
        baseRecommendation = "";
      }
    }

    if (cloudCoverage <= 25) {
      baseRecommendation += ", 선크림";
    }

    return baseRecommendation;
  }

  void showWeatherDialog(BuildContext context, double tempMin, double tempMax,
      String recommendation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("날씨 정보"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("최저 온도: ${tempMin.toStringAsFixed(1)}℃"),
            Text("최고 온도: ${tempMax.toStringAsFixed(1)}℃"),
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

class SchedulePopup extends StatelessWidget {
  const SchedulePopup({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController locationController = TextEditingController();
    final TextEditingController startDateController = TextEditingController();
    final TextEditingController endDateController = TextEditingController();
    final TextEditingController memoController = TextEditingController();

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
                  String formattedDate = "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                  startDateController.text = formattedDate;
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
                  String formattedDate = "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                  endDateController.text = formattedDate;
                }
              },
            ),
            TextField(
              controller: memoController,
              decoration: const InputDecoration(
                labelText: "메모",
              ),
            ),
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
            print("장소: ${locationController.text}");
            print("일정 시작: ${startDateController.text}");
            print("일정 종료: ${endDateController.text}");
            print("메모: ${titleController.text}");
            Navigator.of(context).pop(); // 팝업창 닫기
            showBookingOptions(context);
          },
          child: const Text("다음"),
        ),
      ],
    );
  }
}