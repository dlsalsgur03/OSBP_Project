import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'reservation/transportation_popup.dart';

void main() {
  initializeDateFormatting().then((_) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'), // 한국어 지원
        Locale('en', ''),   // 영어 기본
      ],
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
      },
      selectedDayPredicate: (DateTime day) {
        return isSameDay(selectedDay, day);
      },
    );

  }
}

class SchedulePopup extends StatelessWidget {
  const SchedulePopup({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController locationController = TextEditingController();
    final TextEditingController dateController = TextEditingController();

    return AlertDialog(
      title: const Text("일정 추가"),
      content: Column(
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
            controller: dateController,
            decoration: const InputDecoration(
              labelText: "날짜 범위",
            ),
          ),
        ],
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
            print("날짜 범위: ${dateController.text}");
            Navigator.of(context).pop(); // 팝업창 닫기
          },
          child: const Text("저장"),
        ),
      ],
    );
  }
}