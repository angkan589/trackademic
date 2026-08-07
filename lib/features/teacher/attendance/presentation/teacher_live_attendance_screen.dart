import 'dart:async';

import 'package:flutter/material.dart';
import 'package:trackademic/core/theme/app_colors.dart';
import 'package:trackademic/core/theme/app_dimensions.dart';
import 'package:trackademic/features/teacher/attendance/presentation/teacher_attendance_summary_screen.dart';

class TeacherLiveAttendanceScreen extends StatefulWidget {
  final String course;
  final String batch;
  final String classType;
  final int durationMinutes;
  final String? passcode;
  final int? gpsRadius;

  const TeacherLiveAttendanceScreen({
    required this.course,
    required this.batch,
    required this.classType,
    required this.durationMinutes,
    required this.passcode,
    required this.gpsRadius,
    super.key,
  });

  @override
  State<TeacherLiveAttendanceScreen> createState() =>
      _TeacherLiveAttendanceScreenState();
}

class _TeacherLiveAttendanceScreenState
    extends State<TeacherLiveAttendanceScreen> {
  late Duration _remainingTime;
  Timer? _timer;

  final _searchController = TextEditingController();

  List<_LiveStudent> _eligibleStudents = [];

  bool _endingSession = false;
  String _searchQuery = '';

  static const List<_RosterStudent> _studentDirectory = [
    // CSE 22 Batch · Section A
    _RosterStudent(
      id: '2204001',
      name: 'Afsana Rahman',
      department: 'CSE',
      batch: '22',
      section: 'A',
      enrolledCourses: {'CSE 315', 'CSE 321', 'CSE 333'},
    ),
    _RosterStudent(
      id: '2204002',
      name: 'Tanvir Hasan',
      department: 'CSE',
      batch: '22',
      section: 'A',
      enrolledCourses: {'CSE 315', 'CSE 321', 'CSE 333'},
    ),
    _RosterStudent(
      id: '2204003',
      name: 'Nabila Islam',
      department: 'CSE',
      batch: '22',
      section: 'A',
      enrolledCourses: {'CSE 315', 'CSE 321', 'CSE 333'},
    ),
    _RosterStudent(
      id: '2204004',
      name: 'Mehedi Chowdhury',
      department: 'CSE',
      batch: '22',
      section: 'A',
      enrolledCourses: {'CSE 315', 'CSE 321'},
    ),
    _RosterStudent(
      id: '2204005',
      name: 'Nusrat Jahan',
      department: 'CSE',
      batch: '22',
      section: 'A',
      enrolledCourses: {'CSE 315', 'CSE 321', 'CSE 333'},
    ),
    _RosterStudent(
      id: '2204006',
      name: 'Sadman Sakib',
      department: 'CSE',
      batch: '22',
      section: 'A',
      enrolledCourses: {'CSE 315', 'CSE 321', 'CSE 333'},
    ),
    _RosterStudent(
      id: '2204007',
      name: 'Farhan Ahmed',
      department: 'CSE',
      batch: '22',
      section: 'A',
      enrolledCourses: {'CSE 321', 'CSE 333'},
    ),
    _RosterStudent(
      id: '2204008',
      name: 'Rafia Karim',
      department: 'CSE',
      batch: '22',
      section: 'A',
      enrolledCourses: {'CSE 315', 'CSE 321', 'CSE 333'},
    ),

    // CSE 22 Batch · Section B
    _RosterStudent(
      id: '2204051',
      name: 'Arman Hossain',
      department: 'CSE',
      batch: '22',
      section: 'B',
      enrolledCourses: {'CSE 315', 'CSE 321', 'CSE 333'},
    ),
    _RosterStudent(
      id: '2204052',
      name: 'Tasnia Akter',
      department: 'CSE',
      batch: '22',
      section: 'B',
      enrolledCourses: {'CSE 315', 'CSE 321', 'CSE 333'},
    ),
    _RosterStudent(
      id: '2204053',
      name: 'Fahim Rahman',
      department: 'CSE',
      batch: '22',
      section: 'B',
      enrolledCourses: {'CSE 315', 'CSE 321'},
    ),

    // CSE 23 Batch · Section A
    _RosterStudent(
      id: '2304001',
      name: 'Sadia Islam',
      department: 'CSE',
      batch: '23',
      section: 'A',
      enrolledCourses: {'CSE 315', 'CSE 321', 'CSE 333'},
    ),
    _RosterStudent(
      id: '2304002',
      name: 'Mahin Ahmed',
      department: 'CSE',
      batch: '23',
      section: 'A',
      enrolledCourses: {'CSE 315', 'CSE 321', 'CSE 333'},
    ),

    // Different department — must not appear in a CSE session
    _RosterStudent(
      id: '2203001',
      name: 'Tahmid Alam',
      department: 'EEE',
      batch: '22',
      section: 'A',
      enrolledCourses: {'EEE 321'},
    ),
  ];

  String get _courseCode {
    return widget.course.split(' · ').first.trim();
  }

  String get _department {
    return _courseCode.split(' ').first.trim();
  }

  String get _batchNumber {
    return widget.batch.split(' ').first.trim();
  }

  String get _section {
    final match = RegExp(r'Section\s+(.+)$').firstMatch(widget.batch);

    return match?.group(1)?.trim() ?? '';
  }

  int get _presentCount {
    return _eligibleStudents
        .where((student) => student.status == AttendanceStatus.present)
        .length;
  }

  int get _lateCount {
    return _eligibleStudents
        .where((student) => student.status == AttendanceStatus.late)
        .length;
  }

  int get _absentCount {
    return _eligibleStudents
        .where((student) => student.status == AttendanceStatus.absent)
        .length;
  }

  int get _waitingCount {
    return _eligibleStudents
        .where((student) => student.status == AttendanceStatus.waiting)
        .length;
  }

  List<_LiveStudent> get _visibleStudents {
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return _eligibleStudents;
    }

    return _eligibleStudents.where((student) {
      return student.name.toLowerCase().contains(query) ||
          student.id.toLowerCase().contains(query) ||
          _statusLabel(student.status).toLowerCase().contains(query);
    }).toList();
  }

  double get _timeProgress {
    final totalSeconds = widget.durationMinutes * 60;

    if (totalSeconds <= 0) {
      return 0;
    }

    final remainingRatio = (_remainingTime.inSeconds / totalSeconds).clamp(
      0.0,
      1.0,
    );

    return (1.0 - remainingRatio).toDouble();
  }

  String get _formattedRemainingTime {
    final totalSeconds = _remainingTime.inSeconds;

    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    final minuteText = minutes.toString().padLeft(2, '0');
    final secondText = seconds.toString().padLeft(2, '0');

    if (hours > 0) {
      final hourText = hours.toString().padLeft(2, '0');
      return '$hourText:$minuteText:$secondText';
    }

    return '$minuteText:$secondText';
  }

  @override
  void initState() {
    super.initState();

    _remainingTime = Duration(minutes: widget.durationMinutes);

    _loadEligibleStudents();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _loadEligibleStudents() {
    final filteredRoster = _studentDirectory.where((student) {
      final sameDepartment =
          student.department.toUpperCase() == _department.toUpperCase();

      final sameBatch = student.batch == _batchNumber;
      final sameSection =
          student.section.toUpperCase() == _section.toUpperCase();

      final enrolledInCourse = student.enrolledCourses.contains(_courseCode);

      return sameDepartment && sameBatch && sameSection && enrolledInCourse;
    }).toList();

    _eligibleStudents = [
      for (int index = 0; index < filteredRoster.length; index++)
        _LiveStudent(
          id: filteredRoster[index].id,
          name: filteredRoster[index].name,

          // These statuses simulate incoming student submissions.
          status: index < 2
              ? AttendanceStatus.present
              : index == 2
              ? AttendanceStatus.late
              : AttendanceStatus.waiting,
          submittedAt: index < 3
              ? DateTime.now().subtract(Duration(minutes: index + 1))
              : null,
        ),
    ];
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_remainingTime.inSeconds <= 1) {
        timer.cancel();

        setState(() {
          _remainingTime = Duration.zero;
        });

        _finishSession(showConfirmation: false);
        return;
      }

      setState(() {
        _remainingTime -= const Duration(seconds: 1);
      });
    });
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
              _buildEligibilityBanner(),
              const SizedBox(height: AppSpacing.large),
              _buildMetricCards(),
              const SizedBox(height: AppSpacing.large),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth >= 850) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 7, child: _buildRosterCard()),
                        const SizedBox(width: AppSpacing.regular),
                        Expanded(flex: 4, child: _buildSessionCard()),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      _buildSessionCard(),
                      const SizedBox(height: AppSpacing.regular),
                      _buildRosterCard(),
                    ],
                  );
                },
              ),
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
        IconButton(
          tooltip: 'Back',
          onPressed: _goBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: AppSpacing.small),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Live Attendance',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: AppSpacing.extraSmall),
              Text(
                widget.course,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: AppSpacing.extraSmall),
              Text(
                '${widget.batch} · ${widget.classType}',
                style: const TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.medium),
        FilledButton.icon(
          onPressed: _endingSession
              ? null
              : () {
                  _finishSession(showConfirmation: true);
                },
          icon: const Icon(Icons.stop_circle_outlined),
          label: const Text('End session'),
        ),
      ],
    );
  }

  Widget _buildEligibilityBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.regular),
      decoration: BoxDecoration(
        color: AppColors.informationBackground,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.verified_user_outlined, color: AppColors.primary),
          const SizedBox(width: AppSpacing.medium),
          Expanded(
            child: Text(
              'Eligible roster: $_department department · '
              '$_batchNumber batch · Section $_section · '
              'Enrolled in $_courseCode. Students outside this '
              'roster are not included in this session.',
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth;

        if (constraints.maxWidth >= 800) {
          cardWidth = (constraints.maxWidth - AppSpacing.regular * 3) / 4;
        } else if (constraints.maxWidth >= 500) {
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
              child: _MetricCard(
                label: 'Eligible students',
                value: '${_eligibleStudents.length}',
                icon: Icons.groups_rounded,
                color: AppColors.primary,
                background: AppColors.informationBackground,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _MetricCard(
                label: 'Present',
                value: '$_presentCount',
                icon: Icons.check_circle_outline_rounded,
                color: AppColors.success,
                background: AppColors.successBackground,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _MetricCard(
                label: 'Late',
                value: '$_lateCount',
                icon: Icons.more_time_rounded,
                color: AppColors.warning,
                background: AppColors.warningBackground,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _MetricCard(
                label: 'Waiting',
                value: '$_waitingCount',
                icon: Icons.hourglass_top_rounded,
                color: AppColors.textSecondary,
                background: AppColors.background,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRosterCard() {
    final students = _visibleStudents;

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
            'Eligible student roster',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.extraSmall),
          Text(
            '${_eligibleStudents.length} students matched the '
            'selected class information.',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: AppSpacing.large),
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search by name, ID, or status',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchQuery.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      onPressed: () {
                        _searchController.clear();

                        setState(() {
                          _searchQuery = '';
                        });
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.regular),
          if (students.isEmpty)
            _buildEmptyRoster()
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: students.length,
              separatorBuilder: (context, index) {
                return const Divider(height: 1);
              },
              itemBuilder: (context, index) {
                return _buildStudentRow(students[index]);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyRoster() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.extraLarge),
      child: const Column(
        children: [
          Icon(
            Icons.person_search_rounded,
            color: AppColors.textTertiary,
            size: 44,
          ),
          SizedBox(height: AppSpacing.medium),
          Text(
            'No matching students found',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentRow(_LiveStudent student) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.medium),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.informationBackground,
            child: Text(
              _initials(student.name),
              style: const TextStyle(
                color: AppColors.primary,
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
                  student.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.extraSmall),
                Text(
                  student.submittedAt == null
                      ? 'ID: ${student.id}'
                      : 'ID: ${student.id} · '
                            '${_formatSubmissionTime(student.submittedAt!)}',
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.small),
          _StatusChip(status: student.status),
          PopupMenuButton<AttendanceStatus>(
            tooltip: 'Update attendance status',
            onSelected: (status) {
              _updateStudentStatus(student, status);
            },
            itemBuilder: (context) {
              return [
                _buildStatusMenuItem(
                  AttendanceStatus.present,
                  'Mark present',
                  Icons.check_circle_outline_rounded,
                ),
                _buildStatusMenuItem(
                  AttendanceStatus.late,
                  'Mark late',
                  Icons.more_time_rounded,
                ),
                _buildStatusMenuItem(
                  AttendanceStatus.absent,
                  'Mark absent',
                  Icons.person_off_outlined,
                ),
                _buildStatusMenuItem(
                  AttendanceStatus.waiting,
                  'Reset to waiting',
                  Icons.hourglass_top_rounded,
                ),
              ];
            },
          ),
        ],
      ),
    );
  }

  PopupMenuItem<AttendanceStatus> _buildStatusMenuItem(
    AttendanceStatus status,
    String label,
    IconData icon,
  ) {
    return PopupMenuItem<AttendanceStatus>(
      value: status,
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: AppSpacing.small),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildSessionCard() {
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
            'Active session',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.large),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.large),
            decoration: BoxDecoration(
              color: AppColors.informationBackground,
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.timer_outlined,
                  color: AppColors.primary,
                  size: 36,
                ),
                const SizedBox(height: AppSpacing.small),
                Text(
                  _formattedRemainingTime,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Text(
                  'Time remaining',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.medium),
                LinearProgressIndicator(
                  value: _timeProgress,
                  minHeight: 8,
                  color: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  borderRadius: BorderRadius.circular(100),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.large),
          if (widget.passcode != null) ...[
            _SessionDetail(
              icon: Icons.password_rounded,
              label: 'Attendance passcode',
              value: widget.passcode!,
            ),
            const SizedBox(height: AppSpacing.medium),
          ],
          _SessionDetail(
            icon: Icons.my_location_rounded,
            label: 'GPS verification',
            value: widget.gpsRadius == null
                ? 'Disabled'
                : '${widget.gpsRadius} metre radius',
          ),
          const SizedBox(height: AppSpacing.medium),
          _SessionDetail(
            icon: Icons.verified_user_outlined,
            label: 'Roster protection',
            value:
                '$_department · $_batchNumber Batch · '
                'Section $_section · $_courseCode',
          ),
          const SizedBox(height: AppSpacing.large),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _endingSession
                  ? null
                  : () {
                      _finishSession(showConfirmation: true);
                    },
              icon: _endingSession
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.stop_circle_outlined),
              label: Text(_endingSession ? 'Ending session...' : 'End session'),
            ),
          ),
        ],
      ),
    );
  }

  void _updateStudentStatus(_LiveStudent student, AttendanceStatus status) {
    setState(() {
      student.status = status;

      if (status == AttendanceStatus.present ||
          status == AttendanceStatus.late) {
        student.submittedAt = DateTime.now();
      } else {
        student.submittedAt = null;
      }
    });
  }

  Future<void> _goBack() async {
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.warning,
          ),
          title: const Text('Leave live session?'),
          content: const Text(
            'The attendance session is still active. '
            'Leaving will cancel this live view.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Stay'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Leave'),
            ),
          ],
        );
      },
    );

    if (shouldLeave == true && mounted) {
      _timer?.cancel();
      Navigator.of(context).pop();
    }
  }

  Future<void> _finishSession({required bool showConfirmation}) async {
    if (_endingSession) {
      return;
    }

    if (showConfirmation) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            icon: const Icon(
              Icons.stop_circle_outlined,
              color: AppColors.primary,
              size: 42,
            ),
            title: const Text('End attendance session?'),
            content: Text(
              '$_waitingCount students have not submitted yet. '
              'They will be marked absent.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext, false);
                },
                child: const Text('Continue session'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(dialogContext, true);
                },
                child: const Text('End now'),
              ),
            ],
          );
        },
      );

      if (confirmed != true) {
        return;
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _endingSession = true;

      for (final student in _eligibleStudents) {
        if (student.status == AttendanceStatus.waiting) {
          student.status = AttendanceStatus.absent;
          student.submittedAt = null;
        }
      }
    });

    _timer?.cancel();

    final totalStudents = _eligibleStudents.length;
    final presentCount = _presentCount;
    final lateCount = _lateCount;
    final absentCount = _absentCount;

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (context) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: TeacherAttendanceSummaryScreen(
                course: widget.course,
                batch: widget.batch,
                classType: widget.classType,
                durationMinutes: widget.durationMinutes,
                totalStudents: totalStudents,
                presentCount: presentCount,
                lateCount: lateCount,
                absentCount: absentCount,
              ),
            ),
          );
        },
      ),
    );
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(' ')
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return '?';
    }

    return parts.take(2).map((part) => part[0].toUpperCase()).join();
  }

  String _formatSubmissionTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return 'Submitted at $hour:$minute';
  }

  String _statusLabel(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.late:
        return 'Late';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.waiting:
        return 'Waiting';
    }
  }
}

