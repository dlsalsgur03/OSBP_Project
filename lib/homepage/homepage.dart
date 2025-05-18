import 'package:flutter/material.dart';
import '../calendar/calendar.dart';
import '../schedulePopup/schedulePopup.dart';
import '../menu/drawer.dart';
import '../menu/menu.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

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
      appBar: AppBar(
        leading: MenuButton(scaffoldKey: scaffoldKey,), // menu.dart에서 가져온 MenuButton 사용
        centerTitle: true,
        title: const Text("Miri Calendar"),
        titleTextStyle: const TextStyle(
          fontSize: 30, color: Color(0xffffffff), fontWeight: FontWeight.bold,
        ),
        backgroundColor: const Color(0xffa7385c),
        shadowColor: const Color(0xff8e2d4d),
      ),
      drawer: MenuDrawer(),
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