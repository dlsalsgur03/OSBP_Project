import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

Future<List<DateTime>> fetchHolidays(int year) async {
  final apiKey = dotenv.env['HOLIDAY_API_KEY'];
  final List<DateTime> allHolidays = [];

  for (int month = 1; month <= 12; month++) {
    final url = Uri.parse(
        'http://apis.data.go.kr/B090041/openapi/service/SpcdeInfoService/getHoliDeInfo'
            '?solYear=$year&solMonth=${month.toString().padLeft(2, '0')}&ServiceKey=$apiKey&_type=json');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      print(decodedBody);
      final data = json.decode(decodedBody);
      final itemsContainer = data['response']?['body']?['items'];

      if (itemsContainer == null || itemsContainer is String) {
        // 아무 공휴일도 없는 경우 (items가 "" 빈 문자열인 경우)
        continue;
      }
      final items = itemsContainer['item'];
      if (items is List) {
        for (var item in items) {
          final dateStr = item['locdate'].toString();
          allHolidays.add(DateTime(
            int.parse(dateStr.substring(0, 4)),
            int.parse(dateStr.substring(4, 6)),
            int.parse(dateStr.substring(6, 8)),
          ));
        }
      } else if (items is Map) {
        final dateStr = items['locdate'].toString();
        allHolidays.add(DateTime(
          int.parse(dateStr.substring(0, 4)),
          int.parse(dateStr.substring(4, 6)),
          int.parse(dateStr.substring(6, 8)),
        ));
      } else {
        print('예상치 못한 item 타입: ${items.runtimeType}');
      }
    } else {
      print('[$month월] API 요청 실패: ${response.statusCode}');
    }
  }

  return allHolidays;
}

Future<void> saveHolidaysToJson(List<DateTime> holidays) async {
  if(kIsWeb) {
    final prefs = await SharedPreferences.getInstance();
    List<DateTime> holidayNew = [];

    final existingData = prefs.getString('holidays');
    if (existingData != null) {
      final List<dynamic> jsonList = jsonDecode(existingData);
      holidayNew = jsonList.map((e) => DateTime.parse(e)).toList();
    }

    final merged = {...holidayNew, ...holidays}.toList();

    final List<String> encoded = merged.map((e) => e.toIso8601String()).toList();
    await prefs.setString('holidays', jsonEncode(encoded));
  } else {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/holidays.json');

    // DateTime을 문자열로 변환해서 저장
    final List<String> holidayStrings = holidays.map((date) =>
        date.toIso8601String()).toList();
    await file.writeAsString(jsonEncode(holidayStrings));
    print(file);
  }
}

  Future<void> updateHolidays() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/holidays_last_updated.txt');
    final today = DateTime.now();
    bool shouldUpdate = true;

    if (await file.exists()) {
      final lastUpdatedStr = await file.readAsString();
      final lastUpdated = DateTime.tryParse(lastUpdatedStr);
      if (lastUpdated != null &&
          lastUpdated.day == today.day &&
          lastUpdated.month == today.month &&
          lastUpdated.year == today.year) {
        shouldUpdate = false;
      }
    }

    if (shouldUpdate) {
      final holidays = await fetchHolidays(today.year);
      await saveHolidaysToJson(holidays);
      await file.writeAsString(today.toIso8601String());
      print("공휴일 업데이트 완료");
    } else {
      print("오늘은 이미 공휴일 데이터를 갱신함");
  }
}

Future<List<DateTime>> loadSavedHolidays() async {
  if(kIsWeb) {
    final prefs = await SharedPreferences.getInstance();
    final String? key = prefs.getString('holidays');
    if (key == null) return [];
    final List<dynamic> holidayList = json.decode(key);
    return holidayList.map((s) => DateTime.parse(s)).toList();
  }
  else {
    final directory = await getApplicationDocumentsDirectory();
    final holidaysFile = File('${directory.path}/holidays.json');

    if (await holidaysFile.exists()) {
      final jsonStr = await holidaysFile.readAsString();
      final List<dynamic> holidayList = json.decode(jsonStr);
      return holidayList.map((s) => DateTime.parse(s)).toList();
    } else {
      return [];
    }
  }
}