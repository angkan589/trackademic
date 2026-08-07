import 'package:flutter/material.dart';
import 'package:trackademic/core/theme/app_colors.dart';
import 'package:trackademic/core/theme/app_dimensions.dart';
import 'package:trackademic/features/teacher/attendance/presentation/teacher_live_attendance_screen.dart';

class TeacherCreateAttendanceScreen extends StatefulWidget {
  const TeacherCreateAttendanceScreen({super.key});

  @override
  State<TeacherCreateAttendanceScreen> createState() =>
      _TeacherCreateAttendanceScreenState();
}

class _TeacherCreateAttendanceScreenState
    extends State<TeacherCreateAttendanceScreen> {
  final _formKey = GlobalKey<FormState>();

  final _radiusController = TextEditingController(text: '100');
  final _customDurationController = TextEditingController();

  String _selectedClass = 'CSE 321 · Computer Architecture';
  String _selectedBatch = '22 Batch · Section A';
  String _selectedType = 'Theory';

  int _duration = 15;
  bool _usingCustomDuration = false;

  bool _requireGps = true;
  bool _requirePasscode = true;
  bool _allowLateEntry = false;

  String _passcode = '482731';

  static const _classes = [
    'CSE 315 · Software Engineering',
    'CSE 321 · Computer Architecture',
    'CSE 333 · Computer Networks',
  ];

  static const _batches = [
    '22 Batch · Section A',
    '22 Batch · Section B',
    '23 Batch · Section A',
    '23 Batch · Section B',
  ];

  static const _classTypes = ['Theory', 'Practical', 'Makeup'];

  @override
  void dispose() {
    _radiusController.dispose();
    _customDurationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.large),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: AppSpacing.large),
              _buildInformationBanner(),
              const SizedBox(height: AppSpacing.large),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth >= 820) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 6, child: _buildSetupCard()),
                        const SizedBox(width: AppSpacing.regular),
                        Expanded(flex: 4, child: _buildPreviewCard()),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      _buildSetupCard(),
                      const SizedBox(height: AppSpacing.regular),
                      _buildPreviewCard(),
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
          'Create Attendance',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: AppSpacing.small),
        Text(
          'Start a secure GPS and passcode-based attendance session.',
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
          Icon(Icons.security_rounded, color: AppColors.primary),
          SizedBox(width: AppSpacing.medium),
          Expanded(
            child: Text(
              'Students must satisfy the enabled verification methods before '
              'their attendance is accepted.',
              style: TextStyle(color: AppColors.textSecondary, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetupCard() {
    return Container(
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
            const Text(
              'Session setup',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: AppSpacing.large),

            // Course
            _buildDropdown(
              label: 'Course',
              icon: Icons.menu_book_rounded,
              value: _selectedClass,
              items: _classes,
              onChanged: (value) {
                setState(() {
                  _selectedClass = value;
                });
              },
            ),
            const SizedBox(height: AppSpacing.regular),

            // Batch and section
            _buildDropdown(
              label: 'Batch and section',
              icon: Icons.groups_rounded,
              value: _selectedBatch,
              items: _batches,
              onChanged: (value) {
                setState(() {
                  _selectedBatch = value;
                });
              },
            ),
            const SizedBox(height: AppSpacing.regular),

            // Class type
            _buildDropdown(
              label: 'Class type',
              icon: Icons.category_outlined,
              value: _selectedType,
              items: _classTypes,
              onChanged: (value) {
                setState(() {
                  _selectedType = value;
                });
              },
            ),
            const SizedBox(height: AppSpacing.large),

            // Duration
            const Text(
              'Attendance duration',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            Wrap(
              spacing: AppSpacing.small,
              runSpacing: AppSpacing.small,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (final duration in [5, 10, 15, 20, 30])
                  ChoiceChip(
                    label: Text('$duration min'),
                    selected: !_usingCustomDuration && _duration == duration,
                    onSelected: (selected) {
                      if (!selected) {
                        return;
                      }

                      setState(() {
                        _usingCustomDuration = false;
                        _duration = duration;
                        _customDurationController.clear();
                      });
                    },
                  ),
                SizedBox(
                  width: 190,
                  child: TextFormField(
                    controller: _customDurationController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Custom time',
                      hintText: 'Example: 1',
                      suffixText: 'min',
                      prefixIcon: Icon(Icons.edit_rounded),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onTap: () {
                      if (!_usingCustomDuration) {
                        setState(() {
                          _usingCustomDuration = true;
                        });
                      }
                    },
                    onChanged: (value) {
                      final customDuration = int.tryParse(value.trim());

                      setState(() {
                        _usingCustomDuration = true;

                        if (customDuration != null &&
                            customDuration >= 1 &&
                            customDuration <= 180) {
                          _duration = customDuration;
                        }
                      });
                    },
                    validator: (value) {
                      if (!_usingCustomDuration) {
                        return null;
                      }

                      final customDuration = int.tryParse(value?.trim() ?? '');

                      if (customDuration == null ||
                          customDuration < 1 ||
                          customDuration > 180) {
                        return 'Enter 1–180 minutes';
                      }

                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.large),
            const Divider(),
            const SizedBox(height: AppSpacing.medium),

            // Verification methods
            const Text(
              'Verification methods',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: AppSpacing.small),

            // GPS
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.my_location_rounded),
              title: const Text(
                'Require GPS location',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: const Text(
                'Students must be inside the allowed attendance area.',
              ),
              value: _requireGps,
              onChanged: (value) {
                setState(() {
                  _requireGps = value;
                });
              },
            ),
            if (_requireGps) ...[
              const SizedBox(height: AppSpacing.small),
              TextFormField(
                controller: _radiusController,
                keyboardType: TextInputType.number,
                onChanged: (_) {
                  setState(() {});
                },
                decoration: const InputDecoration(
                  labelText: 'Allowed radius in metres',
                  prefixIcon: Icon(Icons.radar_rounded),
                  suffixText: 'metres',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (!_requireGps) {
                    return null;
                  }

                  final radius = int.tryParse(value?.trim() ?? '');

                  if (radius == null || radius < 10) {
                    return 'Enter a radius of at least 10 metres';
                  }

                  if (radius > 5000) {
                    return 'Radius cannot exceed 5000 metres';
                  }

                  return null;
                },
              ),
            ],
            const SizedBox(height: AppSpacing.small),

            // Passcode
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.password_rounded),
              title: const Text(
                'Require attendance passcode',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: const Text(
                'Students must enter the generated six-digit code.',
              ),
              value: _requirePasscode,
              onChanged: (value) {
                setState(() {
                  _requirePasscode = value;
                });
              },
            ),

            // Late entry
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.more_time_rounded),
              title: const Text(
                'Allow late entry',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: const Text('Late students will be marked separately.'),
              value: _allowLateEntry,
              onChanged: (value) {
                setState(() {
                  _allowLateEntry = value;
                });
              },
            ),
            const SizedBox(height: AppSpacing.large),

            // Start button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _startAttendance,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.medium),
                  child: Text('Start attendance'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard() {
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
            'Session preview',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.large),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.regular),
            decoration: BoxDecoration(
              color: AppColors.informationBackground,
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.how_to_reg_rounded,
                  color: AppColors.primary,
                  size: 42,
                ),
                const SizedBox(height: AppSpacing.medium),
                Text(
                  _selectedClass.split(' · ').first,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSpacing.extraSmall),
                Text(
                  _selectedClass.split(' · ').last,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.large),
          _PreviewItem(
            icon: Icons.groups_rounded,
            label: 'Students',
            value: _selectedBatch,
          ),
          const SizedBox(height: AppSpacing.medium),
          _PreviewItem(
            icon: Icons.category_outlined,
            label: 'Class type',
            value: _selectedType,
          ),
          const SizedBox(height: AppSpacing.medium),
          _PreviewItem(
            icon: Icons.timer_outlined,
            label: 'Duration',
            value: '$_duration minutes',
          ),
          const SizedBox(height: AppSpacing.medium),
          _PreviewItem(
            icon: Icons.my_location_rounded,
            label: 'GPS verification',
            value: _requireGps
                ? '${_radiusController.text.trim()} metre radius'
                : 'Disabled',
          ),
          const SizedBox(height: AppSpacing.medium),
          _PreviewItem(
            icon: Icons.password_rounded,
            label: 'Passcode',
            value: _requirePasscode ? _passcode : 'Disabled',
          ),
          if (_requirePasscode) ...[
            const SizedBox(height: AppSpacing.medium),
            OutlinedButton.icon(
              onPressed: _generatePasscode,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Generate new code'),
            ),
          ],
          const SizedBox(height: AppSpacing.large),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.medium),
            decoration: BoxDecoration(
              color: AppColors.successBackground,
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: const Row(
              children: [
                Icon(Icons.lock_outline_rounded, color: AppColors.success),
                SizedBox(width: AppSpacing.small),
                Expanded(
                  child: Text(
                    'The session will remain inactive until you press Start.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(value: item, child: Text(item)),
          )
          .toList(),
      onChanged: (newValue) {
        if (newValue != null) {
          onChanged(newValue);
        }
      },
    );
  }

  void _generatePasscode() {
    final generatedNumber =
        100000 + DateTime.now().millisecondsSinceEpoch.remainder(900000);

    setState(() {
      _passcode = generatedNumber.toString();
    });
  }

  Future<void> _startAttendance() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_requireGps && !_requirePasscode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enable at least one verification method.'),
        ),
      );

      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.play_circle_outline_rounded,
            color: AppColors.primary,
            size: 42,
          ),
          title: const Text('Start attendance?'),
          content: Text(
            'Attendance for $_selectedClass will remain open for '
            '$_duration minutes.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) {
                      return Scaffold(
                        backgroundColor: AppColors.background,
                        body: SafeArea(
                          child: TeacherLiveAttendanceScreen(
                            course: _selectedClass,
                            batch: _selectedBatch,
                            classType: _selectedType,
                            durationMinutes: _duration,
                            passcode: _requirePasscode ? _passcode : null,
                            gpsRadius: _requireGps
                                ? int.parse(_radiusController.text.trim())
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              child: const Text('Start now'),
            ),
          ],
        );
      },
    );
  }
}

class _PreviewItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _PreviewItem({
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
