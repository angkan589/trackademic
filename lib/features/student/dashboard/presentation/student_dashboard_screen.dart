import 'package:flutter/material.dart';
import 'package:trackademic/core/theme/app_colors.dart';
import 'package:trackademic/core/theme/app_dimensions.dart';

class StudentDashboardScreen extends StatelessWidget {
  final VoidCallback onOpenAttendance;
  final VoidCallback onOpenMarks;
  final VoidCallback onOpenSchedule;

  const StudentDashboardScreen({
    required this.onOpenAttendance,
    required this.onOpenMarks,
    required this.onOpenSchedule,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.large),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: AppSpacing.large),
              const _PrivacyBanner(),
              const SizedBox(height: AppSpacing.large),
              _buildSummaryCards(),
              const SizedBox(height: AppSpacing.large),
              _buildQuickActions(),
              const SizedBox(height: AppSpacing.large),
              _buildMainContent(),
            ],
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
          'Welcome back, Afsana Rahman',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: AppSpacing.small),
        Text(
          'Here is your academic overview for today.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth;

        if (constraints.maxWidth >= 900) {
          cardWidth = (constraints.maxWidth - AppSpacing.regular * 3) / 4;
        } else if (constraints.maxWidth >= 560) {
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
              child: const _MetricCard(
                label: 'Overall attendance',
                value: '88%',
                detail: '43 of 49 classes',
                icon: Icons.fact_check_rounded,
                foreground: AppColors.success,
                background: AppColors.successBackground,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: const _MetricCard(
                label: 'Attendance marks',
                value: '9/10',
                detail: 'Calculated automatically',
                icon: Icons.calculate_rounded,
                foreground: AppColors.primary,
                background: AppColors.informationBackground,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: const _MetricCard(
                label: 'CT average',
                value: '16.4/20',
                detail: 'Across three courses',
                icon: Icons.bar_chart_rounded,
                foreground: AppColors.warning,
                background: AppColors.warningBackground,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: const _MetricCard(
                label: 'Today’s classes',
                value: '3',
                detail: 'Next class at 10:30 AM',
                icon: Icons.calendar_month_rounded,
                foreground: AppColors.secondary,
                background: AppColors.backgroundSoft,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick actions',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.regular),
          LayoutBuilder(
            builder: (context, constraints) {
              final attendanceButton = OutlinedButton.icon(
                onPressed: onOpenAttendance,
                icon: const Icon(Icons.location_on_rounded),
                label: const Text('Mark attendance'),
              );

              final marksButton = OutlinedButton.icon(
                onPressed: onOpenMarks,
                icon: const Icon(Icons.analytics_rounded),
                label: const Text('View marks'),
              );

              final scheduleButton = OutlinedButton.icon(
                onPressed: onOpenSchedule,
                icon: const Icon(Icons.calendar_month_rounded),
                label: const Text('View schedule'),
              );

              if (constraints.maxWidth >= 680) {
                return Row(
                  children: [
                    Expanded(child: attendanceButton),
                    const SizedBox(width: AppSpacing.medium),
                    Expanded(child: marksButton),
                    const SizedBox(width: AppSpacing.medium),
                    Expanded(child: scheduleButton),
                  ],
                );
              }

              return Column(
                children: [
                  SizedBox(width: double.infinity, child: attendanceButton),
                  const SizedBox(height: AppSpacing.small),
                  SizedBox(width: double.infinity, child: marksButton),
                  const SizedBox(height: AppSpacing.small),
                  SizedBox(width: double.infinity, child: scheduleButton),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 820) {
          return const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 6, child: _AttendanceByCourseCard()),
              SizedBox(width: AppSpacing.regular),
              Expanded(flex: 5, child: _TodayScheduleCard()),
            ],
          );
        }

        return const Column(
          children: [
            _AttendanceByCourseCard(),
            SizedBox(height: AppSpacing.regular),
            _TodayScheduleCard(),
          ],
        );
      },
    );
  }
}

class _PrivacyBanner extends StatelessWidget {
  const _PrivacyBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.regular),
      decoration: BoxDecoration(
        color: AppColors.informationBackground,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_outline_rounded, color: AppColors.primary),
          SizedBox(width: AppSpacing.medium),
          Expanded(
            child: Text(
              'Your academic records are private. Only you and '
              'authorized teachers can view them.',
              style: TextStyle(color: AppColors.textSecondary, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String detail;
  final IconData icon;
  final Color foreground;
  final Color background;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.detail,
    required this.icon,
    required this.foreground,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.regular),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Icon(icon, color: foreground),
          ),
          const SizedBox(height: AppSpacing.medium),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.extraSmall),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.extraSmall),
          Text(
            detail,
            style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _AttendanceByCourseCard extends StatelessWidget {
  const _AttendanceByCourseCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Attendance by course',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: AppSpacing.extraSmall),
          Text(
            'Minimum recommended attendance is 75%.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          SizedBox(height: AppSpacing.regular),
          _AttendanceRow(
            code: 'CSE 315',
            name: 'Software Engineering',
            attended: 16,
            total: 17,
            percentage: 94,
          ),
          Divider(),
          _AttendanceRow(
            code: 'CSE 321',
            name: 'Computer Architecture',
            attended: 14,
            total: 16,
            percentage: 88,
          ),
          Divider(),
          _AttendanceRow(
            code: 'CSE 333',
            name: 'Computer Networks',
            attended: 13,
            total: 16,
            percentage: 81,
          ),
        ],
      ),
    );
  }
}

