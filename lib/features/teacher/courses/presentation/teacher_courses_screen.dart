import 'package:flutter/material.dart';
import 'package:trackademic/core/theme/app_colors.dart';
import 'package:trackademic/core/theme/app_dimensions.dart';
import 'package:trackademic/features/teacher/attendance/presentation/teacher_create_attendance_screen.dart';

class TeacherCoursesScreen extends StatefulWidget {
  const TeacherCoursesScreen({super.key});

  @override
  State<TeacherCoursesScreen> createState() => _TeacherCoursesScreenState();
}

class _TeacherCoursesScreenState extends State<TeacherCoursesScreen> {
  final _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedBatch = 'All';

  static const List<_CourseData> _courses = [
    _CourseData(
      code: 'CSE 315',
      name: 'Software Engineering',
      batch: '22 Batch',
      section: 'A',
      students: 47,
      completedSessions: 18,
      attendanceAverage: 88,
      room: 'Room 204',
      schedule: 'Sunday & Tuesday · 10:00 AM',
      roster: [
        _StudentData(id: '2204001', name: 'Afsana Rahman', attendance: 94),
        _StudentData(id: '2204002', name: 'Tanvir Hasan', attendance: 89),
        _StudentData(id: '2204003', name: 'Nabila Islam', attendance: 91),
        _StudentData(id: '2204004', name: 'Mehedi Chowdhury', attendance: 76),
      ],
    ),
    _CourseData(
      code: 'CSE 321',
      name: 'Computer Architecture',
      batch: '22 Batch',
      section: 'A',
      students: 46,
      completedSessions: 16,
      attendanceAverage: 84,
      room: 'Room 302',
      schedule: 'Monday & Thursday · 11:30 AM',
      roster: [
        _StudentData(id: '2204005', name: 'Nusrat Jahan', attendance: 93),
        _StudentData(id: '2204006', name: 'Sadman Sakib', attendance: 87),
        _StudentData(id: '2204007', name: 'Farhan Ahmed', attendance: 79),
        _StudentData(id: '2204008', name: 'Rafia Karim', attendance: 90),
      ],
    ),
    _CourseData(
      code: 'CSE 333',
      name: 'Computer Networks',
      batch: '23 Batch',
      section: 'B',
      students: 52,
      completedSessions: 14,
      attendanceAverage: 81,
      room: 'Network Lab',
      schedule: 'Wednesday & Thursday · 2:00 PM',
      roster: [
        _StudentData(id: '2304051', name: 'Maliha Ahmed', attendance: 88),
        _StudentData(id: '2304052', name: 'Raiyan Chowdhury', attendance: 82),
        _StudentData(id: '2304053', name: 'Sanjida Karim', attendance: 75),
        _StudentData(id: '2304054', name: 'Arif Hossain', attendance: 85),
      ],
    ),
  ];

  List<_CourseData> get _visibleCourses {
    final query = _searchQuery.trim().toLowerCase();

    return _courses.where((course) {
      final matchesBatch =
          _selectedBatch == 'All' || course.batch == _selectedBatch;

      final matchesSearch =
          query.isEmpty ||
          course.code.toLowerCase().contains(query) ||
          course.name.toLowerCase().contains(query) ||
          course.batch.toLowerCase().contains(query) ||
          course.section.toLowerCase().contains(query);

      return matchesBatch && matchesSearch;
    }).toList();
  }

  int get _totalStudents {
    return _courses.fold(0, (total, course) => total + course.students);
  }

