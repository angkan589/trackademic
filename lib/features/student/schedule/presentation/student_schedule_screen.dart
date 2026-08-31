import 'package:flutter/material.dart';
import 'package:trackademic/core/theme/app_colors.dart';
import 'package:trackademic/core/theme/app_dimensions.dart';

class StudentScheduleScreen extends StatefulWidget {
  const StudentScheduleScreen({super.key});

  @override
  State<StudentScheduleScreen> createState() => _StudentScheduleScreenState();
}

class _StudentScheduleScreenState extends State<StudentScheduleScreen> {
  bool _showWeekView = false;
  int _selectedDay = 1;

  static const _days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday'];

  static const _dates = ['30 Aug', '31 Aug', '1 Sep', '2 Sep', '3 Sep'];

  static const _classes = [
    _StudentClass(
      dayIndex: 0,
      time: '9:00 AM',
      endTime: '9:50 AM',
      code: 'CSE 321',
      name: 'Computer Architecture',
      type: 'Theory',
      room: 'Room 302',
      teacher: 'Prof. Dr. Kaushik Deb',
      status: 'Scheduled',
      source: 'Official',
      icon: Icons.memory_rounded,
    ),
    _StudentClass(
      dayIndex: 1,
      time: '11:00 AM',
      endTime: '12:40 PM',
      code: 'CSE 321',
      name: 'Computer Architecture',
      type: 'Practical',
      room: 'Hardware Lab',
      teacher: 'Prof. Dr. Kaushik Deb',
      status: 'Next',
      source: 'Official',
      icon: Icons.science_outlined,
    ),
    _StudentClass(
      dayIndex: 1,
      time: '2:00 PM',
      endTime: '2:50 PM',
      code: 'CSE 333',
      name: 'Computer Networks',
      type: 'Theory',
      room: 'Room 204',
      teacher: 'Dr. Nusrat Jahan',
      status: 'Upcoming',
      source: 'Official',
      icon: Icons.router_outlined,
    ),
    _StudentClass(
      dayIndex: 2,
      time: '9:00 AM',
      endTime: '9:50 AM',
      code: 'CSE 315',
      name: 'Software Engineering',
      type: 'Theory',
      room: 'Room 204',
      teacher: 'Prof. Dr. Kaushik Deb',
      status: 'Scheduled',
      source: 'Official',
      icon: Icons.developer_board_rounded,
    ),
    _StudentClass(
      dayIndex: 3,
      time: '10:00 AM',
      endTime: '11:40 AM',
      code: 'CSE 315',
      name: 'Software Engineering',
      type: 'Practical',
      room: 'Software Lab 2',
      teacher: 'Prof. Dr. Kaushik Deb',
      status: 'Rescheduled',
      source: 'Updated',
      icon: Icons.computer_rounded,
    ),
    _StudentClass(
      dayIndex: 4,
      time: '9:00 AM',
      endTime: '9:50 AM',
      code: 'CSE 315',
      name: 'Software Engineering',
      type: 'Theory',
      room: 'Room 204',
      teacher: 'Prof. Dr. Kaushik Deb',
      status: 'Scheduled',
      source: 'Official',
      icon: Icons.developer_board_rounded,
    ),
    _StudentClass(
      dayIndex: 4,
      time: '11:30 AM',
      endTime: '12:20 PM',
      code: 'CSE 321',
      name: 'Computer Architecture',
      type: 'Theory',
      room: 'Room 302',
      teacher: 'Prof. Dr. Kaushik Deb',
      status: 'Scheduled',
      source: 'Official',
      icon: Icons.memory_rounded,
    ),
  ];

