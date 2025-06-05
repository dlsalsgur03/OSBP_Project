import 'package:permission_handler/permission_handler.dart';

Future<void> requestLocationPermission() async {
  var status = await Permission.location.status;
  if (!status.isGranted) {
    var result = await Permission.location.request();
    if (result.isGranted) {
      print("위치 권한 허용됨");
    } else {
      print("위치 권한 거부됨");
    }
  } else {
    print("이미 위치 권한이 허용된 상태");
  }
}
