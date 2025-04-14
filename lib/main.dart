import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';

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
      )
    );
  }
}

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {

  DateTime selectedDay = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day
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
          switch(day.weekday) {
            case 1:
              return Center(child: Text('월'),);
            case 2:
              return Center(child: Text('화'),);
            case 3:
              return Center(child: Text('수'),);
            case 4:
              return Center(child: Text('목'),);
            case 5:
              return Center(child: Text('금'),);
            case 6:
              return Center(
                child: Text('토', style: TextStyle(color: Color(0xffa7385c)),),);
            case 7:
              return Center(
                child: Text('일', style: TextStyle(color: Color(0xffa7385c)),),);
          }
        }
      ),

      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),

      calendarStyle: CalendarStyle(
        defaultTextStyle: TextStyle(color: Color(0xff000000)),
        weekendTextStyle: TextStyle(color: Color(0xffa7385c)),
        outsideDaysVisible: true,
        outsideTextStyle: TextStyle(
          color: Colors.grey
        ),
        isTodayHighlighted: false,
        todayDecoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(color: Color(0xffa7385c), width: 1.5)
        ),

        todayTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xffa7385c)
        ),

        selectedDecoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(color: Color(0xffa7385c), width: 1.5)
        ),
        selectedTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xffa7385c)
        )
      ),

      calendarFormat: CalendarFormat.month,
      onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
        setState(() {
          this.selectedDay=selectedDay;
          focusDay=focusedDay;
        });
      },
      selectedDayPredicate: (DateTime day) {
        return isSameDay(selectedDay, day);
      },
    );
  }
}


