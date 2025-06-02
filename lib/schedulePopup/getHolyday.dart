import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<List<DateTime>> fetchHolidays(int year) async {
  final HolidayKey = dotenv.env['HOLIDAY_API_KEY'];
  final url = Uri.parse('http://apis.data.go.kr/B090041/openapi/service/SpcdeInfoService/getHoliDeInfo?solYear=$year&ServiceKey=$HolidayKey&_type=json');

  final response = await http.get(url);
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final items = data['response']['body']['items']['item'] as List<dynamic>;
    return items.map((item) {
      final dateStr = item['locdate'].toString(); // e.g. "20250505"
      return DateTime.parse(dateStr);
    }).toList();
  } else {
    throw Exception('공휴일 데이터를 불러오는 데 실패했습니다');
  }
}