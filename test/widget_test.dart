// Basic smoke test for GalClean.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mad/main.dart';

void main() {
  testWidgets('App launches on the welcome screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    // The welcome screen shows the brand name and the primary CTA.
    expect(find.text('GalClean'), findsOneWidget);
    expect(find.text('Start swiping'), findsOneWidget);
  });
}
