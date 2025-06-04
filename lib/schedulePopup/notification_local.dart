import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'search_func.dart';
import 'notification.dart';

class RegionStorage {
  static Map<String, dynamic>? selectedDoc;
}

Future<Map<String, dynamic>> getRegion(Position pos) async {
  var apiKey = dotenv.env['KAKAO_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) throw Exception('Kakao API Key 없음');
  final url = Uri.parse('https://dapi.kakao.com/v2/local/geo/coord2regioncode.json?x=${pos.longitude}&y=${pos.latitude}');

  final res = await http.get(url, headers: {
    'Authorization': 'KakaoAK $apiKey',
  });
  print('위치 좌표: (${pos.latitude}, ${pos.longitude})');
  print('응답 상태 코드: ${res.statusCode}');
  print('응답 본문: ${res.body}');

  if(res.statusCode == 200) {
    final data = jsonDecode(res.body);
    final doc = data['documents'][0];
    if(doc.isEmpty) throw Exception('Failed to get region');
    else {
      final region1 = doc['region_1depth_name'];
      final region2 = doc['region_2depth_name'];
      final region3 = doc['region_3depth_name'];
      print('region1: $region1, region2: $region2, region3: $region3');
      return doc; // 지역명 받아오기
    }
  } else {
    throw Exception('Failed to get region');
  }
}

Future<int> compareMyRegionWith() async {
  // 시/군/구 가져오기
  final myRegion = await getRegion(await getCurrentLocation());
  print(myRegion);
  final myRegion1 = myRegion['region_1depth_name'];
  final myRegion2 = myRegion['region_2depth_name'];
  final myRegion3 = myRegion['region_3depth_name'];
  final otherRegion = RegionStorage.selectedDoc!;
  print(otherRegion);
  final otherRegion1 = otherRegion['region_1depth_name'];
  final otherRegion2 = otherRegion['region_2depth_name'];
  final otherRegion3 = otherRegion['region_3depth_name'];

  int matchCount=0;
  if (myRegion1 == otherRegion1) matchCount++;
  if (myRegion2 == otherRegion2) matchCount++;
  if (myRegion3 == otherRegion3) matchCount++;

  return matchCount;
}

Future<void> notificationChanger(int notificationId ,String title, DateTime firstDate, DateTime lastDate) async {
  int matchLevel = await compareMyRegionWith();
  scheduleNotification(matchLevel, notificationId, title, firstDate, lastDate);
}

Future<void> saveSelectedDoc(Map<String,dynamic> doc) async {
  try {
    print('saveSelectedDoc 호출됨');
    if (doc == null) {
      print('doc is null');
      return;
    }
    final double longitude = double.parse(doc['x']);
    final double latitude = double.parse(doc['y']);
    //Map<String, dynamic> -> Postion : 받아오는 값에 x,y 좌표하고 주소만 있어서 변형 필요
    final pos = Position(
        longitude: longitude,
        latitude: latitude,
        timestamp: DateTime.now(),
        accuracy: 1.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0);
    final region = await getRegion(pos);
    RegionStorage.selectedDoc = region;
    print('✅ 선택된 지역 저장 완료: ${RegionStorage.selectedDoc}');
  } catch (e, st) {
    print('saveSelectedDoc 에러: $e');
    print(st);
  }
}