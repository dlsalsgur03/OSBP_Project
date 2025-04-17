import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
//csv 파일로 저장
Future<void> save_schedule({
  required String title,
  required String location,
  required DateTime firstdate,
  required DateTime lastdate,
}) async {
  try {
    // csv 데이터
    final List<List<dynamic>> rows = [
      ['제목','장소','일정 시작','일정 종료',],
      [
        title,
        location,
        firstdate.toString()
      ],
    ];
    final csvData = const ListToCsvConverter().convert(rows);
    // 파일 경로
    final directory = await getApplicationDocumentsDirectory();
    final scheduler = Directory('${directory.path}/scheduler');
    final schedulepath = '${scheduler.path}/schedule.csv';


    // 파일 저장
    final file = File(schedulepath);
    await file.writeAsString(csvData);

    print("파일 저장"); // 저장 확인용
  } catch(e) {
    print('저장 실패: $e');
  }
}