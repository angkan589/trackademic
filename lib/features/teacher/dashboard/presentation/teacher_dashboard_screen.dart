import 'package:flutter/material.dart';
import 'package:trackademic/core/theme/app_colors.dart';
import 'package:trackademic/core/theme/app_dimensions.dart';
import 'package:trackademic/features/teacher/attendance/presentation/teacher_create_attendance_screen.dart';

class TeacherDashboardScreen extends StatelessWidget {
  const TeacherDashboardScreen({super.key});

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
              _buildHeader(context),
              const SizedBox(height: AppSpacing.extraLarge),
              _buildSummaryCards(),
              const SizedBox(height: AppSpacing.extraLarge),
              _buildMainContent(),
              const SizedBox(height: AppSpacing.extraLarge),
              const _DashboardLowerSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.regular,
      runSpacing: AppSpacing.regular,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, Prof Dr. Kaushik Deb',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: AppSpacing.small),
            Text(
              'Here is your academic overview for today.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
          ],
        ),
        FilledButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) {
                  return const Scaffold(
                    backgroundColor: AppColors.background,
                    body: SafeArea(
                      child: TeacherCreateAttendanceScreen(
                        showBackButton: true,
                      ),
                    ),
                  );
                },
              ),
            );
          },
          icon: const Icon(Icons.add_rounded),
          label: const Text('Create attendance'),
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    const cards = [
      _SummaryData(
        title: 'Assigned courses',
        value: '4',
        message: 'Current semester',
        icon: Icons.menu_book_rounded,
        iconColor: AppColors.primary,
        iconBackground: AppColors.informationBackground,
      ),
      _SummaryData(
        title: 'Total students',
        value: '186',
        message: 'Across all courses',
        icon: Icons.groups_rounded,
        iconColor: AppColors.success,
        iconBackground: AppColors.successBackground,
      ),
      _SummaryData(
        title: 'Today’s classes',
        value: '3',
        message: 'Next class at 11:30 AM',
        icon: Icons.calendar_month_rounded,
        iconColor: AppColors.warning,
        iconBackground: AppColors.warningBackground,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth;

        if (constraints.maxWidth >= 900) {
          cardWidth = (constraints.maxWidth - (AppSpacing.regular * 2)) / 3;
        } else if (constraints.maxWidth >= 600) {
          cardWidth = (constraints.maxWidth - AppSpacing.regular) / 2;
        } else {
          cardWidth = constraints.maxWidth;
        }

        return Wrap(
          spacing: AppSpacing.regular,
          runSpacing: AppSpacing.regular,
          children: [
            for (final card in cards)
              SizedBox(
                width: cardWidth,
                child: _SummaryCard(data: card),
              ),
          ],
        );
      },
    );
  }

  Widget _buildMainContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 820) {
          return const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 5, child: _ActiveAttendanceCard()),
              SizedBox(width: AppSpacing.regular),
              Expanded(flex: 6, child: _TodayScheduleCard()),
            ],
          );
        }

        return const Column(
          children: [
            _ActiveAttendanceCard(),
            SizedBox(height: AppSpacing.regular),
            _TodayScheduleCard(),
          ],
        );
      },
    );
  }
}

class _SummaryData {
  final String title;
  final String value;
  final String message;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;

  const _SummaryData({
    required this.title,
    required this.value,
    required this.message,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
  });
}

class _SummaryCard extends StatelessWidget {
  final _SummaryData data;

