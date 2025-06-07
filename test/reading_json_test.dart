import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:OBSP_Project/reservation/reading_json.dart';

void main() {
  group('Schedule Service Tests', () {
    // 각 테스트가 실행되기 전에 SharedPreferences를 위한 모의(가짜) 초기값을 설정
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('should save a new schedule and retrieve it with getAllSchedules', () async {
      // Arrange: 테스트에 필요한 데이터와 환경을 준비합니다.
      final testDate = DateTime(2023, 10, 27);

      // Act: 테스트하려는 함수를 실행합니다.
      await save_schedule(
        title: '플러터 스터디',
        location: '온라인',
        firstdate: testDate,
        lastdate: testDate,
        emoji: '💻',
        memo: '유닛 테스트 작성하기',
      );

      // Assert: 함수의 실행 결과가 예상과 일치하는지 확인
      final schedules = await getAllSchedules();

      expect(schedules.length, 1); // 스케줄이 1개 저장되었는지 확인
      expect(schedules.first.title, '플러터 스터디');
      expect(schedules.first.memo, '유닛 테스트 작성하기');
      expect(schedules.first.firstdate, testDate.toIso8601String());
    });

    test('getSchedule should return correct schedules for a specific date', () async {
      // Arrange
      final date1 = DateTime(2023, 11, 1);
      final date2 = DateTime(2023, 11, 5);

      await save_schedule(title: '일정 1', location: '장소 1', firstdate: date1, lastdate: date1, emoji: '1️⃣', memo: '');
      await save_schedule(title: '일정 2', location: '장소 2', firstdate: date2, lastdate: date2, emoji: '2️⃣', memo: '');

      // Act
      final schedulesOnDate1 = await getSchedule(date1);
      final schedulesOnDate2 = await getSchedule(date2);
      final schedulesOnEmptyDate = await getSchedule(DateTime(2023, 11, 3));

      // Assert
      expect(schedulesOnDate1.length, 1);
      expect(schedulesOnDate1.first.title, '일정 1');

      expect(schedulesOnDate2.length, 1);
      expect(schedulesOnDate2.first.title, '일정 2');

      expect(schedulesOnEmptyDate.isEmpty, true); // 해당 날짜에는 일정이 없어야 함
    });

    test('getSchedule should correctly filter schedules spanning multiple days', () async {
      // Arrange
      final startDate = DateTime(2023, 12, 10);
      final endDate = DateTime(2023, 12, 15);
      await save_schedule(title: '장기 여행', location: '제주도', firstdate: startDate, lastdate: endDate, emoji: '✈️', memo: '휴가');

      // Act
      final schedulesOnDay12 = await getSchedule(DateTime(2023, 12, 12));
      final schedulesOnDay16 = await getSchedule(DateTime(2023, 12, 16));

      // Assert
      expect(schedulesOnDay12.length, 1);
      expect(schedulesOnDay12.first.title, '장기 여행');
      expect(schedulesOnDay16.isEmpty, true);
    });

    test('deleteSchedule should remove a schedule correctly', () async {
      // Arrange
      final date = DateTime.now();
      await save_schedule(title: '삭제될 일정', location: '임시', firstdate: date, lastdate: date, emoji: '🗑️', memo: '이건 지워져야 함');
      await save_schedule(title: '남아있을 일정', location: '영구', firstdate: date, lastdate: date, emoji: '🌟', memo: '이건 남아있어야 함');

      // 삭제할 Schedule 객체를 생성
      final scheduleToDelete = Schedule(
        title: '삭제될 일정',
        location: '임시',
        firstdate: date.toIso8601String(),
        lastdate: date.toIso8601String(),
        emoji: '🗑️', // emoji는 삭제 조건에 없으므로 중요하지 않음
        memo: '이건 지워져야 함',
      );

      // Act
      await deleteSchedule(scheduleToDelete);

      // Assert
      final remainingSchedules = await getAllSchedules();
      expect(remainingSchedules.length, 1);
      expect(remainingSchedules.first.title, '남아있을 일정');
    });

    test('updateScheduleMemo should update the memo of a specific schedule', () async {
      // Arrange
      final date = DateTime(2024, 1, 1);
      final titleToUpdate = '새해 목표 정하기';
      final initialMemo = '작년 회고';
      final newMemo = '올해 계획 세우기!';

      await save_schedule(title: titleToUpdate, location: '집', firstdate: date, lastdate: date, emoji: '📝', memo: initialMemo);

      // Act
      await updateScheduleMemo(date.toIso8601String(), titleToUpdate, newMemo);

      // Assert
      final updatedSchedules = await getAllSchedules();
      expect(updatedSchedules.length, 1);
      expect(updatedSchedules.first.memo, newMemo);
      expect(updatedSchedules.first.title, titleToUpdate); // 다른 정보는 그대로인지 확인
    });

    test('getAllSchedules should return an empty list when storage is empty', () async {
      // Arrange: 아무것도 하지 않음 (setUp에서 storage를 비워줌)

      // Act
      final schedules = await getAllSchedules();

      // Assert
      expect(schedules.isEmpty, true);
    });
  });
}