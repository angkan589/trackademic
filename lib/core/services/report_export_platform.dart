import 'package:flutter/services.dart';
import 'package:trackademic/core/services/report_export_service.dart';

const _channel = MethodChannel('trackademic/report_export');

Future<String> saveCsv({
  required String fileName,
  required String content,
}) async {
  try {
    final path = await _channel.invokeMethod<String>('saveCsv', {
      'fileName': fileName,
      'content': content,
    });

    return path == null || path.isEmpty
        ? 'Attendance report saved.'
        : 'Attendance report saved to $path.';
  } on MissingPluginException {
    throw const ReportExportException(
      'Report download is supported on Android and web.',
    );
  } on PlatformException catch (error) {
    throw ReportExportException(
      error.message ?? 'The attendance report could not be saved.',
    );
  }
}
