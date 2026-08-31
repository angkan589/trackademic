import 'package:flutter/material.dart';
import 'package:trackademic/core/theme/app_colors.dart';
import 'package:trackademic/core/theme/app_dimensions.dart';

class StudentMarksScreen extends StatefulWidget {
  const StudentMarksScreen({super.key});

  @override
  State<StudentMarksScreen> createState() => _StudentMarksScreenState();
}

class _StudentMarksScreenState extends State<StudentMarksScreen> {
  String _selectedCourseCode = 'CSE 315';

  static const _courses = [
    _CourseMarks(
      code: 'CSE 315',
      name: 'Software Engineering',
      ct1: 17,
      ct2: 18,
      attendancePercentage: 94,
    ),
    _CourseMarks(
      code: 'CSE 321',
      name: 'Computer Architecture',
      ct1: 16,
      attendancePercentage: 92,
    ),
    _CourseMarks(
      code: 'CSE 333',
      name: 'Computer Networks',
      ct1: 15,
      ct2: 17,
      ct3: 16,
      attendancePercentage: 86,
    ),
  ];

  _CourseMarks get _selectedCourse {
    return _courses.firstWhere((course) => course.code == _selectedCourseCode);
  }

  @override
  Widget build(BuildContext context) {
    final course = _selectedCourse;

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
              _buildCourseSelector(),
              const SizedBox(height: AppSpacing.large),
              _buildSummaryCards(course),
              const SizedBox(height: AppSpacing.large),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth >= 820) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 6, child: _MarksCard(course: course)),
                        const SizedBox(width: AppSpacing.regular),
                        Expanded(
                          flex: 4,
                          child: _AttendanceMarkCard(course: course),
                        ),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      _MarksCard(course: course),
                      const SizedBox(height: AppSpacing.regular),
                      _AttendanceMarkCard(course: course),
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
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Marks',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: AppSpacing.small),
        Text(
          'Review your published CT marks and '
          'calculated attendance marks.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildCourseSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedCourseCode,
        decoration: const InputDecoration(
          labelText: 'Course',
          prefixIcon: Icon(Icons.menu_book_rounded),
        ),
        items: _courses.map((course) {
          return DropdownMenuItem<String>(
            value: course.code,
            child: Text('${course.code} · ${course.name}'),
          );
        }).toList(),
        onChanged: (value) {
          if (value == null) {
            return;
          }

          setState(() {
            _selectedCourseCode = value;
          });
        },
      ),
    );
  }

  Widget _buildSummaryCards(_CourseMarks course) {
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
                label: 'CT average',
                value: course.ctAverage == null
                    ? 'Not available'
                    : '${_formatMark(course.ctAverage!)}/20',
                icon: Icons.analytics_rounded,
                foreground: AppColors.primary,
                background: AppColors.informationBackground,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _SummaryCard(
                label: 'Published CTs',
                value: '${course.publishedCtCount}/3',
                icon: Icons.assignment_turned_in_rounded,
                foreground: AppColors.success,
                background: AppColors.successBackground,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _SummaryCard(
                label: 'Attendance mark',
                value: '${_formatMark(course.attendanceMark)}/10',
                icon: Icons.calculate_rounded,
                foreground: AppColors.warning,
                background: AppColors.warningBackground,
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatMark(double mark) {
    if (mark == mark.roundToDouble()) {
      return mark.toStringAsFixed(0);
    }

    return mark.toStringAsFixed(1);
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
              'Only you and authorized teachers can view '
              'these marks. Unpublished assessments remain hidden.',
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
                    fontSize: 21,
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

class _MarksCard extends StatelessWidget {
  final _CourseMarks course;

  const _MarksCard({required this.course});

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
            '${course.code} assessment results',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.extraSmall),
          Text(
            course.name,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.regular),
          _MarkRow(label: 'CT 1', mark: course.ct1, maximum: 20),
          const Divider(),
          _MarkRow(label: 'CT 2', mark: course.ct2, maximum: 20),
          const Divider(),
          _MarkRow(label: 'CT 3', mark: course.ct3, maximum: 20),
          const Divider(),
          _MarkRow(
            label: 'Attendance',
            mark: course.attendanceMark,
            maximum: 30,
            automaticallyCalculated: true,
          ),
        ],
      ),
    );
  }
}

class _MarkRow extends StatelessWidget {
  final String label;
  final double? mark;
  final int maximum;
  final bool automaticallyCalculated;

  const _MarkRow({
    required this.label,
    required this.mark,
    required this.maximum,
    this.automaticallyCalculated = false,
  });

  @override
  Widget build(BuildContext context) {
    final published = mark != null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.medium),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: published
                  ? AppColors.successBackground
                  : AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: Icon(
              automaticallyCalculated
                  ? Icons.calculate_rounded
                  : Icons.assignment_outlined,
              color: published ? AppColors.success : AppColors.textTertiary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.medium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  automaticallyCalculated
                      ? 'Calculated from attendance percentage'
                      : published
                      ? 'Published by teacher'
                      : 'Not published yet',
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.medium),
          if (published)
            Text(
              '${_formatMark(mark!)}/$maximum',
              style: const TextStyle(
                color: AppColors.success,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.medium,
                vertical: AppSpacing.extraSmall,
              ),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppRadius.circular),
              ),
              child: const Text(
                'Pending',
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatMark(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(1);
  }
}

class _AttendanceMarkCard extends StatelessWidget {
  final _CourseMarks course;

  const _AttendanceMarkCard({required this.course});

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
          const Text(
            'Attendance-mark calculation',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.large),
          Center(
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.successBackground,
                border: Border.all(color: AppColors.success, width: 8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${course.attendancePercentage.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Text(
                    'attendance',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.large),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.regular),
            decoration: BoxDecoration(
              color: AppColors.successBackground,
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Column(
              children: [
                const Text(
                  'Calculated attendance mark',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.small),
                Text(
                  '${_formatMark(course.attendanceMark)}/30',
                  style: const TextStyle(
                    color: AppColors.success,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.regular),
          const Text(
            '90% or above = 30 marks\n'
            '85%–89% = 25 marks\n'
            '80%–84% = 20 marks\n'
            '75%–79% = 15 marks\n'
            '70%–74% = 10 marks\n'
            'Below 70% = 0 marks',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  String _formatMark(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(1);
  }
}

class _CourseMarks {
  final String code;
  final String name;
  final double? ct1;
  final double? ct2;
  final double? ct3;
  final double attendancePercentage;

  const _CourseMarks({
    required this.code,
    required this.name,
    required this.attendancePercentage,
    this.ct1,
    this.ct2,
    this.ct3,
  });

  int get publishedCtCount {
    return [ct1, ct2, ct3].whereType<double>().length;
  }

  double? get ctAverage {
    final marks = [ct1, ct2, ct3].whereType<double>().toList();

    if (marks.isEmpty) {
      return null;
    }

    final total = marks.fold<double>(0, (sum, mark) => sum + mark);

    return total / marks.length;
  }

  double get attendanceMark {
    if (attendancePercentage >= 90) {
      return 30;
    }

    if (attendancePercentage >= 85) {
      return 25;
    }

    if (attendancePercentage >= 80) {
      return 20;
    }

    if (attendancePercentage >= 75) {
      return 15;
    }

    if (attendancePercentage >= 70) {
      return 10;
    }

    return 0;
  }
}
