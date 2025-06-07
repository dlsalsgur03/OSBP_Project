import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:OBSP_Project/calendar/underCalender/under_calendar_info.dart';
import 'package:OBSP_Project/menu/menu.dart';
import 'package:OBSP_Project/menu/drawer.dart';
import 'package:OBSP_Project/homepage/homepage.dart';

void main() {
  testWidgets('HomePage UI 요소가 올바르게 표시되는지 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: HomePage()));

    expect(find.text("Miri Calendar"), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  test('SharedPreferences에 색상이 올바르게 저장되는지 테스트', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    Color testColor = Colors.red;
    await saveSettings(testColor, true, Colors.blue);

    expect(prefs.getInt('selectedColor'), testColor.value);
    expect(prefs.getBool('highlightWeekend'), true);
    expect(prefs.getInt('markerColor'), Colors.blue.value);
  });

  testWidgets('FloatingActionButton을 누르면 일정 추가 창이 나타나는지 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: HomePage()));

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.byType(ScheduleListWidget), findsOneWidget);
  });

  testWidgets('메뉴 버튼 클릭 시 드로어가 열리는지 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: HomePage()));

    await tester.tap(find.byType(MenuButton));
    await tester.pumpAndSettle();

    expect(find.byType(MenuDrawer), findsOneWidget);
  });
}
