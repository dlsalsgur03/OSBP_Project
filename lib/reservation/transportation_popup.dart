import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// 교통수단 예매 팝업 함수
void showBookingOptions(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('교통수단 예매'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.directions_bus),
              title: Text('버스 예매'),
              onTap: () {
                Navigator.of(context).pop(); // 팝업 닫기

              },
            ),
            ListTile(
              leading: Icon(Icons.train),
              title: Text('기차 예매'),
              onTap: () {
                Navigator.of(context).pop(); // 팝업 닫기
              },
            ),
          ],
        ),
      );
    },
  );
}
