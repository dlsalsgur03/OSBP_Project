import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:OBSP_Project/calendar/calendar.dart';

void main() {
  testWidgets('Calendar 위젯 렌더링 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Calendar(
            selectedDate: DateTime.now(),
            onDaySelected: (DateTime date) {},
            highlightWeekend: true,
          ),
        ),
      ),
    );

    // 캘린더 헤더가 올바르게 표시되는지 확인
    expect(find.byType(TableCalendar), findsOneWidget);
  });

  testWidgets('날짜 선택 이벤트 발생 테스트', (WidgetTester tester) async {
    DateTime? tappedDate;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Calendar(
            selectedDate: DateTime.now(),
            onDaySelected: (DateTime date) {
              tappedDate = date;
            },
            highlightWeekend: true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('15')); // 15일을 선택한다고 가정
    await tester.pumpAndSettle();

    expect(tappedDate, isNotNull);
    expect(tappedDate!.day, 15);
  });

  testWidgets('주말 강조 기능 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        supportedLocales: [Locale('ko', 'KR')],

        home: Scaffold(
          body: Calendar(
            selectedDate: DateTime.now(),
            onDaySelected: (DateTime date) {},
            highlightWeekend: true,
          ),
        ),
      ),
    );

    expect(find.textContaining('토'), findsOneWidget);
    expect(find.textContaining('일'), findsOneWidget);
  });
}