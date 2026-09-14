import 'report_export_platform.dart'
    if (dart.library.html) 'report_export_web.dart'
    as platform;

abstract final class ReportExportService {
  static Future<String> saveCsv({
    required String fileName,
    required String content,
  }) {
    return platform.saveCsv(
      fileName: _safeFileName(fileName),
      content: content,
    );
  }

  static String attendanceSummaryCsv({
    required String course,
    required String batch,
    required String classType,
    required String date,
    required int durationMinutes,
    required int totalStudents,
    required int presentCount,
    required int lateCount,
    required int absentCount,
  }) {
    final attended = presentCount + lateCount;
    final rate = totalStudents == 0 ? 0.0 : attended / totalStudents * 100;

    final rows = <List<Object>>[
      ['Trackademic Attendance Summary', ''],
      ['Course', course],
      ['Batch', batch],
      ['Class type', classType],
      ['Date', date],
      ['Duration (minutes)', durationMinutes],
      ['Total students', totalStudents],
      ['Present', presentCount],
      ['Late', lateCount],
      ['Absent', absentCount],
      ['Attendance rate', '${rate.toStringAsFixed(1)}%'],
    ];

    return rows.map((row) => row.map(_csvCell).join(',')).join('\n');
  }

  static String _safeFileName(String value) {
    final sanitized = value
        .trim()
        .replaceAll(RegExp(r'[^a-zA-Z0-9._-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_');

    final baseName = sanitized.isEmpty ? 'trackademic_report' : sanitized;
    return baseName.toLowerCase().endsWith('.csv') ? baseName : '$baseName.csv';
  }

  static String _csvCell(Object value) {
    final text = value.toString().replaceAll('"', '""');
    return '"$text"';
  }
}

class ReportExportException implements Exception {
  final String message;

  const ReportExportException(this.message);

  @override
  String toString() => message;
}
