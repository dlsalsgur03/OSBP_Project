import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

const int searchRadius = 50000; // 50km 반경

Future<Map<String, dynamic>> findNearestStation(double x, double y) async {
  final busResults = await searchKakaoPlaces('버스 터미널', x, y);
  final trainResults = await searchKakaoPlaces('기차역', x, y);

  // 두 리스트를 합치고 거리 기준으로 정렬
  final allPlaces = [...busResults, ...trainResults];
  allPlaces.sort((a, b) => int.parse(a['distance']).compareTo(int.parse(b['distance'])));

  // 가장 가까운 결과 리턴
  return allPlaces.isNotEmpty ? allPlaces.first : {};
}

Future<List<Map<String, dynamic>>> searchKakaoPlaces(String query, double x, double y) async {
  var apiKey = dotenv.env['KAKAO_API_KEY'];
  final url = Uri.parse('https://dapi.kakao.com/v2/local/search/keyword.json?query=$query&x=$x&y=$y&radius=$searchRadius&sort=distance'
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
