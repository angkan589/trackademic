import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trackademic/core/theme/app_colors.dart';
import 'package:trackademic/core/theme/app_dimensions.dart';

class StudentAttendanceScreen extends StatefulWidget {
  const StudentAttendanceScreen({super.key});

  @override
  State<StudentAttendanceScreen> createState() =>
      _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends State<StudentAttendanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passcodeController = TextEditingController();

  bool _locationVerified = false;
  bool _attendanceMarked = false;

  static const _activePasscode = '482731';

  @override
  void dispose() {
    _passcodeController.dispose();
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
              _buildSummaryCards(),
              const SizedBox(height: AppSpacing.large),
              _buildMainContent(),
              const SizedBox(height: AppSpacing.large),
              const _AttendanceHistoryCard(),
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
          'Attendance',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: AppSpacing.small),
        Text(
          'Mark attendance securely and review your attendance history.',
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
                label: 'Overall attendance',
                value: '88%',
                icon: Icons.fact_check_rounded,
                foreground: AppColors.success,
                background: AppColors.successBackground,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: const _SummaryCard(
                label: 'Classes attended',
                value: '43/49',
                icon: Icons.event_available_rounded,
                foreground: AppColors.primary,
                background: AppColors.informationBackground,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: const _SummaryCard(
                label: 'Attendance marks',
                value: '9/10',
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

  Widget _buildMainContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 820) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(flex: 5, child: _ActiveSessionCard()),
              const SizedBox(width: AppSpacing.regular),
              Expanded(flex: 5, child: _buildVerificationCard()),
            ],
          );
        }

        return Column(
          children: [
            const _ActiveSessionCard(),
            const SizedBox(height: AppSpacing.regular),
            _buildVerificationCard(),
          ],
        );
      },
    );
  }

  Widget _buildVerificationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.border),
      ),
      child: _attendanceMarked
          ? const _AttendanceMarkedState()
          : Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Verify attendance',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.small),
                  const Text(
                    'Complete both security checks before submitting.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.large),
                  _buildLocationVerification(),
                  const SizedBox(height: AppSpacing.large),
                  TextFormField(
                    controller: _passcodeController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 6,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Six-digit passcode',
                      hintText: 'Enter the code from your teacher',
                      prefixIcon: Icon(Icons.password_rounded),
                      counterText: '',
                    ),
                    validator: (value) {
                      final passcode = value?.trim() ?? '';

                      if (passcode.length != 6) {
                        return 'Enter the six-digit attendance passcode';
                      }

                      if (passcode != _activePasscode) {
                        return 'The attendance passcode is incorrect';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.large),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _markAttendance,
                      icon: const Icon(Icons.how_to_reg_rounded),
                      label: const Text('Mark attendance'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildLocationVerification() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.regular),
      decoration: BoxDecoration(
        color: _locationVerified
            ? AppColors.successBackground
            : AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: _locationVerified ? AppColors.success : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _locationVerified
                    ? Icons.location_on_rounded
                    : Icons.location_searching_rounded,
                color: _locationVerified
                    ? AppColors.success
                    : AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.small),
              Expanded(
                child: Text(
                  _locationVerified
                      ? 'Location verified'
                      : 'GPS location required',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (_locationVerified)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            _locationVerified
                ? 'You are inside the allowed 100-metre attendance area.'
                : 'Verify that you are inside the allowed 100-metre area.',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          if (!_locationVerified) ...[
            const SizedBox(height: AppSpacing.medium),
            OutlinedButton.icon(
              onPressed: _verifyLocation,
              icon: const Icon(Icons.my_location_rounded),
              label: const Text('Verify location'),
            ),
          ],
        ],
      ),
    );
  }

  void _verifyLocation() {
    setState(() {
      _locationVerified = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Location verified successfully.')),
    );
  }

  Future<void> _markAttendance() async {
    if (!_locationVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verify your GPS location first.')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.how_to_reg_rounded,
            color: AppColors.primary,
            size: 40,
          ),
          title: const Text('Submit attendance?'),
          content: const Text(
            'Submit your attendance for '
            'CSE 321 · Computer Architecture?',
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
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _attendanceMarked = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Attendance marked successfully.')),
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

class _ActiveSessionCard extends StatelessWidget {
  const _ActiveSessionCard();

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
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Active attendance session',
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
                  borderRadius: BorderRadius.circular(AppRadius.circular),
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
                        fontWeight: FontWeight.w900,
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
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          const Text(
            '22 Batch · Section A',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.large),
          const _SessionInformation(
            icon: Icons.person_outline_rounded,
            label: 'Teacher',
            value: 'Prof. Dr. Kaushik Deb',
          ),
          const SizedBox(height: AppSpacing.medium),
          const _SessionInformation(
            icon: Icons.location_on_outlined,
            label: 'Room',
            value: 'Room 302',
          ),
          const SizedBox(height: AppSpacing.medium),
          const _SessionInformation(
            icon: Icons.timer_outlined,
            label: 'Time remaining',
            value: '18 minutes',
          ),
          const SizedBox(height: AppSpacing.medium),
          const _SessionInformation(
            icon: Icons.security_rounded,
            label: 'Security',
            value: 'GPS + six-digit passcode',
          ),
          const SizedBox(height: AppSpacing.large),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.medium),
            decoration: BoxDecoration(
              color: AppColors.warningBackground,
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: const Row(
              children: [
                Icon(Icons.schedule_rounded, color: AppColors.warning),
                SizedBox(width: AppSpacing.small),
                Expanded(
                  child: Text(
                    'Submit before the session closes to avoid '
                    'being marked absent.',
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
}

class _SessionInformation extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SessionInformation({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
                  fontSize: 11,
                ),
              ),
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

class _AttendanceMarkedState extends StatelessWidget {
  const _AttendanceMarkedState();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Icon(Icons.check_circle_rounded, color: AppColors.success, size: 72),
        SizedBox(height: AppSpacing.regular),
        Text(
          'Attendance marked',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: AppSpacing.small),
        Text(
          'Your attendance for CSE 321 was submitted successfully.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary),
        ),
        SizedBox(height: AppSpacing.large),
        _ConfirmationItem(label: 'Status', value: 'Present'),
        SizedBox(height: AppSpacing.small),
        _ConfirmationItem(label: 'Submitted at', value: '10:42 AM'),
        SizedBox(height: AppSpacing.small),
        _ConfirmationItem(label: 'Verification', value: 'GPS + passcode'),
      ],
    );
  }
}

class _ConfirmationItem extends StatelessWidget {
  final String label;
  final String value;

  const _ConfirmationItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: AppColors.successBackground,
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.success,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceHistoryCard extends StatelessWidget {
  const _AttendanceHistoryCard();

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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent attendance history',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: AppSpacing.regular),
          _HistoryRow(
            course: 'CSE 315 · Software Engineering',
            date: '29 August 2026 · 9:30 AM',
            status: 'Present',
          ),
          Divider(),
          _HistoryRow(
            course: 'CSE 333 · Computer Networks',
            date: '28 August 2026 · 1:30 PM',
            status: 'Late',
          ),
          Divider(),
          _HistoryRow(
            course: 'CSE 321 · Computer Architecture',
            date: '27 August 2026 · 10:30 AM',
            status: 'Present',
          ),
          Divider(),
          _HistoryRow(
            course: 'CSE 315 · Software Engineering',
            date: '25 August 2026 · 9:30 AM',
            status: 'Absent',
          ),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final String course;
  final String date;
  final String status;

  const _HistoryRow({
    required this.course,
    required this.date,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final Color foreground;
    final Color background;

    switch (status) {
      case 'Present':
        foreground = AppColors.success;
        background = AppColors.successBackground;
      case 'Late':
        foreground = AppColors.warning;
        background = AppColors.warningBackground;
      default:
        foreground = AppColors.danger;
        background = AppColors.dangerBackground;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.medium),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.informationBackground,
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.medium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.extraSmall),
                Text(
                  date,
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.medium),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.medium,
              vertical: AppSpacing.extraSmall,
            ),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(AppRadius.circular),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: foreground,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
