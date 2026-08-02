import 'package:flutter_test/flutter_test.dart';
import 'package:trackademic/app/trackademic_app.dart';

void main() {
  testWidgets(
    'Trackademic welcome screen displays correctly',
    (WidgetTester tester) async {
      // Build the Trackademic application.
      await tester.pumpWidget(const TrackademicApp());

      // Verify important welcome-screen content.
      expect(find.text('Trackademic'), findsOneWidget);

      expect(
        find.text('Attendance that works\nonly where the class is.'),
        findsOneWidget,
      );

      expect(find.text('Sign in'), findsOneWidget);
      expect(find.text('Create account'), findsOneWidget);
    },
  );
}