  List<_StudentClass> get _selectedClasses {
    if (_showWeekView) {
      return _classes;
    }

    return _classes.where((item) {
      return item.dayIndex == _selectedDay;
    }).toList();
  }

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
              const _ScheduleUpdateBanner(),
              const SizedBox(height: AppSpacing.large),
              _buildSummaryCards(),
              const SizedBox(height: AppSpacing.large),
              _buildViewControls(),
              const SizedBox(height: AppSpacing.large),
              _buildScheduleCard(),
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
          'Class Schedule',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: AppSpacing.small),
        Text(
          'View your regular classes and recently '
          'updated schedules.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth;

        if (constraints.maxWidth >= 800) {
          cardWidth = (constraints.maxWidth - AppSpacing.regular * 2) / 3;
        } else if (constraints.maxWidth >= 520) {
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
              child: const _SummaryCard(
                label: 'Classes this week',
                value: '7',
                icon: Icons.calendar_month_rounded,
                foreground: AppColors.primary,
                background: AppColors.informationBackground,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: const _SummaryCard(
                label: 'Classes today',
                value: '2',
                icon: Icons.today_rounded,
                foreground: AppColors.success,
                background: AppColors.successBackground,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: const _SummaryCard(
                label: 'Recent updates',
                value: '1',
                icon: Icons.update_rounded,
                foreground: AppColors.warning,
                background: AppColors.warningBackground,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildViewControls() {
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
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment<bool>(
                value: false,
                icon: Icon(Icons.view_day_outlined),
                label: Text('Day'),
              ),
              ButtonSegment<bool>(
                value: true,
                icon: Icon(Icons.view_week_outlined),
                label: Text('Week'),
              ),
            ],
            selected: {_showWeekView},
            onSelectionChanged: (selection) {
              setState(() {
                _showWeekView = selection.first;
              });
            },
          ),
          if (!_showWeekView) ...[
            const SizedBox(height: AppSpacing.regular),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (int index = 0; index < _days.length; index++) ...[
                    ChoiceChip(
                      selected: _selectedDay == index,
                      onSelected: (_) {
                        setState(() {
                          _selectedDay = index;
                        });
                      },
                      label: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_days[index]),
                          Text(
                            _dates[index],
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    if (index < _days.length - 1)
                      const SizedBox(width: AppSpacing.small),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScheduleCard() {
    final classes = _selectedClasses;

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
            _showWeekView
                ? 'Weekly schedule'
                : '${_days[_selectedDay]} · '
                      '${_dates[_selectedDay]}',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.regular),
          if (classes.isEmpty)
            const _EmptySchedule()
          else
            for (int index = 0; index < classes.length; index++) ...[
              if (_showWeekView &&
                  (index == 0 ||
                      classes[index].dayIndex != classes[index - 1].dayIndex))
                Padding(
                  padding: EdgeInsets.only(
                    top: index == 0 ? 0 : AppSpacing.large,
                    bottom: AppSpacing.small,
                  ),
                  child: Text(
                    _days[classes[index].dayIndex],
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              _ScheduleEntryCard(schedule: classes[index]),
              if (index < classes.length - 1)
                const SizedBox(height: AppSpacing.medium),
            ],
        ],
      ),
    );
  }
}

class _ScheduleUpdateBanner extends StatelessWidget {
  const _ScheduleUpdateBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.regular),
      decoration: BoxDecoration(
        color: AppColors.warningBackground,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.update_rounded, color: AppColors.warning),
          SizedBox(width: AppSpacing.medium),
          Expanded(
            child: Text(
              'Schedule update: Wednesday’s CSE 315 '
              'practical class is now at 10:00 AM '
              'in Software Lab 2.',
              style: TextStyle(color: AppColors.textSecondary, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color foreground;
  final Color background;

  const _SummaryCard({
    required this.label,
    required this.value,
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
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Icon(icon, color: foreground),
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

class _ScheduleEntryCard extends StatelessWidget {
  final _StudentClass schedule;

  const _ScheduleEntryCard({required this.schedule});

  @override
  Widget build(BuildContext context) {
    final isUpdated = schedule.status == 'Rescheduled';
    final isNext = schedule.status == 'Next';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.regular),
      decoration: BoxDecoration(
        color: isUpdated
            ? AppColors.warningBackground
            : isNext
            ? AppColors.informationBackground
            : AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: isUpdated
              ? AppColors.warning
              : isNext
              ? AppColors.primary
              : AppColors.border,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final timeBox = Container(
            width: 72,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.small,
              vertical: AppSpacing.medium,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: Column(
              children: [
                Text(
                  schedule.time,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSpacing.extraSmall),
                Text(
                  schedule.endTime,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          );

          final information = Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(schedule.icon, color: AppColors.primary, size: 20),
                    const SizedBox(width: AppSpacing.small),
                    Expanded(
                      child: Text(
                        '${schedule.code} · ${schedule.name}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.small),
                Text(
                  '${schedule.type} · ${schedule.room}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.extraSmall),
                Text(
                  schedule.teacher,
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                Wrap(
                  spacing: AppSpacing.small,
                  runSpacing: AppSpacing.small,
                  children: [
                    _StatusLabel(
                      text: schedule.status,
                      foreground: isUpdated
                          ? AppColors.warning
                          : isNext
                          ? AppColors.primary
                          : AppColors.success,
                      background: isUpdated
                          ? AppColors.warningBackground
                          : isNext
                          ? AppColors.informationBackground
                          : AppColors.successBackground,
                    ),
                    _StatusLabel(
                      text: schedule.source,
                      foreground: schedule.source == 'Official'
                          ? AppColors.primary
                          : AppColors.warning,
                      background: schedule.source == 'Official'
                          ? AppColors.informationBackground
                          : AppColors.warningBackground,
                    ),
                  ],
                ),
              ],
            ),
          );

          if (constraints.maxWidth >= 500) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                timeBox,
                const SizedBox(width: AppSpacing.regular),
                information,
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              timeBox,
              const SizedBox(height: AppSpacing.medium),
              Row(children: [information]),
            ],
          );
        },
      ),
    );
  }
}

class _StatusLabel extends StatelessWidget {
  final String text;
  final Color foreground;
  final Color background;

  const _StatusLabel({
    required this.text,
    required this.foreground,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.medium,
        vertical: AppSpacing.extraSmall,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.circular),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: foreground,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _EmptySchedule extends StatelessWidget {
  const _EmptySchedule();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.extraLarge),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.event_available_rounded,
            color: AppColors.textTertiary,
            size: 48,
          ),
          SizedBox(height: AppSpacing.medium),
          Text(
            'No classes scheduled',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentClass {
  final int dayIndex;
  final String time;
  final String endTime;
  final String code;
  final String name;
  final String type;
  final String room;
  final String teacher;
  final String status;
  final String source;
  final IconData icon;

  const _StudentClass({
    required this.dayIndex,
    required this.time,
    required this.endTime,
    required this.code,
    required this.name,
    required this.type,
    required this.room,
    required this.teacher,
    required this.status,
    required this.source,
    required this.icon,
  });
}
