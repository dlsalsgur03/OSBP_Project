import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:latlong2/latlong.dart';

Future<LatLng?> getCoordinatesFromLocation(String locationName) async {
  final apiKey = dotenv.env['KAKAO_API_KEY'];
  final url = Uri.parse(
      'https://dapi.kakao.com/v2/local/search/keyword.json?query=$locationName');

  final response = await http.get(
    url,
    headers: {'Authorization': 'KakaoAK $apiKey'},
  );

  print('응답 상태 코드: ${response.statusCode}');
  print('응답 본문: ${response.body}');

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final documents = data['documents'];

    if (documents != null && documents.isNotEmpty) {
      final first = documents[0];
      final lat = double.parse(first['y']);
      final lng = double.parse(first['x']);
      if (lng != null && lat != null) {
        print('좌표 찾음: ($lat, $lng)');
        return LatLng(lat, lng);
      } else {
        print('검색 결과 없음');
      }
    } else {
      print('HTTP ERROR: ${response.statusCode}');
    }
  }
  return null;
}
