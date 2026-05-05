import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:world_timezone_cal/main.dart';

void main() {
  testWidgets('App launches with navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Verify main navigation destinations exist
    expect(find.text('Current'), findsOneWidget);
    expect(find.text('Calculate'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    // Tap Calculate tab and verify it navigates
    await tester.tap(find.text('Calculate'));
    await tester.pumpAndSettle();
    expect(find.text('Calculate Time Screen - Phase 1 Placeholder'), findsOneWidget);

    // Tap Settings tab and verify
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Settings Screen - Phase 1 Placeholder'), findsOneWidget);
  });
}
