import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:world_timezone_cal/main.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App launches with 3-tab navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const WorldTimezoneCalApp());
    await tester.pumpAndSettle();

    expect(find.text('Current'), findsOneWidget);
    expect(find.text('Calculate'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    await tester.tap(find.text('Calculate'));
    await tester.pumpAndSettle();
    expect(find.text('Calculate Time'), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsWidgets);

    await tester.tap(find.text('Current'));
    await tester.pumpAndSettle();
    expect(find.text('Current Time'), findsOneWidget);
  });

  testWidgets('Settings screen has toggles', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const WorldTimezoneCalApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Dark Mode'), findsOneWidget);
    expect(find.text('24-Hour Format'), findsOneWidget);
  });

  testWidgets('Current Time screen shows city cards after init', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const WorldTimezoneCalApp());
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('Taipei'), findsOneWidget);
  });
}