  double get _averageAttendance {
    if (_courses.isEmpty) {
      return 0;
    }

    final total = _courses.fold<double>(
      0,
      (sum, course) => sum + course.attendanceAverage,
    );

    return total / _courses.length;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
              _buildInformationBanner(),
              const SizedBox(height: AppSpacing.large),
              _buildSummaryCards(),
              const SizedBox(height: AppSpacing.large),
              _buildCourseSection(),
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
          'My Courses',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: AppSpacing.small),
        Text(
          'View assigned courses and enrolled student information.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildInformationBanner() {
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
          Icon(Icons.verified_user_outlined, color: AppColors.primary),
          SizedBox(width: AppSpacing.medium),
          Expanded(
            child: Text(
              'Only courses assigned to the signed-in teacher are shown. '
              'Course and enrollment data currently use mock information.',
              style: TextStyle(color: AppColors.textSecondary, height: 1.45),
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
              child: _SummaryCard(
                label: 'Assigned courses',
                value: '${_courses.length}',
                icon: Icons.menu_book_rounded,
                iconColor: AppColors.primary,
                iconBackground: AppColors.informationBackground,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _SummaryCard(
                label: 'Enrolled students',
                value: '$_totalStudents',
                icon: Icons.groups_rounded,
                iconColor: AppColors.success,
                iconBackground: AppColors.successBackground,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _SummaryCard(
                label: 'Average attendance',
                value: '${_averageAttendance.toStringAsFixed(0)}%',
                icon: Icons.trending_up_rounded,
                iconColor: AppColors.warning,
                iconBackground: AppColors.warningBackground,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCourseSection() {
    final visibleCourses = _visibleCourses;

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
            'Course list',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.extraSmall),
          Text(
            '${visibleCourses.length} matching courses',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: AppSpacing.large),
          _buildControls(),
          const SizedBox(height: AppSpacing.large),
          if (visibleCourses.isEmpty)
            _buildEmptyState()
          else
            _buildCourseGrid(visibleCourses),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final searchField = TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Search by course, batch, or section',
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
          ),
        );

        final filters = Wrap(
          spacing: AppSpacing.small,
          runSpacing: AppSpacing.small,
          children: [
            for (final batch in ['All', '22 Batch', '23 Batch'])
              ChoiceChip(
                label: Text(batch),
                selected: _selectedBatch == batch,
                onSelected: (selected) {
                  if (!selected) {
                    return;
                  }

                  setState(() {
                    _selectedBatch = batch;
                  });
                },
              ),
          ],
        );

        if (constraints.maxWidth >= 720) {
          return Row(
            children: [
              Expanded(child: searchField),
              const SizedBox(width: AppSpacing.regular),
              filters,
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            searchField,
            const SizedBox(height: AppSpacing.medium),
            filters,
          ],
        );
      },
    );
  }

  Widget _buildCourseGrid(List<_CourseData> courses) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth;

        if (constraints.maxWidth >= 760) {
          cardWidth = (constraints.maxWidth - AppSpacing.regular) / 2;
        } else {
          cardWidth = constraints.maxWidth;
        }

        return Wrap(
          spacing: AppSpacing.regular,
          runSpacing: AppSpacing.regular,
          children: [
            for (final course in courses)
              SizedBox(
                width: cardWidth,
                child: _CourseCard(
                  course: course,
                  onViewCourse: () {
                    _showCourseDetails(course);
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.extraLarge),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.search_off_rounded,
            color: AppColors.textTertiary,
            size: 48,
          ),
          const SizedBox(height: AppSpacing.medium),
          const Text(
            'No matching courses',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          const Text(
            'Try another search or batch filter.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.medium),
          TextButton(
            onPressed: () {
              _searchController.clear();

              setState(() {
                _searchQuery = '';
                _selectedBatch = 'All';
              });
            },
            child: const Text('Reset filters'),
          ),
        ],
      ),
    );
  }

  Future<void> _showCourseDetails(_CourseData course) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.informationBackground,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.medium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(course.code),
                    Text(
                      course.name,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 560,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailRow(
                    icon: Icons.groups_outlined,
                    label: 'Batch and section',
                    value: '${course.batch} · Section ${course.section}',
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  _DetailRow(
                    icon: Icons.location_on_outlined,
                    label: 'Classroom',
                    value: course.room,
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  _DetailRow(
                    icon: Icons.schedule_rounded,
                    label: 'Regular schedule',
                    value: course.schedule,
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  _DetailRow(
                    icon: Icons.fact_check_outlined,
                    label: 'Attendance average',
                    value: '${course.attendanceAverage.toStringAsFixed(0)}%',
                  ),
                  const SizedBox(height: AppSpacing.large),
                  const Divider(),
                  const SizedBox(height: AppSpacing.large),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Enrolled students',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Text(
                        'Showing ${course.roster.length} of '
                        '${course.students}',
                        style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                    ),
                    child: Column(
                      children: [
                        for (
                          int index = 0;
                          index < course.roster.length;
                          index++
                        ) ...[
                          _StudentRow(student: course.roster[index]),
                          if (index < course.roster.length - 1) const Divider(),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Close'),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext);

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
              icon: const Icon(Icons.how_to_reg_rounded),
              label: const Text('Create attendance'),
            ),
          ],
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
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
              color: iconBackground,
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Icon(icon, color: iconColor),
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
                    fontSize: 23,
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

class _CourseCard extends StatelessWidget {
  final _CourseData course;
  final VoidCallback onViewCourse;

  const _CourseCard({required this.course, required this.onViewCourse});

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.informationBackground,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.medium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.code,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.extraSmall),
                    Text(
                      course.name,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.small,
                  vertical: AppSpacing.extraSmall,
                ),
                decoration: BoxDecoration(
                  color: AppColors.successBackground,
                  borderRadius: BorderRadius.circular(AppRadius.circular),
                ),
                child: const Text(
                  'Active',
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.regular),
          _CourseInformation(
            icon: Icons.groups_rounded,
            text: '${course.batch} · Section ${course.section}',
          ),
          const SizedBox(height: AppSpacing.small),
          _CourseInformation(
            icon: Icons.location_on_outlined,
            text: course.room,
          ),
          const SizedBox(height: AppSpacing.small),
          _CourseInformation(
            icon: Icons.schedule_rounded,
            text: course.schedule,
          ),
          const SizedBox(height: AppSpacing.regular),
          Container(
            padding: const EdgeInsets.all(AppSpacing.medium),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _MiniMetric(
                        label: 'Students',
                        value: '${course.students}',
                      ),
                    ),
                    Container(width: 1, height: 35, color: AppColors.border),
                    Expanded(
                      child: _MiniMetric(
                        label: 'Sessions',
                        value: '${course.completedSessions}',
                      ),
                    ),
                    Container(width: 1, height: 35, color: AppColors.border),
                    Expanded(
                      child: _MiniMetric(
                        label: 'Attendance',
                        value:
                            '${course.attendanceAverage.toStringAsFixed(0)}%',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.medium),
                LinearProgressIndicator(
                  value: course.attendanceAverage / 100,
                  minHeight: 7,
                  color: AppColors.primary,
                  backgroundColor: AppColors.border,
                  borderRadius: BorderRadius.circular(AppRadius.circular),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.regular),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onViewCourse,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('View course'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseInformation extends StatelessWidget {
  final IconData icon;
  final String text;

  const _CourseInformation({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textTertiary),
        const SizedBox(width: AppSpacing.small),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final String label;
  final String value;

  const _MiniMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: AppSpacing.extraSmall),
        Text(
          label,
          style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
        ),
      ],
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
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.informationBackground,
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: AppSpacing.medium),
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

class _StudentRow extends StatelessWidget {
  final _StudentData student;

  const _StudentRow({required this.student});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.medium),
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
                Text(
                  'ID: ${student.id}',
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${student.attendance.toStringAsFixed(0)}%',
            style: TextStyle(
              color: student.attendance >= 75
                  ? AppColors.success
                  : AppColors.danger,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(' ')
        .where((part) => part.isNotEmpty)
        .take(2);

    return parts.map((part) => part[0].toUpperCase()).join();
  }
}

class _CourseData {
  final String code;
  final String name;
  final String batch;
  final String section;
  final int students;
  final int completedSessions;
  final double attendanceAverage;
  final String room;
  final String schedule;
  final List<_StudentData> roster;

  const _CourseData({
    required this.code,
    required this.name,
    required this.batch,
    required this.section,
    required this.students,
    required this.completedSessions,
    required this.attendanceAverage,
    required this.room,
    required this.schedule,
    required this.roster,
  });
}

class _StudentData {
  final String id;
  final String name;
  final double attendance;

  const _StudentData({
    required this.id,
    required this.name,
    required this.attendance,
  });
}
