import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

Future<Position> getCurrentLocation() async {
  var status = await Permission.location.request();
  if(status.isGranted) {
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  } else {
    throw Exception("Location permission denied");
  }
}