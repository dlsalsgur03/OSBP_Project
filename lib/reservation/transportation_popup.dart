import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../schedulePopup/notification.dart';
import '../schedulePopup/notification_local.dart';


// 교통수단 예매 팝업 함수
void showBookingOptions(BuildContext context, String title, DateTime firstdate, DateTime lastdate) {
  int notificationId = notification_Id(firstdate, title);
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color(0xffffffff),
        title: const Text('교통수단 예매'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.directions_bus),
              title: Text('버스 예매'),
              onTap: () async {
                bool is_exist = await isIdStored(notificationId);
                if(is_exist) {
                  await removeId(notificationId);
                }
                Navigator.of(context).pop(); // 팝업 닫기
                launchURL('https://www.kobus.co.kr/main.do'); // 고속버스 예매 사이트로 이동
              },
            ),
            ListTile(
              leading: Icon(Icons.train),
              title: Text('기차 예매'),
              onTap: () async {
                bool is_exist2 = await isIdStored(notificationId);
                if(is_exist2) {
                  await removeId(notificationId);
                }
                Navigator.of(context).pop(); // 팝업 닫기
                launchURL('https://www.letskorail.com/'); // 기차 예매 사이트로 이동
              },
            ),
            ListTile(
              title: Text('다음에 예매'),
              onTap: () {
                storeId(notificationId);
                notificationChanger(notificationId ,title ,firstdate, lastdate);
                Navigator.of(context).pop();
              }
            )
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
