import 'package:flutter/material.dart';
import 'package:trackademic/core/theme/app_colors.dart';
import 'package:trackademic/core/theme/app_dimensions.dart';

class TeacherAddClassScreen extends StatefulWidget {
  const TeacherAddClassScreen({super.key});

  @override
  State<TeacherAddClassScreen> createState() => _TeacherAddClassScreenState();
}

class _TeacherAddClassScreenState extends State<TeacherAddClassScreen> {
  final _formKey = GlobalKey<FormState>();
  final _roomController = TextEditingController(text: 'Room 302');

  String _course = 'CSE 333 · Computer Networks';
  String _batch = '23 Batch';
  String _section = 'Section B';
  String _classType = 'Theory';

  DateTime _date = DateTime(2026, 8, 7);
  TimeOfDay _startTime = const TimeOfDay(hour: 11, minute: 30);
  TimeOfDay _endTime = const TimeOfDay(hour: 12, minute: 20);

  bool _repeatWeekly = true;

  static const _courses = [
    'CSE 315 · Software Engineering',
    'CSE 321 · Computer Architecture',
    'CSE 333 · Computer Networks',
  ];

  static const _batches = ['22 Batch', '23 Batch', '24 Batch'];

  static const _sections = ['Section A', 'Section B'];

  static const _classTypes = ['Theory', 'Practical', 'Makeup'];

  @override
  void dispose() {
    _roomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.large),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: AppSpacing.large),
              _buildInformationBanner(),
              const SizedBox(height: AppSpacing.large),
              _buildFormCard(),
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
          tooltip: 'Back to schedule',
          onPressed: () {
            Navigator.of(context).maybePop();
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: AppSpacing.small),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Class',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: AppSpacing.small),
              Text(
                'Add an extra, makeup, or manually scheduled class.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInformationBanner() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.regular),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.warning),
          const SizedBox(width: AppSpacing.small),
          const Expanded(
            child: Text(
              'This class will be shown in the schedule overview and can be adjusted manually if needed.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
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
              'Class information',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: AppSpacing.large),
            LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = constraints.maxWidth >= 700
                    ? (constraints.maxWidth - AppSpacing.regular) / 2
                    : constraints.maxWidth;

                return Wrap(
                  spacing: AppSpacing.regular,
                  runSpacing: AppSpacing.regular,
                  children: [
                    SizedBox(
                      width: itemWidth,
                      child: _buildDropdown(
                        label: 'Course',
                        icon: Icons.menu_book_rounded,
                        value: _course,
                        items: _courses,
                        onChanged: (value) {
                          setState(() => _course = value);
                        },
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _buildDropdown(
                        label: 'Batch',
                        icon: Icons.groups_rounded,
                        value: _batch,
                        items: _batches,
                        onChanged: (value) {
                          setState(() => _batch = value);
                        },
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _buildDropdown(
                        label: 'Section',
                        icon: Icons.class_outlined,
                        value: _section,
                        items: _sections,
                        onChanged: (value) {
                          setState(() => _section = value);
                        },
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _buildDropdown(
                        label: 'Class type',
                        icon: Icons.category_outlined,
                        value: _classType,
                        items: _classTypes,
                        onChanged: (value) {
                          setState(() => _classType = value);
                        },
                      ),
                    ),
                    SizedBox(width: itemWidth, child: _buildDateField()),
                    SizedBox(
                      width: itemWidth,
                      child: TextFormField(
                        controller: _roomController,
                        decoration: const InputDecoration(
                          labelText: 'Room or laboratory',
                          prefixIcon: Icon(Icons.location_on_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter a room or laboratory';
                          }

                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _buildTimeField(
                        label: 'Start time',
                        icon: Icons.schedule_rounded,
                        time: _startTime,
                        onTap: () => _pickTime(isStartTime: true),
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _buildTimeField(
                        label: 'End time',
                        icon: Icons.schedule_outlined,
                        time: _endTime,
                        onTap: () => _pickTime(isStartTime: false),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.large),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Repeat every week',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              subtitle: const Text(
                'Automatically place this class on your weekly schedule.',
              ),
              value: _repeatWeekly,
              onChanged: (value) {
                setState(() => _repeatWeekly = value);
              },
            ),
            const SizedBox(height: AppSpacing.large),
            const Divider(),
            const SizedBox(height: AppSpacing.medium),
            Wrap(
              spacing: AppSpacing.small,
              runSpacing: AppSpacing.small,
              children: [
                OutlinedButton.icon(
                  onPressed: _checkConflicts,
                  icon: const Icon(Icons.warning_amber_rounded),
                  label: const Text('Check conflicts'),
                ),
                FilledButton.icon(
                  onPressed: _saveClass,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save class'),
                ),
              ],
            ),
          ],
        ),
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
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: (newValue) {
        if (newValue != null) {
          onChanged(newValue);
        }
      },
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: _pickDate,
      borderRadius: BorderRadius.circular(AppRadius.medium),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Class date',
          prefixIcon: Icon(Icons.calendar_month_outlined),
          border: OutlineInputBorder(),
        ),
        child: Text(_formattedDate),
      ),
    );
  }

  Widget _buildTimeField({
    required String label,
    required IconData icon,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.medium),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        child: Text(time.format(context)),
      ),
    );
  }

  String get _formattedDate {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${_date.day} ${months[_date.month - 1]} ${_date.year}';
  }

  Future<void> _pickDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2026),
      lastDate: DateTime(2030),
    );

    if (!mounted || selectedDate == null) {
      return;
    }

    setState(() => _date = selectedDate);
  }

  Future<void> _pickTime({required bool isStartTime}) async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );

    if (!mounted || selectedTime == null) {
      return;
    }

    setState(() {
      if (isStartTime) {
        _startTime = selectedTime;
      } else {
        _endTime = selectedTime;
      }
    });
  }

  void _checkConflicts() {
    _showConflictDialog(allowSaving: false);
  }

  void _saveClass() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _showConflictDialog(allowSaving: true);
  }

  Future<void> _showConflictDialog({required bool allowSaving}) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.warning,
            size: 38,
          ),
          title: const Text('Schedule conflict found'),
          content: const Text(
            'Room 302 is already occupied from 11:30 AM to 12:20 PM. '
            'You also have CSE 321 scheduled at this time.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Go back'),
            ),
            if (allowSaving)
              FilledButton(
                onPressed: () {
                  Navigator.pop(dialogContext);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Manual class saved in the UI preview.'),
                    ),
                  );
                },
                child: const Text('Save anyway'),
              ),
          ],
        );
      },
    );
  }
}
