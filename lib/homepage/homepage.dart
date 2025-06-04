import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../calendar/calendar.dart';
import '../schedulePopup/schedulePopup.dart';
import '../menu/drawer.dart';
import '../menu/menu.dart';
import '../calendar/dateInfo/under_calendar_info.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScheduleListWidgetState> _scheduleKey = GlobalKey<ScheduleListWidgetState>();
  final GlobalKey<CalendarState> _calendarKey = GlobalKey<CalendarState>();
  Color _selectedColor = const Color(0xffADB5BD);
  Color _markerColor = const Color(0xFF800020);
  bool _highlightWeekend = true;

  void _changeMarkerColor(Color newColor) {
    setState(() {
      _markerColor = newColor;
    });
  }
  void _toggleHighlightWeekend(bool value) {
    setState(() {
      _highlightWeekend = value;
    });
  }

  // selectedDate를 hompage.dart에서 관리하기 위한 것
  DateTime _selectedDate = DateTime.now();
  void _handleDateChanged(DateTime newDate){
    setState(() {
      _selectedDate = newDate;
    });
  }
  void _changeColor(Color newColor) {
    setState(() {
      _selectedColor = newColor;
    });
  }
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestNotificationPermission();
    });
  }

  void _requestNotificationPermission() async {
    if (await Permission.notification.isDenied &&
        !await Permission.notification.isPermanentlyDenied) {
      await [Permission.notification].request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          child: AppBar(
            leading: MenuButton(scaffoldKey: scaffoldKey,),
            centerTitle: true,
            title: const Text("Miri Calendar"),
            titleTextStyle: const TextStyle(
              fontSize: 30, color: Color(0xff212529), fontWeight: FontWeight.bold,
            ),
            backgroundColor:_selectedColor,
            elevation: 10,
            shadowColor: Color(0xffB0B0B0),
          ),
        ),
      ),
      drawer: MenuDrawer(
        onColorChanged: _changeColor,
        highlightWeekend: _highlightWeekend,
        onWeekendToggle: _toggleHighlightWeekend,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Calendar(
              key: _calendarKey,
              selectedDate: _selectedDate,
              onDaySelected: _handleDateChanged,
              markerColor: _markerColor,
              highlightWeekend: _highlightWeekend,
            ), // 달력 위치
            Padding(  // 달력과 일정 사이에 날짜 출력
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR').format(_selectedDate),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              child: ScheduleListWidget(
                key: _scheduleKey,
                selectedDate: _selectedDate,
                onScheduleChanged: () {
                  _scheduleKey.currentState?.refresh();
                  _calendarKey.currentState?.loadScheduledDates();
                },
                onColorChanged: _changeMarkerColor,
            ),)
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _selectedColor,
        onPressed: () async {
          final didAdd = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return SchedulePopup();
            },
          );

          if (didAdd == true) {
            _scheduleKey.currentState?.refresh();
            _calendarKey.currentState?.loadScheduledDates();
          }
        },
        child: const Icon(Icons.add),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}