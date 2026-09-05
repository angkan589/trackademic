import 'package:flutter/material.dart';
import 'package:trackademic/core/services/auth_service.dart';
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

  static const _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    final displayName =
        (user?.displayName != null && user!.displayName!.trim().isNotEmpty)
        ? user.displayName!.trim()
        : 'Student';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.large),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(displayName),
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

  Widget _buildHeader(String displayName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back, $displayName',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: AppSpacing.small),
        const Text(
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
                value: '—',
                detail: 'No attendance records yet',
                icon: Icons.fact_check_rounded,
                foreground: AppColors.success,
                background: AppColors.successBackground,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: const _MetricCard(
                label: 'Attendance marks',
                value: '—',
                detail: 'No attendance marks yet',
                icon: Icons.calculate_rounded,
                foreground: AppColors.primary,
                background: AppColors.informationBackground,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: const _MetricCard(
                label: 'CT average',
                value: '—',
                detail: 'No published marks yet',
                icon: Icons.bar_chart_rounded,
                foreground: AppColors.warning,
                background: AppColors.warningBackground,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: const _MetricCard(
                label: 'Today’s classes',
                value: '—',
                detail: 'No schedule data yet',
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
    return const _EmptyAcademicCard(
      title: 'Attendance by course',
      message:
          'Your course attendance will appear here after attendance records are created.',
      icon: Icons.fact_check_outlined,
    );
  }
}

class _TodayScheduleCard extends StatelessWidget {
  const _TodayScheduleCard();

  @override
  Widget build(BuildContext context) {
    return const _EmptyAcademicCard(
      title: 'Today’s schedule',
      message:
          'Your classes will appear here after schedule data is added by a teacher.',
      icon: Icons.calendar_month_outlined,
    );
  }
}

class _EmptyAcademicCard extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;

  const _EmptyAcademicCard({
    required this.title,
    required this.message,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
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
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.large),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.extraLarge,
              ),
              child: Column(
                children: [
                  Icon(icon, size: 48, color: AppColors.textTertiary),
                  const SizedBox(height: AppSpacing.medium),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
