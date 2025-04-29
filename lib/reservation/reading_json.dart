import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart'; // path_provider 패키지 필요

final String scheduleFileName = 'schedule.json';
final String directoryName = 'scheduler';

Future<void> save_schedule({
  required String title,
  required String location,
  required String firstdate,
  required String lastdate,
  required String emoji,
}) async {
  try {
    // 파일 경로 설정
    final directory = await getApplicationDocumentsDirectory();
    final schedulerDirPath = '${directory.path}/$directoryName';
    final schedulePath = '$schedulerDirPath/$scheduleFileName';
    final schedulerDir = Directory(schedulerDirPath);
    final file = File(schedulePath);

    // 디렉토리 존재 확인 및 생성 (없으면 생성)
    if (!await schedulerDir.exists()) {
      await schedulerDir.create(recursive: true);
    }

    // 기존 데이터 읽기
    List<Map<String, dynamic>> schedules = [];
    if (await file.exists()) {
      try {
        final jsonString = await file.readAsString();
        if (jsonString.isNotEmpty) {
          final decodedData = jsonDecode(jsonString);
          // 디코딩된 데이터가 리스트 형태인지 확인
          if (decodedData is List) {
            // 리스트의 각 항목이 Map<String, dynamic>인지 확인하며 변환
            schedules = List<Map<String, dynamic>>.from(
                decodedData.whereType<Map<String, dynamic>>() // 타입 캐스팅 및 필터링
            );
            print("기존 일정 ${schedules.length}개 로드 완료.");
          } else {
            print("새 리스트로 시작합니다.");
            // 파일 내용이 이상하면 기존 내용을 무시하고 새로 시작
          }
        }
      } catch (e) {
        print("파일 읽기 또는 JSON 파싱 오류: $e. 새 리스트로 시작합니다.");
        schedules = []; // 오류 시 빈 리스트로 초기화
      }
    } else {
      print("저장된 파일 없음.");
    }

    // 새로운 일정 데이터 Map 생성, 일단 전부 문자열로 읽기
    final newSchedule = {
      '제목': title,
      '장소': location,
      '일정 시작': firstdate,
      '일정 종료': lastdate,
    };

    // 기존 리스트에 새로운 일정 추가
    schedules.add(newSchedule);

    // 업데이트된 전체 리스트 JSON 문자열로 인코딩
    final encoder = JsonEncoder.withIndent(' ');
    final updatedJsonData = encoder.convert(schedules);

    // 파일에 최종 데이터 저장 (덮어쓰기)
    await file.writeAsString(updatedJsonData);

  } catch (e) {
    // 파일 시스템 오류 등 예외 처리
    print('일정 저장 실패: $e');
  }
}
