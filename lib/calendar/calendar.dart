import 'package:OBSP_Project/calendar/dateInfo/show_date_info.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../weather/weather.dart';
import '../reservation/reading_json.dart';
class Calendar extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDaySelected;
  final Color markerColor;

  const Calendar({
    super.key,
    required this.selectedDate,
    required this.onDaySelected,
    this.markerColor = const Color(0xffa7385c),
  });

  @override
  State<Calendar> createState() => CalendarState();
}

class CalendarState extends State<Calendar> {
  final WeatherService weatherService = WeatherService(); // weather.dart 연동

  Set<DateTime> scheduledDates = {};
  Set<String> scheduledDateStrings = {};

  @override
  void initState() {
    super.initState();
    loadScheduledDates(); // 앱 시작할 때 저장된 일정 날짜 로딩
  }
  Map<String, int> scheduledDateCounts = {};

  Future<void> loadScheduledDates() async {
    List<Schedule> allSchedules = await getAllSchedules();
    Set<DateTime> dates = {};
    Set<String> dateStrings = {};
    Map<String, int> dateCounts = {};

    for (var schedule in allSchedules) {
      //string 타입으로 되어있는 startdate,enddate 부분을 Datetime으로 변환하는 코드입니다.
      DateTime startDate = DateTime.parse(schedule.firstdate);
      DateTime endDate = DateTime.parse(schedule.lastdate);

      DateTime currentDate = startDate;
      while (!currentDate.isAfter(endDate)) {
        final dateKey = _dateKey(currentDate);
        dateCounts[dateKey] = (dateCounts[dateKey] ?? 0) + 1;
        dateStrings.add(dateKey);
        currentDate = currentDate.add(const Duration(days: 1));
      }
    }
    setState(() {
      scheduledDates = dates;
      scheduledDateStrings = dateStrings;
      scheduledDateCounts = dateCounts;
      scheduledDateStrings = dateStrings;
    });
  }
  String _dateKey(DateTime date) => "${date.year}-${date.month}-${date.day}";

  DateTime selectedDay = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  DateTime focusDay = DateTime.now();

  // 더블 탭 bottomSheetModal을 위한 변수 선언
  DateTime? _lastTappedDay;
  DateTime? _lastTappedTime;
  final Duration doubleTapThreshold = Duration(milliseconds: 500);

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
          final dateKey = _dateKey(normalizedDate);
          if (!scheduledDateStrings.contains(dateKey)) {
            return null;
          }
          final count = scheduledDateCounts[dateKey]!;
          final prevDateKey = _dateKey(normalizedDate.subtract(Duration(days: 1)));
          final nextDateKey = _dateKey(normalizedDate.add(Duration(days: 1)));

          final hasPrev = scheduledDateCounts.containsKey(prevDateKey);
          final hasNext = scheduledDateCounts.containsKey(nextDateKey);

          return Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(count, (index) {
                return Container(
                  margin: EdgeInsets.only(
                    top: 1.0,
                    left: hasPrev ? 0 : 8,
                    right: hasNext ? 0 : 8,
                  ),
                  height: 2,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: widget.markerColor,
                    borderRadius: BorderRadius.horizontal(
                      left: hasPrev ? Radius.zero : Radius.circular(3),
                      right: hasNext ? Radius.zero : Radius.circular(3),
                    ),
                  ),
                );
              }),
            ),
          );
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
      onDaySelected: (DateTime tappedDay, DateTime newFocusedDay) {
        final now = DateTime.now();
        setState(() {
          focusDay = newFocusedDay;
          final isReTapOnSelected = isSameDay(tappedDay, selectedDay);
          selectedDay = tappedDay;

          if (isReTapOnSelected){
            showBottomSheetModal(context, tappedDay);
          } else if(_lastTappedDay != null && isSameDay(_lastTappedDay, tappedDay) && _lastTappedTime != null && now.difference(_lastTappedTime!) < doubleTapThreshold){
            showBottomSheetModal(context, tappedDay);
            _lastTappedDay = null;
            _lastTappedTime = null;
          } else{
            _lastTappedDay = tappedDay;
            _lastTappedTime = now;
          }
        });
        widget.onDaySelected(selectedDay);
      },
      selectedDayPredicate: (DateTime day) {
        return isSameDay(selectedDay, day);
      },
    );
  }
}