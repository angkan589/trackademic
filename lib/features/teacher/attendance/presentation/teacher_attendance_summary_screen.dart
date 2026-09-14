import 'package:flutter/material.dart';
import 'package:trackademic/core/services/report_export_service.dart';
import 'package:trackademic/core/theme/app_colors.dart';
import 'package:trackademic/core/theme/app_dimensions.dart';

class TeacherAttendanceSummaryScreen extends StatelessWidget {
  final String course;
  final String batch;
  final String classType;
  final int durationMinutes;
  final DateTime? sessionDate;
  final int totalStudents;
  final int presentCount;
  final int lateCount;
  final int absentCount;

  const TeacherAttendanceSummaryScreen({
    required this.course,
    required this.batch,
    required this.classType,
    required this.durationMinutes,
    required this.sessionDate,
    required this.totalStudents,
    required this.presentCount,
    required this.lateCount,
    required this.absentCount,
    super.key,
  });

  double get _attendanceRate {
    if (totalStudents == 0) {
      return 0;
    }

    return ((presentCount + lateCount) / totalStudents)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  String get _formattedDate {
    final value = sessionDate ?? DateTime.now();

    return '${value.day.toString().padLeft(2, '0')}/'
        '${value.month.toString().padLeft(2, '0')}/'
        '${value.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Attendance summary'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1050),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: AppSpacing.large),
                  _buildSuccessBanner(),
                  const SizedBox(height: AppSpacing.large),
                  _buildSummaryCards(),
                  const SizedBox(height: AppSpacing.large),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth >= 800) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 6,
                              child: _buildAttendanceOverview(),
                            ),
                            const SizedBox(width: AppSpacing.regular),
                            Expanded(flex: 4, child: _buildSessionDetails()),
                          ],
                        );
                      }

                      return Column(
                        children: [
                          _buildAttendanceOverview(),
                          const SizedBox(height: AppSpacing.regular),
                          _buildSessionDetails(),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.large),
                  _buildActions(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attendance Summary',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: AppSpacing.small),
        Text(
          'Review the final attendance result for this session.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildSuccessBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.regular),
      decoration: BoxDecoration(
        color: AppColors.successBackground,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          Icon(Icons.task_alt_rounded, color: AppColors.success, size: 30),
          SizedBox(width: AppSpacing.medium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Attendance session completed',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: AppSpacing.extraSmall),
                Text(
                  'The session is closed and students can no longer submit.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth;

        if (constraints.maxWidth >= 760) {
          cardWidth = (constraints.maxWidth - AppSpacing.regular * 3) / 4;
        } else if (constraints.maxWidth >= 480) {
          cardWidth = (constraints.maxWidth - AppSpacing.regular) / 2;
        } else {
          cardWidth = constraints.maxWidth;
        }

        return Wrap(
          spacing: AppSpacing.regular,
          runSpacing: AppSpacing.regular,
          children: [
            SizedBox(
              width: cardWidth,
              child: _SummaryCard(
                label: 'Total students',
                value: '$totalStudents',
                icon: Icons.groups_rounded,
                color: AppColors.primary,
                background: AppColors.informationBackground,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _SummaryCard(
                label: 'Present',
                value: '$presentCount',
                icon: Icons.check_circle_outline_rounded,
                color: AppColors.success,
                background: AppColors.successBackground,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _SummaryCard(
                label: 'Late',
                value: '$lateCount',
                icon: Icons.more_time_rounded,
                color: AppColors.warning,
                background: AppColors.warningBackground,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _SummaryCard(
                label: 'Absent',
                value: '$absentCount',
                icon: Icons.person_off_outlined,
                color: Colors.red,
                background: AppColors.background,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAttendanceOverview() {
    final ratePercentage = (_attendanceRate * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: AppShadows.raised,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Attendance overview',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.extraLarge),
          Center(
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.successBackground,
                border: Border.all(color: AppColors.success, width: 8),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$ratePercentage%',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Text(
                      'Attendance',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.extraLarge),
          LinearProgressIndicator(
            value: _attendanceRate,
            minHeight: 10,
            color: AppColors.success,
            backgroundColor: AppColors.background,
            borderRadius: BorderRadius.circular(100),
          ),
          const SizedBox(height: AppSpacing.medium),
          Text(
            '${presentCount + lateCount} out of $totalStudents students '
            'attended this class.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionDetails() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: AppShadows.raised,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Session details',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.large),
          _DetailRow(
            icon: Icons.menu_book_rounded,
            label: 'Course',
            value: course,
          ),
          const SizedBox(height: AppSpacing.medium),
          _DetailRow(icon: Icons.groups_rounded, label: 'Batch', value: batch),
          const SizedBox(height: AppSpacing.medium),
          _DetailRow(
            icon: Icons.category_outlined,
            label: 'Class type',
            value: classType,
          ),
          const SizedBox(height: AppSpacing.medium),
          _DetailRow(
            icon: Icons.calendar_today_outlined,
            label: 'Date',
            value: _formattedDate,
          ),
          const SizedBox(height: AppSpacing.medium),
          _DetailRow(
            icon: Icons.timer_outlined,
            label: 'Session duration',
            value: '$durationMinutes minutes',
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton.icon(
          onPressed: () => _downloadReport(context),
          icon: const Icon(Icons.download_rounded),
          label: const Text('Download report'),
        ),
        const SizedBox(width: AppSpacing.medium),
        FilledButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.done_rounded),
          label: const Text('Done'),
        ),
      ],
    );
  }

  Future<void> _downloadReport(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final dateForFile = _formattedDate.replaceAll('/', '-');
    final csv = ReportExportService.attendanceSummaryCsv(
      course: course,
      batch: batch,
      classType: classType,
      date: _formattedDate,
      durationMinutes: durationMinutes,
      totalStudents: totalStudents,
      presentCount: presentCount,
      lateCount: lateCount,
      absentCount: absentCount,
    );

    try {
      final message = await ReportExportService.saveCsv(
        fileName: 'attendance_${course}_$dateForFile.csv',
        content: csv,
      );

      messenger.showSnackBar(SnackBar(content: Text(message)));
    } on ReportExportException catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(error.message)));
    }
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color background;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.regular),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: AppShadows.soft,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: AppSpacing.medium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.textTertiary, size: 20),
        const SizedBox(width: AppSpacing.small),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: AppSpacing.extraSmall),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