  const _SummaryCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: data.iconBackground,
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Icon(data.icon, color: data.iconColor, size: 28),
          ),
          const SizedBox(width: AppSpacing.regular),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.extraSmall),
                Text(
                  data.value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSpacing.extraSmall),
                Text(
                  data.message,
                  style: const TextStyle(
                    color: AppColors.textTertiary,
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

class _ActiveAttendanceCard extends StatelessWidget {
  const _ActiveAttendanceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Active attendance',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.medium,
                  vertical: AppSpacing.extraSmall,
                ),
                decoration: BoxDecoration(
                  color: AppColors.successBackground,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 9, color: AppColors.success),
                    SizedBox(width: AppSpacing.extraSmall),
                    Text(
                      'Live',
                      style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.large),
          const Text(
            'CSE 321 · Computer Architecture',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          const Text(
            'Section A · Room 302',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.large),
          const Wrap(
            spacing: AppSpacing.large,
            runSpacing: AppSpacing.medium,
            children: [
              _AttendanceInformation(
                icon: Icons.groups_rounded,
                label: '42 of 55 present',
              ),
              _AttendanceInformation(
                icon: Icons.timer_outlined,
                label: '18 minutes left',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.large),
          const Row(
            children: [
              Text(
                'Attendance progress',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Spacer(),
              Text(
                '76%',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.small),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: const LinearProgressIndicator(
              value: 0.76,
              minHeight: 9,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
            ),
          ),
          const SizedBox(height: AppSpacing.large),
          LayoutBuilder(
            builder: (context, constraints) {
              final buttons = [
                OutlinedButton(
                  onPressed: () {
                    _showMessage(
                      context,
                      'Opening attendance-session preview.',
                    );
                  },
                  child: const Text('View session'),
                ),
                FilledButton(
                  onPressed: () {
                    _showMessage(
                      context,
                      'End-session confirmation will appear here.',
                    );
                  },
                  child: const Text('End session'),
                ),
              ];

              if (constraints.maxWidth < 390) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    buttons[0],
                    const SizedBox(height: AppSpacing.small),
                    buttons[1],
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: buttons[0]),
                  const SizedBox(width: AppSpacing.small),
                  Expanded(child: buttons[1]),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _AttendanceInformation extends StatelessWidget {
  final IconData icon;
  final String label;

  const _AttendanceInformation({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: AppSpacing.small),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Today’s schedule',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Opening the complete schedule preview.'),
                    ),
                  );
                },
                child: const Text('View all'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.medium),
          const _ScheduleItem(
            time: '9:00 AM',
            courseCode: 'CSE 315',
            courseName: 'Software Engineering',
            room: 'Room 204',
            status: 'Completed',
            statusColor: AppColors.success,
            statusBackground: AppColors.successBackground,
          ),
          const SizedBox(height: AppSpacing.small),
          const _ScheduleItem(
            time: '11:30 AM',
            courseCode: 'CSE 321',
            courseName: 'Computer Architecture',
            room: 'Room 302',
            status: 'Next',
            statusColor: AppColors.primary,
            statusBackground: AppColors.informationBackground,
          ),
          const SizedBox(height: AppSpacing.small),
          const _ScheduleItem(
            time: '2:00 PM',
            courseCode: 'CSE 333',
            courseName: 'Computer Networks',
            room: 'Lab 2',
            status: 'Upcoming',
            statusColor: AppColors.warning,
            statusBackground: AppColors.warningBackground,
          ),
        ],
      ),
    );
  }
}

class _ScheduleItem extends StatelessWidget {
  final String time;
  final String courseCode;
  final String courseName;
  final String room;
  final String status;
  final Color statusColor;
  final Color statusBackground;

  const _ScheduleItem({
    required this.time,
    required this.courseCode,
    required this.courseName,
    required this.room,
    required this.status,
    required this.statusColor,
    required this.statusBackground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.regular),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              time,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.small),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  courseCode,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.extraSmall),
                Text(
                  courseName,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.extraSmall),
                Text(
                  room,
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.small),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.small,
              vertical: AppSpacing.extraSmall,
            ),
            decoration: BoxDecoration(
              color: statusBackground,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardLowerSection extends StatelessWidget {
  const _DashboardLowerSection();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 820) {
          return const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 5, child: _QuickActionsCard()),
              SizedBox(width: AppSpacing.regular),
              Expanded(flex: 6, child: _RecentActivityCard()),
            ],
          );
        }

        return const Column(
          children: [
            _QuickActionsCard(),
            SizedBox(height: AppSpacing.regular),
            _RecentActivityCard(),
          ],
        );
      },
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard();

  static const _actions = [
    _QuickActionData(
      title: 'Create attendance',
      description: 'Start GPS and passcode attendance',
      message: 'Opening the create-attendance preview.',
      icon: Icons.how_to_reg_rounded,
      color: AppColors.primary,
      background: AppColors.informationBackground,
    ),
    _QuickActionData(
      title: 'Manage schedule',
      description: 'Add, edit or reschedule a class',
      message: 'Opening the schedule-management preview.',
      icon: Icons.edit_calendar_rounded,
      color: AppColors.success,
      background: AppColors.successBackground,
    ),
    _QuickActionData(
      title: 'View timetable',
      description: 'See your day and week schedule',
      message: 'Opening the complete timetable preview.',
      icon: Icons.calendar_view_week_rounded,
      color: AppColors.warning,
      background: AppColors.warningBackground,
    ),
    _QuickActionData(
      title: 'Attendance reports',
      description: 'Review course attendance records',
      message: 'Opening the attendance-reports preview.',
      icon: Icons.analytics_outlined,
      color: AppColors.primary,
      background: AppColors.informationBackground,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
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
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          const Text(
            'Manage your classes and attendance.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.large),
          LayoutBuilder(
            builder: (context, constraints) {
              final double itemWidth;

              if (constraints.maxWidth >= 430) {
                itemWidth = (constraints.maxWidth - AppSpacing.small) / 2;
              } else {
                itemWidth = constraints.maxWidth;
              }

              return Wrap(
                spacing: AppSpacing.small,
                runSpacing: AppSpacing.small,
                children: [
                  for (final action in _actions)
                    SizedBox(
                      width: itemWidth,
                      child: _QuickActionTile(action: action),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QuickActionData {
  final String title;
  final String description;
  final String message;
  final IconData icon;
  final Color color;
  final Color background;

  const _QuickActionData({
    required this.title,
    required this.description,
    required this.message,
    required this.icon,
    required this.color,
    required this.background,
  });
}

class _QuickActionTile extends StatelessWidget {
  final _QuickActionData action;

  const _QuickActionTile({required this.action});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(AppRadius.medium),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        onTap: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(action.message)));
        },
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.regular),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.medium),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: action.background,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                child: Icon(action.icon, color: action.color),
              ),
              const SizedBox(width: AppSpacing.medium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.extraSmall),
                    Text(
                      action.description,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentActivityCard extends StatelessWidget {
  const _RecentActivityCard();

  static const _activities = [
    _ActivityData(
      title: 'Attendance completed',
      description: 'CSE 315 · 48 of 52 students present',
      time: '10:05 AM',
      label: 'Completed',
      icon: Icons.check_circle_outline_rounded,
      color: AppColors.success,
      background: AppColors.successBackground,
    ),
    _ActivityData(
      title: 'Practical class assigned',
      description: 'CSE 321 · 22 Batch · Lab 2',
      time: 'Yesterday',
      label: 'Official',
      icon: Icons.account_balance_outlined,
      color: AppColors.primary,
      background: AppColors.informationBackground,
    ),
    _ActivityData(
      title: 'Makeup class added',
      description: 'CSE 333 · 23 Batch · Room 204',
      time: 'Aug 5',
      label: 'Manual',
      icon: Icons.add_task_rounded,
      color: AppColors.warning,
      background: AppColors.warningBackground,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Recent activity',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Opening all activity preview.'),
                    ),
                  );
                },
                child: const Text('View all'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.medium),
          for (int index = 0; index < _activities.length; index++) ...[
            _ActivityItem(activity: _activities[index]),
            if (index < _activities.length - 1)
              const Divider(height: AppSpacing.extraLarge),
          ],
        ],
      ),
    );
  }
}

class _ActivityData {
  final String title;
  final String description;
  final String time;
  final String label;
  final IconData icon;
  final Color color;
  final Color background;

  const _ActivityData({
    required this.title,
    required this.description,
    required this.time,
    required this.label,
    required this.icon,
    required this.color,
    required this.background,
  });
}

class _ActivityItem extends StatelessWidget {
  final _ActivityData activity;

  const _ActivityItem({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: activity.background,
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          child: Icon(activity.icon, color: activity.color, size: 22),
        ),
        const SizedBox(width: AppSpacing.medium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activity.title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.extraSmall),
              Text(
                activity.description,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.small,
                      vertical: AppSpacing.extraSmall,
                    ),
                    decoration: BoxDecoration(
                      color: activity.background,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      activity.label,
                      style: TextStyle(
                        color: activity.color,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    activity.time,
                    style: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
