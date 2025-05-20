import 'package:OBSP_Project/calendar/dateInfo/show_date_info.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../reservation/reading_json.dart';

import '../weather/weather.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  void initState() {
    super.initState();
    loadScheduledDates(); // 앱 시작 시 일정 날짜 로딩
  }

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  final WeatherService weatherService = WeatherService(); // weather.dart 연동
  Set<DateTime> scheduledDates = {};

  @override
  void initState() {
    super.initState();
    loadScheduledDates(); // 앱 시작할 때 저장된 일정 날짜 로딩
  }

  Future<void> loadScheduledDates() async {
    List<Schedule> allSchedules = await getAllSchedules();
    Set<DateTime> dates = {};
    for (var schedule in allSchedules) {
      DateTime date = DateTime.parse(schedule.date);
      dates.add(DateTime(date.year, date.month, date.day));
    }
    setState(() {
      scheduledDates = dates;
    });
  }

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
                child: Text('토', style: TextStyle(color: Color(0xffB0B0B0))),
              );
            case 7:
              return const Center(
                child: Text('일', style: TextStyle(color: Color(0xffB0B0B0))),
              );
          }
          return const Center();
        },
        markerBuilder: (context, date, events) {
          final normalizedDate = DateTime(date.year, date.month, date.day);
          if (scheduledDates.contains(normalizedDate)) {
            return Positioned(
              bottom: 1,
              child: Container(
                width: 30,
                height: 2,
                color: Color(0xffa7385c), // 밑줄 색상
              ),
            );
          }
          return null;
        },
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
      calendarStyle: CalendarStyle(
        defaultTextStyle: const TextStyle(color: Color(0xff2D2D2D)),
        weekendTextStyle: const TextStyle(color: Color(0xffB0B0B0)),
        outsideDaysVisible: true,
        outsideTextStyle: const TextStyle(color: Color(0xff5C5C5C)),
        isTodayHighlighted: true,
        todayDecoration: BoxDecoration(
          color: Color(0xffF2F2F2),
          shape: BoxShape.circle,
          border: Border.all(color: Color(0xffF2F2F2), width: 1.5),
        ),
        todayTextStyle: const TextStyle(
            fontWeight: FontWeight.bold, color: Color(0xff2D2D2D)),
        selectedDecoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(color: Color(0xffB0B0B0), width: 1.5),
        ),
        selectedTextStyle: const TextStyle(
            fontWeight: FontWeight.bold, color: Color(0xff2D2D2D)),
      ),
      calendarFormat: CalendarFormat.month,
      onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
        setState(() {
          this.selectedDay = selectedDay;
          focusDay = focusedDay;
        });

        showBottomSheetModal(context, selectedDay);
      },
      selectedDayPredicate: (DateTime day) {
        return isSameDay(selectedDay, day);
      },
    );
  }
}