class _AttendanceRow extends StatelessWidget {
  final String code;
  final String name;
  final int attended;
  final int total;
  final int percentage;

  const _AttendanceRow({
    required this.code,
    required this.name,
    required this.attended,
    required this.total,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final isSafe = percentage >= 75;
    final progressColor = isSafe ? AppColors.success : AppColors.danger;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      code,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      name,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$percentage%',
                style: TextStyle(
                  color: progressColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.small),
          LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 7,
            color: progressColor,
            backgroundColor: AppColors.border,
            borderRadius: BorderRadius.circular(AppRadius.circular),
          ),
          const SizedBox(height: AppSpacing.extraSmall),
          Text(
            '$attended of $total classes attended',
            style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _TodayScheduleCard extends StatelessWidget {
  const _TodayScheduleCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Today’s schedule',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Icon(Icons.calendar_today_rounded, color: AppColors.primary),
            ],
          ),
          SizedBox(height: AppSpacing.regular),
          _ScheduleRow(
            time: '9:30 AM',
            course: 'CSE 315',
            room: 'Room 401',
            completed: true,
          ),
          Divider(),
          _ScheduleRow(time: '10:30 AM', course: 'CSE 321', room: 'Room 302'),
          Divider(),
          _ScheduleRow(time: '1:30 PM', course: 'CSE 333', room: 'Network Lab'),
          SizedBox(height: AppSpacing.regular),
          _ScheduleUpdate(),
        ],
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  final String time;
  final String course;
  final String room;
  final bool completed;

  const _ScheduleRow({
    required this.time,
    required this.course,
    required this.room,
    this.completed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.medium),
      child: Row(
        children: [
          Container(
            width: 66,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.small),
            decoration: BoxDecoration(
              color: completed
                  ? AppColors.successBackground
                  : AppColors.informationBackground,
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: Text(
              time,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: completed ? AppColors.success : AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.medium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  room,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            completed ? Icons.check_circle_rounded : Icons.schedule_rounded,
            color: completed ? AppColors.success : AppColors.textTertiary,
          ),
        ],
      ),
    );
  }
}

class _ScheduleUpdate extends StatelessWidget {
  const _ScheduleUpdate();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: AppColors.warningBackground,
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: const Row(
        children: [
          Icon(Icons.update_rounded, color: AppColors.warning),
          SizedBox(width: AppSpacing.small),
          Expanded(
            child: Text(
              'CSE 333 was recently moved to Network Lab.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
