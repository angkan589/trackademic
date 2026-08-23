import 'package:flutter/material.dart';
import 'package:trackademic/core/theme/app_colors.dart';
import 'package:trackademic/core/theme/app_dimensions.dart';
import 'package:trackademic/features/teacher/schedule/presentation/teacher_add_class_screen.dart';
import 'package:trackademic/features/teacher/attendance/presentation/teacher_create_attendance_screen.dart';

class TeacherScheduleScreen extends StatefulWidget {
  const TeacherScheduleScreen({super.key});

  @override
  State<TeacherScheduleScreen> createState() => _TeacherScheduleScreenState();
}

class _TeacherScheduleScreenState extends State<TeacherScheduleScreen> {
  bool _showWeekView = false;
  int _selectedDay = 4;

  static const _days = ['Sunday','Monday', 'Tuesday', 'Wednesday', 'Thursday'];

  static const _classes = [
    _ScheduleEntry(
      dayIndex: 0,
      time: '9:00 AM',
      endTime: '9:50 AM',
      courseCode: 'CSE 321',
      courseName: 'Computer Architecture',
      batch: '22 Batch · Section A',
      classType: 'Theory',
      room: 'Room 302',
      source: 'Official',
      status: 'Scheduled',
      icon: Icons.menu_book_rounded,
    ),
    _ScheduleEntry(
      dayIndex: 1,
      time: '11:00 AM',
      endTime: '12:40 PM',
      courseCode: 'CSE 321',
      courseName: 'Computer Architecture',
      batch: '22 Batch · Section A',
      classType: 'Practical',
      room: 'Hardware Lab',
      source: 'Official',
      status: 'Scheduled',
      icon: Icons.science_outlined,
    ),
    _ScheduleEntry(
      dayIndex: 2,
      time: '2:00 PM',
      endTime: '2:50 PM',
      courseCode: 'CSE 333',
      courseName: 'Computer Networks',
      batch: '23 Batch · Section B',
      classType: 'Theory',
      room: 'Room 204',
      source: 'Manual',
      status: 'Scheduled',
      icon: Icons.router_outlined,
    ),
    _ScheduleEntry(
      dayIndex: 3,
      time: '10:00 AM',
      endTime: '11:40 AM',
      courseCode: 'CSE 315',
      courseName: 'Software Engineering',
      batch: '22 Batch · Section B',
      classType: 'Practical',
      room: 'Software Lab 2',
      source: 'Rescheduled',
      status: 'Rescheduled',
      icon: Icons.computer_rounded,
    ),
    _ScheduleEntry(
      dayIndex: 4,
      time: '9:00 AM',
      endTime: '9:50 AM',
      courseCode: 'CSE 315',
      courseName: 'Software Engineering',
      batch: '22 Batch · Section A',
      classType: 'Theory',
      room: 'Room 204',
      source: 'Official',
      status: 'Completed',
      icon: Icons.developer_board_rounded,
    ),
    _ScheduleEntry(
      dayIndex: 4,
      time: '11:30 AM',
      endTime: '12:20 PM',
      courseCode: 'CSE 321',
      courseName: 'Computer Architecture',
      batch: '22 Batch · Section A',
      classType: 'Theory',
      room: 'Room 302',
      source: 'Official',
      status: 'Next',
      icon: Icons.memory_rounded,
    ),
    _ScheduleEntry(
      dayIndex: 4,
      time: '2:00 PM',
      endTime: '3:40 PM',
      courseCode: 'CSE 333',
      courseName: 'Computer Networks',
      batch: '23 Batch · Section B',
      classType: 'Practical',
      room: 'Network Lab',
      source: 'Manual',
      status: 'Upcoming',
      icon: Icons.lan_rounded,
    ),
  ];

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
              _buildSourceInformation(),
              const SizedBox(height: AppSpacing.large),
              _buildViewControls(),
              const SizedBox(height: AppSpacing.large),
              if (_showWeekView) _buildWeekView() else _buildDayView(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Schedule',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: AppSpacing.small),
              Text(
                'View official classes and manage your own classes.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.medium),
        FilledButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => const Scaffold(
                  backgroundColor: AppColors.background,
                  body: SafeArea(child: TeacherAddClassScreen()),
                ),
              ),
            );
          },
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add class'),
        ),
      ],
    );
  }

  Widget _buildSourceInformation() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.regular),
      decoration: BoxDecoration(
        color: AppColors.informationBackground,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.primary),
          SizedBox(width: AppSpacing.medium),
          Expanded(
            child: Text(
              'Official classes are assigned by the coordinator. '
              'Manual classes are created by you and can be edited or deleted.',
              style: TextStyle(color: AppColors.textSecondary, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewControls() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: AppSpacing.small,
                children: [
                  ChoiceChip(
                    label: const Text('Day'),
                    avatar: const Icon(Icons.view_day_outlined, size: 18),
                    selected: !_showWeekView,
                    onSelected: (_) {
                      setState(() => _showWeekView = false);
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Week'),
                    avatar: const Icon(
                      Icons.calendar_view_week_rounded,
                      size: 18,
                    ),
                    selected: _showWeekView,
                    onSelected: (_) {
                      setState(() => _showWeekView = true);
                    },
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _showMessage('Previous week selected.'),
              tooltip: 'Previous week',
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            const Text(
              '3–7 August 2026',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            IconButton(
              onPressed: () => _showMessage('Next week selected.'),
              tooltip: 'Next week',
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
        if (!_showWeekView) ...[
          const SizedBox(height: AppSpacing.regular),
          SizedBox(
            height: 46,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _days.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(width: AppSpacing.small),
              itemBuilder: (context, index) {
                return ChoiceChip(
                  label: Text(_days[index]),
                  selected: _selectedDay == index,
                  onSelected: (_) {
                    setState(() => _selectedDay = index);
                  },
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDayView() {
    final dayClasses = _classes
        .where((schedule) => schedule.dayIndex == _selectedDay)
        .toList();

    if (dayClasses.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.extraLarge),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.large),
          border: Border.all(color: AppColors.border),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.event_available_outlined,
              size: 54,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: AppSpacing.medium),
            Text(
              'No classes scheduled',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (int index = 0; index < dayClasses.length; index++) ...[
          _ScheduleCard(schedule: dayClasses[index], onAction: _showMessage),
          if (index < dayClasses.length - 1)
            const SizedBox(height: AppSpacing.medium),
        ],
      ],
    );
  }

  Widget _buildWeekView() {
    return SizedBox(
      height: 510,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _days.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.medium),
        itemBuilder: (context, dayIndex) {
          final dayClasses = _classes
              .where((schedule) => schedule.dayIndex == dayIndex)
              .toList();

          return SizedBox(
            width: 290,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.medium),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.large),
                border: Border.all(
                  color: dayIndex == 4 ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _days[dayIndex],
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  if (dayClasses.isEmpty)
                    const Text(
                      'No classes',
                      style: TextStyle(color: AppColors.textTertiary),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        itemCount: dayClasses.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.small),
                        itemBuilder: (context, index) {
                          return _WeekClassCard(schedule: dayClasses[index]);
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ScheduleCard extends StatelessWidget {
  final _ScheduleEntry schedule;
  final ValueChanged<String> onAction;

  const _ScheduleCard({required this.schedule, required this.onAction});

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 82,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule.time,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSpacing.extraSmall),
                Text(
                  schedule.endTime,
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.informationBackground,
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Icon(schedule.icon, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.medium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${schedule.courseCode} · ${schedule.classType}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSpacing.extraSmall),
                Text(
                  schedule.courseName,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.small),
                Wrap(
                  spacing: AppSpacing.medium,
                  runSpacing: AppSpacing.small,
                  children: [
                    _Information(
                      icon: Icons.groups_rounded,
                      text: schedule.batch,
                    ),
                    _Information(
                      icon: Icons.location_on_outlined,
                      text: schedule.room,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.medium),
                Wrap(
                  spacing: AppSpacing.small,
                  runSpacing: AppSpacing.small,
                  children: [
                    _Label(
                      text: schedule.source,
                      color: schedule.source == 'Official'
                          ? AppColors.primary
                          : AppColors.warning,
                      background: schedule.source == 'Official'
                          ? AppColors.informationBackground
                          : AppColors.warningBackground,
                    ),
                    _Label(
                      text: schedule.status,
                      color: schedule.status == 'Completed'
                          ? AppColors.success
                          : AppColors.primary,
                      background: schedule.status == 'Completed'
                          ? AppColors.successBackground
                          : AppColors.informationBackground,
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'attendance') {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const Scaffold(
                      backgroundColor: AppColors.background,
                      body: SafeArea(child: TeacherCreateAttendanceScreen()),
                    ),
                  ),
                );
              } else if (value == 'edit') {
                onAction('Opening Edit Class preview.');
              } else {
                onAction('Opening class details preview.');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'attendance',
                child: Text('Start attendance'),
              ),
              const PopupMenuItem(
                value: 'details',
                child: Text('View details'),
              ),
              if (schedule.source != 'Official')
                const PopupMenuItem(value: 'edit', child: Text('Edit class')),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeekClassCard extends StatelessWidget {
  final _ScheduleEntry schedule;

  const _WeekClassCard({required this.schedule});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${schedule.time}–${schedule.endTime}',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            schedule.courseCode,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.extraSmall),
          Text(
            '${schedule.classType} · ${schedule.batch}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: AppSpacing.extraSmall),
          Text(
            schedule.room,
            style: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _Information extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Information({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: AppColors.textTertiary),
        const SizedBox(width: AppSpacing.extraSmall),
        Text(
          text,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  final Color color;
  final Color background;

  const _Label({
    required this.text,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.small,
        vertical: AppSpacing.extraSmall,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ScheduleEntry {
  final int dayIndex;
  final String time;
  final String endTime;
  final String courseCode;
  final String courseName;
  final String batch;
  final String classType;
  final String room;
  final String source;
  final String status;
  final IconData icon;

  const _ScheduleEntry({
    required this.dayIndex,
    required this.time,
    required this.endTime,
    required this.courseCode,
    required this.courseName,
    required this.batch,
    required this.classType,
    required this.room,
    required this.source,
    required this.status,
    required this.icon,
  });
}
