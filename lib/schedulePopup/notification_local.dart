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
    return data['documents'][0]['region_3depth_name']; // 지역명(동이름) 받아오기
  } else {
    throw Exception('Failed to get region');
  }
}