import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Types into the text field with this label.
Future<void> enter(WidgetTester tester, String label, String text) =>
    tester.enterText(find.widgetWithText(TextField, label), text);

/// Taps the button or link with this text, and waits for what follows.
Future<void> tap(WidgetTester tester, String label) async {
  await tester.ensureVisible(find.text(label).last);
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

/// Signs in from the sign-in screen.
Future<void> signIn(WidgetTester tester, String email, String password) async {
  await tester.pumpAndSettle();
  await enter(tester, 'Email', email);
  await enter(tester, 'Password', password);
  await tap(tester, 'Sign in');
}
