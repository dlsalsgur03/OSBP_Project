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
                launchURL('https://www.kobus.co.kr/main.do'); // 고속버스 예매 사이트로 이동
              },
            ),
            ListTile(
              leading: Icon(Icons.train),
              title: Text('기차 예매'),
              onTap: () {
                Navigator.of(context).pop(); // 팝업 닫기
                launchURL('https://www.letskorail.com/'); // 기차 예매 사이트로 이동
              },
            ),
          ],
        ),
      );
    },
  );
}
// URL 실행 함수
Future<void> launchURL(String url) async {
  Uri uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    launchUrl(
      uri,
      mode: LaunchMode.externalApplication, // 외부 애플리케이션에서 열기
    );
  } else {
    throw 'Could not launch $url';
  }
}
