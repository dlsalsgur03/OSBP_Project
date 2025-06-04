import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

const int searchRadius = 10000; // 10km 반경

Future<List<Map<String, dynamic>>> searchKakaoPlaces(String query, double x, double y) async {
  var apiKey = dotenv.env['KAKAO_API_KEY'];
  final url = Uri.parse(
      'https://dapi.kakao.com/v2/local/search/keyword.json'
          '?query=$query&x=$x&y=$y&radius=$searchRadius&sort=distance'
  );

  final response = await http.get(url, headers: {
    'Authorization': 'KakaoAK $apiKey',
  });

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final List documents = data['documents'];
    return documents.cast<Map<String, dynamic>>();
  } else {
    throw Exception('카카오 API 요청 실패: ${response.statusCode}');
  }
}
