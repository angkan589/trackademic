import 'package:flutter/material.dart';
import 'package:trackademic/core/theme/app_colors.dart';
import 'package:trackademic/core/theme/app_dimensions.dart';

class TeacherMarksScreen extends StatefulWidget {
  const TeacherMarksScreen({super.key});

  @override
  State<TeacherMarksScreen> createState() => _TeacherMarksScreenState();
}

class _TeacherMarksScreenState extends State<TeacherMarksScreen> {
  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();

  String _selectedCourse = 'CSE 315 · Software Engineering';
  String _selectedAssessment = 'CT 1';
  String _searchQuery = '';

  final Set<String> _publishedAssessments = {};

  final Map<String, List<_StudentMark>> _studentsByCourse = {
    'CSE 315 · Software Engineering': [
      _StudentMark(
        id: '2204001',
        name: 'Afsana Rahman',
        ct1: 17,
        ct2: 18,
        attendancePercentage: 94,
      ),
      _StudentMark(
        id: '2204002',
        name: 'Tanvir Hasan',
        ct1: 15,
        ct2: 16,
        attendancePercentage: 89,
      ),
      _StudentMark(
        id: '2204003',
        name: 'Nabila Islam',
        ct1: 18,
        ct2: 17,
        attendancePercentage: 91,
      ),
      _StudentMark(
        id: '2204004',
        name: 'Mehedi Chowdhury',
        ct1: 12,
        ct2: 14,
        attendancePercentage: 76,
      ),
      _StudentMark(
        id: '2204005',
        name: 'Nusrat Jahan',
        ct1: 16,
        ct2: 18,
        attendancePercentage: 93,
      ),
      _StudentMark(
        id: '2204006',
        name: 'Sadman Sakib',
        ct1: 14,
        ct2: 15,
        attendancePercentage: 87,
      ),
      _StudentMark(
        id: '2204007',
        name: 'Farhan Ahmed',
        ct1: 11,
        ct2: 13,
        attendancePercentage: 79,
      ),
      _StudentMark(
        id: '2204008',
        name: 'Rafia Karim',
        ct1: 19,
        ct2: 18,
        attendancePercentage: 90,
      ),
    ],
    'CSE 321 · Computer Architecture': [
      _StudentMark(
        id: '2204001',
        name: 'Afsana Rahman',
        ct1: 16,
        attendancePercentage: 92,
      ),
      _StudentMark(
        id: '2204002',
        name: 'Tanvir Hasan',
        ct1: 14,
        attendancePercentage: 85,
      ),
      _StudentMark(
        id: '2204003',
        name: 'Nabila Islam',
        ct1: 18,
        attendancePercentage: 90,
      ),
      _StudentMark(
        id: '2204004',
        name: 'Mehedi Chowdhury',
        ct1: 13,
        attendancePercentage: 74,
      ),
      _StudentMark(
        id: '2204005',
        name: 'Nusrat Jahan',
        ct1: 17,
        attendancePercentage: 95,
      ),
      _StudentMark(
        id: '2204006',
        name: 'Sadman Sakib',
        ct1: 15,
        attendancePercentage: 88,
      ),
      _StudentMark(
        id: '2204007',
        name: 'Farhan Ahmed',
        ct1: 12,
        attendancePercentage: 78,
      ),
      _StudentMark(
        id: '2204008',
        name: 'Rafia Karim',
        ct1: 18,
        attendancePercentage: 91,
      ),
    ],
    'CSE 333 · Computer Networks': [
      _StudentMark(
        id: '2304051',
        name: 'Maliha Ahmed',
        ct1: 18,
        attendancePercentage: 88,
      ),
      _StudentMark(
        id: '2304052',
        name: 'Raiyan Chowdhury',
        ct1: 15,
        attendancePercentage: 82,
      ),
      _StudentMark(
        id: '2304053',
        name: 'Sanjida Karim',
        ct1: 13,
        attendancePercentage: 75,
      ),
      _StudentMark(
        id: '2304054',
        name: 'Arif Hossain',
        ct1: 16,
        attendancePercentage: 85,
      ),
      _StudentMark(
        id: '2304055',
        name: 'Tasnia Akter',
        ct1: 17,
        attendancePercentage: 93,
      ),
      _StudentMark(
        id: '2304056',
        name: 'Fahim Rahman',
        ct1: 14,
        attendancePercentage: 80,
      ),
    ],
  };

  List<_StudentMark> get _selectedStudents {
    return _studentsByCourse[_selectedCourse] ?? [];
  }

  List<_StudentMark> get _visibleStudents {
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return _selectedStudents;
    }

