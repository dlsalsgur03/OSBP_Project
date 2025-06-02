import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<List<DateTime>> fetchHolidays(int year) async {
  final apiKey = dotenv.env['HOLIDAY_API_KEY'];
  final List<DateTime> allHolidays = [];

  for (int month = 1; month <= 12; month++) {
    final url = Uri.parse(
        'http://apis.data.go.kr/B090041/openapi/service/SpcdeInfoService/getHoliDeInfo?solYear=$year&solMonth=${month.toString().padLeft(2, '0')}&ServiceKey=$apiKey&_type=json');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final items = data['response']['body']['items']['item'];

      if (items != null) {
        // items가 List일 수도, Map일 수도 있음
        if (items is List) {
          allHolidays.addAll(items.map((item) {
            final dateStr = item['locdate'].toString(); // e.g. "20250505"
            return DateTime.parse(dateStr);
          }));
        } else if (items is Map) {
          final dateStr = items['locdate'].toString();
          allHolidays.add(DateTime.parse(dateStr));
        }
      }
    } else {
      throw Exception('[$month월] 공휴일 데이터를 불러오는 데 실패했습니다');
    }
  }

  return allHolidays;
}

Future<void> saveHolidaysToJson(List<DateTime> holidays) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/holidays.json');

  // DateTime을 문자열로 변환해서 저장
  final List<String> holidayStrings = holidays.map((date) => date.toIso8601String()).toList();
  await file.writeAsString(jsonEncode(holidayStrings));
  print(file);
}


