import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

final String scheduleFileName = 'schedule.json';
final String directoryName = 'assets/scheduler';

class Schedule {
  final String title;
  final String location;
  final String firstdate;
  final String lastdate;
  final String emoji;
  final String memo;


  Schedule({
    required this.title,
    required this.location,
    required this.firstdate,
    required this.lastdate,
    required this.emoji,
    required this.memo,
  });

  Schedule copyWith({
    String? title,
    String? location,
    String? firstdate,
    String? lastdate,
    String? emoji,
    String? memo,
  }) {
    return Schedule(
      title: title ?? this.title,
      location: location ?? this.location,
      firstdate: firstdate ?? this.firstdate,
      lastdate: lastdate ?? this.lastdate,
      emoji: emoji ?? this.emoji,
      memo: memo ?? this.memo,
    );
  }

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      title: json['title'] ?? '',
      location: json['location'] ?? '',
      firstdate: json['firstdate'] ?? '',
      lastdate: json['lastdate'] ?? '',
      emoji: json['emoji'] ?? '',
      memo: json['memo'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'location': location,
      'firstdate': firstdate,
      'lastdate': lastdate,
      'emoji': "",
      'memo' : memo,
    };
  }
}

Future<List<Schedule>> getAllSchedules() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  List<Schedule> schedules = [];
  try {
    final String? existingData = prefs.getString('schedules_storage');
    if (existingData != null) {
      final dynamic decodedData = jsonDecode(existingData);
      if (decodedData is List) {
        schedules = decodedData
            .whereType<Map<String, dynamic>>()
            .map((json) => Schedule.fromJson(json))
            .toList();
      }
    }
  } catch (e) {
    print('전체 일정 불러오기 실패: $e');
  }
  return schedules;
}
Future<void> save_schedule({
  required String title,
  required String location,
  required DateTime? firstdate,
  required DateTime? lastdate,
  required String emoji,
  required String memo,
}) async {
  try {

    final prefs = await SharedPreferences.getInstance();
    // 새로운 일정 데이터 Map 생성, 일단 전부 문자열로 읽기
    final newSchedule = {
      'title' : title,
      'location' : location,
      'firstdate' : firstdate!.toIso8601String() ?? '',
      'lastdate' : lastdate!.toIso8601String() ?? '',
      'emoji' : emoji,
      'memo' : memo,
    };

    List<Map<String, dynamic>> schedules = [];

    final existingData = prefs.getString('schedules_storage');
    if(existingData != null){
      final decoded = jsonDecode(existingData);
      if(decoded is List) {
        schedules = List<Map<String, dynamic>>.from(decoded);
      }
    }
    schedules.add(newSchedule);
    // 파일에 최종 데이터 저장 (덮어쓰기)
    await prefs.setString('schedules_storage', jsonEncode(schedules));

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
  required String memo,
}) async {
  try{
    final newSchedule = {
      'title' : title,
      'location' : location,
      'firstdate' : firstdate!.toIso8601String(),
      'lastdate' : lastdate!.toIso8601String(),
      'emoji' : emoji,
      'memo' : memo
    };

    if(kIsWeb){
        // 웹 전용 저장 로직
      final prefs = await SharedPreferences.getInstance();
      List<Map<String, dynamic>> schedules = [];

      final existingData = prefs.getString('schedules_storage');
      if(existingData != null){
        schedules = List<Map<String, dynamic>>.from(jsonDecode(existingData));
      }
      // 스케줄 추가 및 SharedPreferences 데이터베이스에 저장
      schedules.add(newSchedule);
      await prefs.setString('schedules_storage', jsonEncode(schedules));
      print("일정 저장 완료 (웹)");
      }
    else {
      save_schedule(
        title: title,
        location: location,
        firstdate: firstdate,
        lastdate: lastdate,
        emoji: emoji,
        memo: memo
      );
      }

  } catch (e) {
    print('일정 저장 실패 (웹) : $e');
  }

}

Future<void> deleteSchedule(Schedule targetSchedule) async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? existingData = prefs.getString('schedules_storage');

    if (existingData != null) {
      final List<dynamic> decoded = jsonDecode(existingData);
      final List<Map<String, dynamic>> updated = decoded
          .whereType<Map<String, dynamic>>()
          .where((json) {
        final Schedule s = Schedule.fromJson(json);
        return !(
          s.title == targetSchedule.title &&
          s.location == targetSchedule.location &&
          s.firstdate == targetSchedule.firstdate &&
          s.lastdate == targetSchedule.lastdate &&
          s.memo == targetSchedule.memo
        );
      }).toList();

      await prefs.setString('schedules_storage', jsonEncode(updated));
      print('일정 삭제 완료');
    }
  } catch (e) {
    print('일정 삭제 실패: $e');
  }
}


void read_data() async {
  final SharedPreferences pref = await SharedPreferences.getInstance();
  try{
    final String? key = pref.getString("schedules_storage");
    print(key);
  }catch(e){ }
}


Future<List<Schedule>> getSchedule(DateTime? firstdate) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  List<Schedule> schedules = [];
  try {
    final String? existingData = prefs.getString('schedules_storage');
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

  // startDate부터 endDate 까지 일정 필터링
  List<Schedule> filteredSchedules = schedules.where((event) {
    DateTime startDate = DateTime.parse(event.firstdate);
    DateTime endDate = DateTime.parse(event.lastdate);
    return firstdate!.year >= startDate.year &&
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
      print('  Memo: ${schedule.memo}');
      print('----------------');
    }
  } else {
    print('일정 필터링 완료: 해당 날짜에 일정이 없습니다.');
  }
  return filteredSchedules;
}

Future<void> updateScheduleMemo(String firstdate, String title, String newMemo) async {
  final prefs = await SharedPreferences.getInstance();
  final existingData = prefs.getString('schedules_storage');

  if (existingData == null) return;

  final List<Map<String, dynamic>> scheduleList =
  List<Map<String, dynamic>>.from(jsonDecode(existingData));

  for (var schedule in scheduleList) {
    if (schedule['firstdate'] == firstdate && schedule['title'] == title) {
      schedule['memo'] = newMemo;
      break;
    }
  }

  await prefs.setString('schedules_storage', jsonEncode(scheduleList));
}
