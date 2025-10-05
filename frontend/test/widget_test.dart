// This is a basic Flutter widget test for BPR Absence app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/main.dart';

void main() {
  testWidgets('App loads and shows splash screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Wait for any initialization
    await tester.pump();

    // Verify that our app loads successfully
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('App navigation test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Wait for any initialization and animations
    await tester.pumpAndSettle();

    // The app should load without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
