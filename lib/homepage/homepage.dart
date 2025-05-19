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
    _initialization();
  }

  void _initialization() async {
    AndroidInitializationSettings android = const AndroidInitializationSettings("@mipmap/ic_launcher");
    DarwinInitializationSettings ios = const DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );
    InitializationSettings settings = InitializationSettings(android: android, iOS: ios);
    await _local.initialize(settings);
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
            backgroundColor: const Color(0xffADB5BD),
            elevation: 10,
            shadowColor: Color(0xffB0B0B0),
          ),
        ),
      ),
      drawer: MenuDrawer(),
      body: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Calendar(), // 달력 위치
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xffADB5BD),
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