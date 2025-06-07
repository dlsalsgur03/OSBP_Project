import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:OBSP_Project/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('앱이 Splash → HomePage로 전환', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Miri Calendar'), findsOneWidget); // Splash

    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump(const Duration(milliseconds: 1000));

    expect(find.text('Miri Calendar'), findsWidgets); // AppBar
  });
}
