import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<List<dynamic>> searchAddress(String query) async {
  final apiKey = dotenv.env['KAKAO_API_KEY'] ?? '';

  final encodedQuery = Uri.encodeComponent(query);
  final url = Uri.parse('https://dapi.kakao.com/v2/local/search/keyword.json?query=$encodedQuery');

  final response = await http.get(
    url,
    headers: {
      'Authorization': 'KakaoAK $apiKey',
    },
  );

  print('응답 상태 코드: ${response.statusCode}');
  print('응답 본문: ${response.body}');

  if (response.statusCode == 200) {
    final jsonResult = json.decode(response.body);
    final documents = jsonResult['documents'];
    if (documents.isEmpty){
      print('검색 결과 없음');
    } else {
      for (var place in documents) {
        print('장소명: ${place['place_name']}, 주소: ${place['road_address_name']}');
      }
    }
    return jsonResult['documents']; // 주소 리스트
  } else {
    throw Exception('주소 검색 실패: ${response.statusCode}');
  }
}
