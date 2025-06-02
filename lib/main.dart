import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'schedulePopup/notification.dart';
import 'dart:async';
import 'homepage/homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");
  await initializeNotifications();
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
        Locale('ko', 'KR'),
        Locale('en', ''),
      ],
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    // 1.5초 후 서서히 글자가 사라지도록 설정
    Future.delayed(const Duration(milliseconds: 1500), () {
      setState(() {
        _opacity = 0.0;
      });

      // 글자가 완전히 사라진 후 메인 화면으로 이동
      Future.delayed(const Duration(milliseconds: 1000), () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 1100), // 1.1초 동안 페이드아웃
          opacity: _opacity,
          child: const Text(
            "Miri Calendar",
            style: TextStyle(
              fontSize: 50,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}