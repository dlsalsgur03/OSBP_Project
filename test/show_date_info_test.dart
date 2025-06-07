import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:OBSP_Project/calendar/dateInfo/show_date_info.dart';

void main() {
  testWidgets('바텀시트가 정상적으로 열리는지 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                onPressed: () {
                  showBottomSheetModal(context, DateTime.now());
                },
                child: Text("바텀시트 열기"),
              );
            },
          ),
        ),
      ),
    );

    // 바텀시트 열기
    await tester.tap(find.text("바텀시트 열기"));
    await tester.pumpAndSettle();

    // 바텀시트가 정상적으로 표시되었는지 확인
    expect(find.textContaining("To Do List"), findsOneWidget);
  });

  testWidgets('할 일 추가 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                onPressed: () {
                  showBottomSheetModal(context, DateTime.now());
                },
                child: Text("바텀시트 열기"),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text("바텀시트 열기"));
    await tester.pumpAndSettle();

    final Finder textField = find.byType(TextField);
    await tester.enterText(textField, "새로운 할 일");
    await tester.tap(find.text("추가"));
    await tester.pumpAndSettle();

    expect(find.text("새로운 할 일"), findsOneWidget);
  });

  testWidgets('할 일 삭제 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                onPressed: () {
                  showBottomSheetModal(context, DateTime.now());
                },
                child: Text("바텀시트 열기"),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text("바텀시트 열기"));
    await tester.pumpAndSettle();

    final Finder textField = find.byType(TextField);
    await tester.enterText(textField, "삭제할 할 일");
    await tester.tap(find.text("추가"));
    await tester.pumpAndSettle();

    expect(find.text("삭제할 할 일"), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline_rounded));
    await tester.pumpAndSettle();

    expect(find.text("삭제할 할 일"), findsNothing);
  });

  testWidgets('할 일 완료 상태 변경 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                onPressed: () {
                  showBottomSheetModal(context, DateTime.now());
                },
                child: Text("바텀시트 열기"),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text("바텀시트 열기"));
    await tester.pumpAndSettle();

    final Finder textField = find.byType(TextField);
    await tester.enterText(textField, "완료할 할 일");
    await tester.tap(find.text("추가"));
    await tester.pumpAndSettle();

    expect(find.text("완료할 할 일"), findsOneWidget);

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    // 완료 상태 변경 확인
    final Text completedTask = find.text("완료할 할 일").evaluate().first.widget as Text;
    expect(completedTask.style?.decoration, TextDecoration.lineThrough);
  });
}