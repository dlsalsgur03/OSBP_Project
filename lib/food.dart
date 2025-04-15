import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String apiKey = '2bb7d1d04a4a7cd6b226ce87c31a0ece';

void main() {
  initializeDateFormatting().then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Calendar(),
            IconButton(
              padding: EdgeInsets.all(0.0),
              color: Color(0xffa7385c),
              icon: Icon(Icons.add_circle_rounded, size: 50.0),
              onPressed: () {},
            )
          ],
        ),
      ),
    );
  }
}

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  DateTime selectedDay = DateTime.now();
  DateTime focusDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      focusedDay: focusDay,
      firstDay: DateTime(2025, 1, 1),
      lastDay: DateTime(2025, 12, 31),
      locale: 'ko-KR',
      headerStyle: HeaderStyle(formatButtonVisible: false, titleCentered: true),
      calendarFormat: CalendarFormat.month,
      onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
        setState(() {
          this.selectedDay = selectedDay;
          focusDay = focusedDay;
        });
        fetchWeatherOrRecommendation(context, selectedDay);
      },
      selectedDayPredicate: (DateTime day) {
        return isSameDay(selectedDay, day);
      },
    );
  }

  void fetchWeatherOrRecommendation(BuildContext context, DateTime selectedDay) {
    // 날짜 차이에 따라 다르게 처리
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

        for (var entry in data['list']) {
          DateTime dateTime = DateTime.parse(entry['dt_txt']);
          if (isSameDay(dateTime, day)) {
            double temp = entry['main']['temp'];
            tempMin = temp < tempMin ? temp : tempMin;
            tempMax = temp > tempMax ? temp : tempMax;
            weatherDescription = entry['weather'][0]['description'];
          }
        }

        String recommendation =
        getRecommendation(tempMin, tempMax, weatherDescription);
        showWeatherDialog(context, tempMin, tempMax, recommendation);
      } else {
        print('Failed to fetch weather');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void showWeatherDialog(BuildContext context, double tempMin, double tempMax,
      String recommendation) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.4,
          height: MediaQuery.of(context).size.height * 0.3,
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("날씨 정보",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(height: 10),
              Text("최저 온도: ${tempMin.toStringAsFixed(1)}℃"),
              Text("최고 온도: ${tempMax.toStringAsFixed(1)}℃"),
              SizedBox(height: 20),
              Text("추천 준비물",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(height: 10),
              Text(recommendation, textAlign: TextAlign.center),
              SizedBox(height: 20),
              TextButton(
                  onPressed: () => Navigator.pop(context), child: Text("닫기"))
            ],
          ),
        ),
      ),
    );
  }

  String getRecommendation(
      double tempMin, double tempMax, String weatherDescription) {
    if (weatherDescription.contains("rain")) {
      if (tempMin <= 10 && tempMax <= 15) {
        return "우산, 따뜻한 외투";
      } else if (tempMin >= 9) {
        return "우산, 가벼운 겉옷";
      } else if (tempMin >= 20) {
        return "우산, 반팔";
      } else if (tempMax <= 10) {
        return "우산, 패딩";
      } else {
        return "우산";
      }
    } else {
      if (tempMin <= 10 && tempMax <= 15) {
        return "따뜻한 외투";
      } else if (tempMin >= 9) {
        return "가벼운 겉옷";
      } else if (tempMin >= 20) {
        return "반팔, 선크림";
      } else if (tempMax <= 10) {
        return "패딩";
      } else {
        return "";
      }
    }
  }

  void showRecommendationByMonth(BuildContext context, DateTime selectedDay) {
    String message =
        "현재 내 날짜 기준으로 5일 뒤의 정보는 가까운 날짜가 아니라 정보를 자세히 표시해 드릴 수 없습니다.";
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
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("날짜 정보",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(height: 10),
              Text(message),
              SizedBox(height: 20),
              Text("추천 준비물",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(height: 10),
              Text(recommendation, textAlign: TextAlign.center),
              SizedBox(height: 20),
              TextButton(
                  onPressed: () => Navigator.pop(context), child: Text("닫기"))
            ],
          ),
        ),
      ),
    );
  }
}