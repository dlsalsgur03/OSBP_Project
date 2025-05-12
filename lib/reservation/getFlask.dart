import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;

// Flask 서버 URL 가져오기
String getFlaskBaseUrl() {
  if(kIsWeb) {
    return 'http://localhost:5000';
  }
  else if(Platform. isAndroid) {
    return 'http://10.0.2.2:5000';
  }
  else {
    return 'http://localhost:5000';
  }
}

