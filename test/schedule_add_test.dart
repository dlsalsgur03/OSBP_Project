import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:OBSP_Project/schedulePopup/schedule_add.dart';

void main() {
  testWidgets('일정 제목 입력 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScheduleBottomSheetContent(scrollController: ScrollController()),
        ),
      ),
    );

    // 제목 입력 필드 찾기
    final Finder titleField = find.widgetWithText(TextField, "일정 제목");

    // 입력값 설정
    await tester.enterText(titleField, "회의");

    // 기대값 검증
    expect(find.text("회의"), findsOneWidget);
  });

  testWidgets('장소 검색 모달이 열리는지 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScheduleBottomSheetContent(scrollController: ScrollController()),
        ),
      ),
    );

    final Finder locationField = find.widgetWithText(TextField, "장소");

    await tester.tap(locationField);
    await tester.pumpAndSettle();

    // 모달의 내부 UI 요소를 확인하는 방식으로 테스트
    expect(find.text('장소·주소 검색'), findsOneWidget); // 검색 입력창이 표시되는지 확인
    expect(find.byIcon(Icons.search), findsOneWidget);
  });

  testWidgets('이모티콘 선택 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScheduleBottomSheetContent(scrollController: ScrollController()),
        ),
      ),
    );

    // 이모티콘 선택 버튼 찾기
    final Finder emojiButton = find.byIcon(Icons.emoji_emotions);

    await tester.tap(emojiButton);
    await tester.pumpAndSettle();

    // 이모티콘 선택 모달이 나타나는지 확인
    expect(find.byType(EmojiPicker), findsOneWidget);
  });

  testWidgets('취소 버튼 클릭 시 바텀시트 닫기', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => ScheduleBottomSheetContent(
                      scrollController: ScrollController(),
                    ),
                  );
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

    // 취소 버튼 확인
    debugDumpApp();
    expect(find.widgetWithText(TextButton, "취소"), findsOneWidget);

    // 취소 버튼 클릭
    await tester.tap(find.text("취소"));
    await tester.pumpAndSettle();

    // `Navigator.pop()`이 호출되었는지 확인 (즉, 바텀시트가 닫힘)
    expect(find.byType(ScheduleBottomSheetContent), findsNothing);
  });
}