import 'package:flutter_test/flutter_test.dart';
import 'package:world_timezone_cal/main.dart';

void main() {
  testWidgets('App launches with 3-tab navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const WorldTimezoneCalApp());
    await tester.pumpAndSettle();

    // Verify navigation destinations exist
    expect(find.text('Current'), findsOneWidget);
    expect(find.text('Calculate'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    // Tap Calculate tab
    await tester.tap(find.text('Calculate'));
    await tester.pumpAndSettle();
    expect(find.text('Calculate Time'), findsOneWidget);

    // Tap Settings tab
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsWidgets);

    // Back to Current tab
    await tester.tap(find.text('Current'));
    await tester.pumpAndSettle();
    expect(find.text('Current Time'), findsOneWidget);
  });

  testWidgets('Settings screen has dark mode and time format toggles', (WidgetTester tester) async {
    await tester.pumpWidget(const WorldTimezoneCalApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Dark Mode'), findsOneWidget);
    expect(find.text('24-Hour Format'), findsOneWidget);
  });

  testWidgets('Current Time screen shows city cards', (WidgetTester tester) async {
    await tester.pumpWidget(const WorldTimezoneCalApp());
    await tester.pumpAndSettle();

    // Should show Taipei (default selected city)
    expect(find.text('Taipei'), findsOneWidget);
  });
}