    return _selectedStudents.where((student) {
      return student.name.toLowerCase().contains(query) ||
          student.id.toLowerCase().contains(query);
    }).toList();
  }

  bool get _isAttendanceAssessment {
    return _selectedAssessment == 'Attendance';
  }

  double get _maximumMark {
    return _isAttendanceAssessment ? 10 : 20;
  }

  String get _publicationKey {
    return '$_selectedCourse|$_selectedAssessment';
  }

  bool get _isPublished {
    return _publishedAssessments.contains(_publicationKey);
  }

  int get _missingMarkCount {
    if (_isAttendanceAssessment) {
      return 0;
    }

    return _selectedStudents.where((student) {
      return student.markFor(_selectedAssessment) == null;
    }).length;
  }

  double get _classAverage {
    final marks = _selectedStudents
        .map((student) => _markForStudent(student))
        .whereType<double>()
        .where((mark) => mark >= 0 && mark <= _maximumMark)
        .toList();

    if (marks.isEmpty) {
      return 0;
    }

    final total = marks.fold<double>(0, (sum, mark) => sum + mark);

    return total / marks.length;
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
              _buildSelectors(),
              const SizedBox(height: AppSpacing.large),
              _buildSummaryCards(),
              const SizedBox(height: AppSpacing.large),
              _buildMarksCard(),
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
                'Marks Management',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: AppSpacing.small),
              Text(
                'Enter, review, and publish student academic marks.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.medium),
        if (_isPublished)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.medium,
              vertical: AppSpacing.small,
            ),
            decoration: BoxDecoration(
              color: AppColors.successBackground,
              borderRadius: BorderRadius.circular(AppRadius.circular),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  color: AppColors.success,
                  size: 18,
                ),
                SizedBox(width: AppSpacing.small),
                Text(
                  'Published',
                  style: TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildInformationBanner() {
    final message = _isAttendanceAssessment
        ? 'Attendance marks are calculated automatically from each '
              'student’s attendance percentage. They cannot be edited manually.'
        : 'Enter marks from 0 to 20. You can save incomplete marks as a '
              'draft, but every student must have a valid mark before publishing.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.regular),
      decoration: BoxDecoration(
        color: _isAttendanceAssessment
            ? AppColors.successBackground
            : AppColors.informationBackground,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _isAttendanceAssessment
                ? Icons.calculate_outlined
                : Icons.info_outline_rounded,
            color: _isAttendanceAssessment
                ? AppColors.success
                : AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.medium),
          Expanded(
            child: Text(
              message,
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

  Widget _buildSelectors() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final courseDropdown = DropdownButtonFormField<String>(
            initialValue: _selectedCourse,
            decoration: const InputDecoration(
              labelText: 'Course',
              prefixIcon: Icon(Icons.menu_book_rounded),
            ),
            items: _studentsByCourse.keys.map((course) {
              return DropdownMenuItem<String>(
                value: course,
                child: Text(course),
              );
            }).toList(),
            onChanged: (value) {
              if (value == null) {
                return;
              }

              _searchController.clear();

              setState(() {
                _selectedCourse = value;
                _searchQuery = '';
              });
            },
          );

          final assessmentDropdown = DropdownButtonFormField<String>(
            initialValue: _selectedAssessment,
            decoration: const InputDecoration(
              labelText: 'Assessment',
              prefixIcon: Icon(Icons.assignment_outlined),
            ),
            items: const [
              DropdownMenuItem(value: 'CT 1', child: Text('CT 1 · 20 marks')),
              DropdownMenuItem(value: 'CT 2', child: Text('CT 2 · 20 marks')),
              DropdownMenuItem(value: 'CT 3', child: Text('CT 3 · 20 marks')),
              DropdownMenuItem(
                value: 'Attendance',
                child: Text('Attendance · 10 marks'),
              ),
            ],
            onChanged: (value) {
              if (value == null) {
                return;
              }

              setState(() {
                _selectedAssessment = value;
              });
            },
          );

          if (constraints.maxWidth >= 720) {
            return Row(
              children: [
                Expanded(child: courseDropdown),
                const SizedBox(width: AppSpacing.regular),
                Expanded(child: assessmentDropdown),
              ],
            );
          }

          return Column(
            children: [
              courseDropdown,
              const SizedBox(height: AppSpacing.regular),
              assessmentDropdown,
            ],
          );
        },
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
                label: 'Students',
                value: '${_selectedStudents.length}',
                icon: Icons.groups_rounded,
                foreground: AppColors.primary,
                background: AppColors.informationBackground,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _SummaryCard(
                label: 'Class average',
                value:
                    '${_classAverage.toStringAsFixed(1)}/${_maximumMark.toStringAsFixed(0)}',
                icon: Icons.analytics_outlined,
                foreground: AppColors.success,
                background: AppColors.successBackground,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _SummaryCard(
                label: 'Missing marks',
                value: '$_missingMarkCount',
                icon: Icons.pending_actions_outlined,
                foreground: _missingMarkCount == 0
                    ? AppColors.success
                    : AppColors.warning,
                background: _missingMarkCount == 0
                    ? AppColors.successBackground
                    : AppColors.warningBackground,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMarksCard() {
    final students = _visibleStudents;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.border),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$_selectedAssessment marks',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  'Maximum ${_maximumMark.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
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
                hintText: 'Search by student name or ID',
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
            ),
            const SizedBox(height: AppSpacing.large),
            if (students.isEmpty)
              _buildEmptyState()
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: students.length,
                separatorBuilder: (context, index) {
                  return const Divider();
                },
                itemBuilder: (context, index) {
                  return _buildStudentMarkRow(students[index]);
                },
              ),
            const SizedBox(height: AppSpacing.large),
            const Divider(),
            const SizedBox(height: AppSpacing.large),
            LayoutBuilder(
              builder: (context, constraints) {
                final saveButton = OutlinedButton.icon(
                  onPressed: _isPublished ? null : _saveDraft,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save draft'),
                );

                final publishButton = FilledButton.icon(
                  onPressed: _isPublished ? null : _publishMarks,
                  icon: const Icon(Icons.publish_rounded),
                  label: Text(
                    _isPublished ? 'Marks published' : 'Publish marks',
                  ),
                );

                if (constraints.maxWidth >= 520) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      saveButton,
                      const SizedBox(width: AppSpacing.medium),
                      publishButton,
                    ],
                  );
                }

                return Column(
                  children: [
                    SizedBox(width: double.infinity, child: saveButton),
                    const SizedBox(height: AppSpacing.medium),
                    SizedBox(width: double.infinity, child: publishButton),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentMarkRow(_StudentMark student) {
    final mark = _markForStudent(student);

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
                  _isAttendanceAssessment
                      ? 'ID: ${student.id} · '
                            '${student.attendancePercentage.toStringAsFixed(0)}% attendance'
                      : 'ID: ${student.id}',
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.medium),
          if (_isAttendanceAssessment)
            Container(
              width: 90,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.medium,
                vertical: AppSpacing.small,
              ),
              decoration: BoxDecoration(
                color: AppColors.successBackground,
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
              child: Text(
                '${_formatMark(mark ?? 0)}/10',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.w900,
                ),
              ),
            )
          else
            SizedBox(
              width: 105,
              child: TextFormField(
                key: ValueKey(
                  '${student.id}|$_selectedCourse|$_selectedAssessment',
                ),
                initialValue: mark == null ? '' : _formatMark(mark),
                enabled: !_isPublished,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  suffixText: '/${_maximumMark.toStringAsFixed(0)}',
                  isDense: true,
                ),
                onChanged: (value) {
                  final parsedMark = double.tryParse(value.trim());

                  setState(() {
                    student.updateMark(_selectedAssessment, parsedMark);
                  });
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return null;
                  }

                  final parsedMark = double.tryParse(value.trim());

                  if (parsedMark == null ||
                      parsedMark < 0 ||
                      parsedMark > _maximumMark) {
                    return '0-${_maximumMark.toStringAsFixed(0)}';
                  }

                  return null;
                },
              ),
            ),
        ],
      ),
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
      child: const Column(
        children: [
          Icon(
            Icons.person_search_rounded,
            color: AppColors.textTertiary,
            size: 48,
          ),
          SizedBox(height: AppSpacing.medium),
          Text(
            'No matching students',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  void _saveDraft() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$_selectedAssessment marks saved as draft.')),
    );
  }

  Future<void> _publishMarks() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_isAttendanceAssessment) {
      final hasInvalidMark = _selectedStudents.any((student) {
        final mark = student.markFor(_selectedAssessment);

        return mark == null || mark < 0 || mark > _maximumMark;
      });

      if (hasInvalidMark) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Enter a valid mark for every student before publishing.',
            ),
          ),
        );

        return;
      }
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.publish_rounded,
            color: AppColors.primary,
            size: 40,
          ),
          title: const Text('Publish marks?'),
          content: Text(
            'Publish $_selectedAssessment marks for '
            '$_selectedCourse? Students will be able to view them.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Publish'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _publishedAssessments.add(_publicationKey);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$_selectedAssessment marks were published successfully.',
        ),
      ),
    );
  }

  double? _markForStudent(_StudentMark student) {
    if (_isAttendanceAssessment) {
      return _calculateAttendanceMark(student.attendancePercentage);
    }

    return student.markFor(_selectedAssessment);
  }

  double _calculateAttendanceMark(double percentage) {
    if (percentage >= 90) {
      return 10;
    }

    if (percentage >= 85) {
      return 9;
    }

    if (percentage >= 80) {
      return 8;
    }

    if (percentage >= 75) {
      return 7;
    }

    if (percentage >= 70) {
      return 6;
    }

    return 0;
  }

  String _formatMark(double mark) {
    if (mark == mark.roundToDouble()) {
      return mark.toStringAsFixed(0);
    }

    return mark.toStringAsFixed(1);
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

class _StudentMark {
  final String id;
  final String name;
  final double attendancePercentage;

  double? ct1;
  double? ct2;
  double? ct3;

  _StudentMark({
    required this.id,
    required this.name,
    required this.attendancePercentage,
    this.ct1,
    this.ct2,
  });

  double? markFor(String assessment) {
    switch (assessment) {
      case 'CT 1':
        return ct1;
      case 'CT 2':
        return ct2;
      case 'CT 3':
        return ct3;
      default:
        return null;
    }
  }

  void updateMark(String assessment, double? mark) {
    switch (assessment) {
      case 'CT 1':
        ct1 = mark;
      case 'CT 2':
        ct2 = mark;
      case 'CT 3':
        ct3 = mark;
    }
  }
}
