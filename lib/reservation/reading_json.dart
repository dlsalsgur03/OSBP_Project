import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final String scheduleFileName = 'schedule.json';
final String directoryName = 'assets/scheduler';

class Schedule {
  final String title;
  final String location;
  final String firstdate;
  final String lastdate;
  final String emoji;


  Schedule({
    required this.title,
    required this.location,
    required this.firstdate,
    required this.lastdate,
    required this.emoji,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      title: json['title'] ?? '',
      location: json['location'] ?? '',
      firstdate: json['firstdate'] ?? '',
      lastdate: json['lastdate'] ?? '',
      emoji: json['emoji'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'location': location,
      'firstdate': firstdate,
      'lastdate': lastdate,
      'emoji': "",
    };
  }
}

Future<void> save_schedule({
  required String title,
  required String location,
  required DateTime? firstdate,
  required DateTime? lastdate,
  required String emoji,
}) async {
  try {

    final prefs = await SharedPreferences.getInstance();
    // 새로운 일정 데이터 Map 생성, 일단 전부 문자열로 읽기
    final newSchedule = {
      'title' : title,
      'location' : location,
      'firstdate' : firstdate!.toIso8601String(),
      'lastdate' : lastdate!.toIso8601String(),
      'emoji' : emoji,
    };

    List<Map<String, dynamic>> schedules = [];

    final existingData = prefs.getString('schedules_storage');
    if(existingData != null){
      schedules = List<Map<String, dynamic>>.from(jsonDecode(existingData));
    }

    schedules.add(newSchedule);
    await prefs.setString('schedules_web_storage', jsonEncode(schedules));
    print("일정 저장 완료 (웹)");
    // 기존 리스트에 새로운 일정 추가
    schedules.add(newSchedule);

    // 업데이트된 전체 리스트 JSON 문자열로 인코딩
    final encoder = JsonEncoder.withIndent('  ');
    final updatedJsonData = encoder.convert(schedules);

    // 파일에 최종 데이터 저장 (덮어쓰기)
    await prefs.setString('schedules_storage', jsonEncode(updatedJsonData));

  } catch (e) {
    // 파일 시스템 오류 등 예외 처리
    print('일정 저장 실패: $e');
  }
}

Future<void> save_schedule_web({
  required String title,
  required String location,
  required DateTime? firstdate,
  required DateTime? lastdate,
  required String emoji,
}) async {
  try{
    final newSchedule = {
      'title' : title,
      'location' : location,
      'firstdate' : firstdate!.toIso8601String(),
      'lastdate' : lastdate!.toIso8601String(),
      'emoji' : emoji,
    };

    if(kIsWeb){
        // 웹 전용 저장 로직
      final prefs = await SharedPreferences.getInstance();
      List<Map<String, dynamic>> schedules = [];

      final existingData = prefs.getString('schedules_web_storage');
      if(existingData != null){
        schedules = List<Map<String, dynamic>>.from(jsonDecode(existingData));
      }

      schedules.add(newSchedule);
      await prefs.setString('schedules_web_storage', jsonEncode(schedules));
      print("일정 저장 완료 (웹)");

      }
    else {
        save_schedule(
            title: title,
            location: location,
            firstdate: firstdate,
            lastdate: lastdate,
            emoji: emoji);
      }

  } catch (e) {
    print('일정 저장 실패 : $e');
  }

}

void read_data() async {
  final SharedPreferences pref = await SharedPreferences.getInstance();
  try{
    final String? key = pref.getString("schedules_web_storage");
    print(key);
  }catch(e){}
}


Future<List<Schedule>> getSchedule(DateTime? firstdate) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String firstdata = firstdate!.toIso8601String();
  List<Schedule> schedules = [];
  try {
    final String? existingData = prefs.getString('schedules_web_storage');
    // JSON형 문자열 파싱
    if(existingData != null) {
      final dynamic decodedData = jsonDecode(existingData);
      // 디코딩된 데이터가 리스트 형태인지 확인, 리스트로 변환
      if (decodedData is List) {
        print('data 파싱중...');
        schedules = decodedData.whereType<Map<String, dynamic>>().map((json) => Schedule.fromJson(json)).toList();
      }
    }
  }catch(e) {
    print('데이터 읽기 실패: $e');
    schedules=[];
  }

  // firstdate에 따라 일정 필터링
  List<Schedule> filteredSchedules = schedules.where((event) {
    DateTime startDate = DateTime.parse(event.firstdate);
    DateTime endDate = DateTime.parse(event.lastdate);
    return firstdate.year >= startDate.year &&
           firstdate.month >= startDate.month &&
           firstdate.day >= startDate.day &&
           firstdate.year <= endDate.year &&
           firstdate.month <= endDate.month &&
           firstdate.day <= endDate.day;
  }).toList();

  if (filteredSchedules.isNotEmpty) {
    print('일정 필터링 완료. 찾은 일정 개수: ${filteredSchedules.length}');
    for (Schedule schedule in filteredSchedules) {
      print('--- Schedule ---');
      print('  Title: ${filteredSchedules.first.title}');
      print('  Location: ${schedule.location}');
      print('  First Date: ${schedule.firstdate}');
      print('  Last Date: ${schedule.lastdate}');
      print('  Emoji: ${schedule.emoji}');
      print('----------------');
    }
  } else {
    print('일정 필터링 완료: 해당 날짜에 일정이 없습니다.');
  }
  return filteredSchedules;
}

