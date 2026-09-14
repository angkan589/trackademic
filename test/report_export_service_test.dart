import 'package:flutter_test/flutter_test.dart';
import 'package:trackademic/core/services/report_export_service.dart';

void main() {
  test('attendance summary CSV contains escaped live values', () {
    final csv = ReportExportService.attendanceSummaryCsv(
      course: 'CSE-300, SDP',
      batch: '2026 "A"',
      classType: 'Theory',
      date: '05/09/2026',
      durationMinutes: 15,
      totalStudents: 30,
      presentCount: 24,
      lateCount: 2,
      absentCount: 4,
    );

    expect(csv, contains('"CSE-300, SDP"'));
    expect(csv, contains('"2026 ""A"""'));
    expect(csv, contains('"Attendance rate","86.7%"'));
  });
}
