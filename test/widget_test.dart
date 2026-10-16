import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ritu_nails_art/main.dart';

void main() {
  testWidgets('app loads login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text("Don't have an account?"), findsOneWidget);
    expect(find.text('Forgot Password?'), findsOneWidget);
  });
}