enum AttendanceStatus { waiting, present, late, absent }

class _RosterStudent {
  final String id;
  final String name;
  final String department;
  final String batch;
  final String section;
  final Set<String> enrolledCourses;

  const _RosterStudent({
    required this.id,
    required this.name,
    required this.department,
    required this.batch,
    required this.section,
    required this.enrolledCourses,
  });
}

class _LiveStudent {
  final String id;
  final String name;

  AttendanceStatus status;
  DateTime? submittedAt;

  _LiveStudent({
    required this.id,
    required this.name,
    required this.status,
    required this.submittedAt,
  });
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color background;

  const _MetricCard({
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

class _StatusChip extends StatelessWidget {
  final AttendanceStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    late final String label;
    late final Color foreground;
    late final Color background;

    switch (status) {
      case AttendanceStatus.present:
        label = 'Present';
        foreground = AppColors.success;
        background = AppColors.successBackground;

      case AttendanceStatus.late:
        label = 'Late';
        foreground = AppColors.warning;
        background = AppColors.warningBackground;

      case AttendanceStatus.absent:
        label = 'Absent';
        foreground = const Color(0xFFDC2626);
        background = const Color(0xFFFFEBEE);

      case AttendanceStatus.waiting:
        label = 'Waiting';
        foreground = AppColors.textSecondary;
        background = AppColors.background;
    }

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
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SessionDetail extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SessionDetail({
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
