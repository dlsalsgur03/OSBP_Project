import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;

// Flask 서버 URL 가져오기
String getFlaskBaseUrl() {
  if(kIsWeb) {
    return 'http://localhost:5000';
  }
  else if(Platform. isAndroid) {
    return 'http://10.0.2.2:5000';
  }
  else {
    return 'http://localhost:5000';
  }
}

// 입력된 문자열 MongoDB에 저장
Future<void> saveTextToMongoDB({
      required String title,
      required String location,
      required String firstdate,
      required String lastdate,
      required String emoji,
    }) async {
  final newSchedule = {
    'title' : title,
    'place' : location,
    'startdate' : firstdate,
    'enddate' : lastdate,
    'emoji' : emoji,
  };
  if (newSchedule.isEmpty) {
    print("저장할 내용이 없습니다.");
    return;
  }

  final String baseUrl = getFlaskBaseUrl();
  final url = Uri.parse('$baseUrl/save-text'); // Flask API 엔드포인트

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(newSchedule),
    );
  } catch (e) {
    print('MongoDB 저장 중 네트워크 또는 기타 오류: $e');

    throw Exception('Error saving text: $e');
  }
}
