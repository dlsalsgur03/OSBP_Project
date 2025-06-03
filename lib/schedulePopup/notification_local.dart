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

Future<int> compareMyRegionWith(Map<String, dynamic> documents) async {
  // 시/군/구 가져오기
  final myRegion = await getRegion(await getCurrentLocation());
  final myRegion1 = myRegion['region_1depth_name'];
  final myRegion2 = myRegion['region_2depth_name'];
  final myRegion3 = myRegion['region_3depth_name'];
  final otherRegion1 = documents[0]['region_1depth_name'];
  final otherRegion2 = documents[0]['region_2depth_name'];
  final otherRegion3 = documents[0]['region_3depth_name'];

  int matchCount=0;
  if (myRegion1 == otherRegion1) matchCount++;
  if (myRegion2 == otherRegion2) matchCount++;
  if (myRegion3 == otherRegion3) matchCount++;

  return matchCount;
}

Future<void> notificationChanger(Map<String, dynamic> documents) async {
  int matchLevel = await compareMyRegionWith(documents);
  switch(matchLevel) {
    case 3 :
      print("같은지역입니다. 도보를 이용하거나, 시내버스를 이용하세요.");
      break;
    case 2 :
      print("같은 군 내입니다. 시내버스를 이용하세요.");
      break;
    case 1 :
      print("같은 시 내입니다. 시내버스를 이용하세요.");
      break;
    case 0 :
      print("버스, 기차");
      break;
  }
}
