import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ritu_nails_art/main.dart';
import 'package:ritu_nails_art/screens/courses/add_course_or_video_screen.dart';
import 'package:ritu_nails_art/screens/courses/courses_screen.dart';

void main() {
  testWidgets('app loads login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text("Don't have an account?"), findsOneWidget);
    expect(find.text('Forgot Password?'), findsOneWidget);
  });

  testWidgets('course page mode controls switch between all content types',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: CoursesScreen()));

    await tester.tap(find.text('Online Classes'));
    await tester.pump();
    expect(find.text('Online Nail Art & Design Masterclass'), findsOneWidget);

    await tester.tap(find.text('Video Clips'));
    await tester.pump();
    expect(find.text('Russian Cuticle Prep & Builder Gel Overlay'),
        findsOneWidget);
  });

  testWidgets('add form mode controls expose course and video fields',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AddCourseOrVideoScreen()));

    await tester.tap(find.text('Video Clip'));
    await tester.pump();
    expect(find.text('Video Stream Link or File URL'), findsOneWidget);
    expect(find.text('Choose Video Clip'), findsOneWidget);

    await tester.tap(find.text('Offline'));
    await tester.pump();
    expect(find.text('Course Fee *'), findsOneWidget);
    expect(find.text('Choose Image'), findsOneWidget);
  });
}
