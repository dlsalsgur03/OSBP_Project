import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import '../schedulePopup/notification_local.dart';

Future<List<dynamic>> searchAddress(String query) async {
  final apiKey = dotenv.env['KAKAO_API_KEY'] ?? '';

  final position = await getCurrentLocation();

  final encodedQuery = Uri.encodeComponent(query);
  final url = Uri.parse('https://dapi.kakao.com/v2/local/search/keyword.json?query=$encodedQuery&x=${position.longitude}&y=${position.latitude}');

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
    await saveSelectedDoc(documents[0]);
    return jsonResult['documents']; // 주소 리스트
  } else {
    throw Exception('주소 검색 실패: ${response.statusCode}');
  }
}

Future<Position> getCurrentLocation() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // 위치 서비스가 꺼져있으면 예외처리
    throw Exception('위치 서비스가 꺼져 있습니다.');
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception('위치 권한 거부됨');
    }
  }
  if (permission == LocationPermission.deniedForever) {
    throw Exception('위치 권한이 영구 거부됨');
  }

  return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
}