import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'search_func.dart';

Future<Map<String, dynamic>> getRegion(Position pos) async {
  var apiKey = dotenv.env['KAKAO_API_KEY'];
  final url = Uri.parse('https://dapi.kakao.com/v2/local/geo/coord2regioncode.json?x=${pos.longitude}&y=${pos.latitude}');

  final res = await http.get(url, headers: {
    'Authorization': 'KakaoAK $apiKey',
  });

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

Future<void> compareMyRegionWith(Map<String, dynamic> documents) async {
  // 시/군/구 가져오기
  final myRegion = await getRegion(await getCurrentLocation());
  final myRegion1 = myRegion['region_1depth_name'];
  final myRegion2 = myRegion['region_2depth_name'];
  final myRegion3 = myRegion['region_3depth_name'];
  final otherRegion1 = documents[0]['region_1depth_name'];
  final otherRegion2 = documents[0]['region_2depth_name'];
  final otherRegion3 = documents[0]['region_3depth_name'];

  if(myRegion1 == otherRegion1 && myRegion2 == otherRegion2 && myRegion3 == otherRegion3) {
    print('✅ 같은 지역입니다.');
  }
  else if (myRegion1 == otherRegion1 && myRegion2 == otherRegion2) {
    print('🚌 같은 시/군 → 버스 알림!');
  }
  else if (myRegion1 == otherRegion1) {
    print('🚌 같은 시/군 → 버스 알림!');
  }
  else {
    print('🚆 같은 시/도만 같음 → 기차 알림!');
  }

}
