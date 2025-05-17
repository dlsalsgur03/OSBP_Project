import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../weather/weather.dart';

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