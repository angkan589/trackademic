import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trackademic/features/authentication/presentation/create_account_screen.dart';
import 'package:trackademic/features/authentication/presentation/sign_in_screen.dart';
import 'package:trackademic/features/teacher/attendance/presentation/teacher_attendance_summary_screen.dart';
import 'package:trackademic/features/welcome/presentation/welcome_screen.dart';

void main() {
  testWidgets('Trackademic welcome screen displays correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));

    expect(find.text('Trackademic'), findsOneWidget);

    expect(
      find.text('Attendance that works\nonly where the class is.'),
      findsOneWidget,
    );

    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
  });

  testWidgets('authentication pages always expose back navigation', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.byType(SignInScreen), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    expect(find.byType(CreateAccountScreen), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);
  });

  testWidgets('attendance summary has report action and back button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TeacherAttendanceSummaryScreen(
          course: 'CSE-300 · Software Development Project',
          batch: '2026 · Section A',
          classType: 'Theory',
          durationMinutes: 15,
          sessionDate: null,
          totalStudents: 30,
          presentCount: 24,
          lateCount: 2,
          absentCount: 4,
        ),
      ),
    );

    expect(find.byType(BackButton), findsOneWidget);
    expect(find.text('Attendance Summary'), findsOneWidget);
    expect(find.text('Download report'), findsOneWidget);
    expect(find.text('87%'), findsOneWidget);
  });
}
