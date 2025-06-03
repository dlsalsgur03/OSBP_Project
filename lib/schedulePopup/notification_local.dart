import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String> getRegion(Position pos) async {
  var apiKey = dotenv.env['KAKAO_API_KEY'];
  final url = Uri.parse('https://dapi.kakao.com/v2/local/geo/coord2regioncode.json?x=${pos.longitude}&y=${pos.latitude}');

  final res = await http.get(url, headers: {
    'Authorization': 'KakaoAK $apiKey',
  });

  if(res.statusCode == 200) {
    final data = jsonDecode(res.body);
    final doc = data['documents'][0];
    final region1 = doc['region_1depth_name'];
    final region2 = doc['region_2depth_name'];
    final region3 = doc['region_3depth_name'];

    return '$region1 $region2 $region3'; // 지역명 받아오기
  } else {
    throw Exception('Failed to get region');
  }
}

