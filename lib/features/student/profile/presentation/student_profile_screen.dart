import 'package:flutter/material.dart';
import 'package:trackademic/core/theme/app_colors.dart';
import 'package:trackademic/core/theme/app_dimensions.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  bool _attendanceReminders = true;
  bool _marksAlerts = true;
  bool _scheduleAlerts = true;
  bool _basicProfileVisible = false;

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
              const _ProfileSummaryCard(),
              const SizedBox(height: AppSpacing.large),
              _buildInformationSection(),
              const SizedBox(height: AppSpacing.large),
              _buildPrivacyCard(),
              const SizedBox(height: AppSpacing.large),
              _buildNotificationCard(),
              const SizedBox(height: AppSpacing.large),
              _buildAccountSecurityCard(),
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
          'Profile',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: AppSpacing.small),
        Text(
          'Review your personal information and '
          'academic privacy settings.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildInformationSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 820) {
          return const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _PersonalInformationCard()),
              SizedBox(width: AppSpacing.regular),
              Expanded(child: _AcademicInformationCard()),
            ],
          );
        }

        return const Column(
          children: [
            _PersonalInformationCard(),
            SizedBox(height: AppSpacing.regular),
            _AcademicInformationCard(),
          ],
        );
      },
    );
  }

  Widget _buildPrivacyCard() {
    return _SectionCard(
      title: 'Privacy and record access',
      subtitle: 'Control profile visibility and review protected data access.',
      icon: Icons.privacy_tip_outlined,
      children: [
        const _ProtectedRecordTile(
          icon: Icons.fact_check_outlined,
          title: 'Attendance records',
          access: 'Only you and authorized teachers',
        ),
        const Divider(),
        const _ProtectedRecordTile(
          icon: Icons.analytics_outlined,
          title: 'Marks and results',
          access: 'Only you and authorized course teachers',
        ),
        const Divider(),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          secondary: const Icon(Icons.badge_outlined, color: AppColors.primary),
          title: const Text(
            'Basic profile visibility',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          subtitle: const Text(
            'Allow classmates to see only your name, '
            'student ID, and section.',
          ),
          value: _basicProfileVisible,
          onChanged: (value) {
            setState(() {
              _basicProfileVisible = value;
            });
          },
        ),
        const Divider(),
        const _ProtectedRecordTile(
          icon: Icons.location_on_outlined,
          title: 'GPS location access',
          access: 'Used only during active attendance verification',
        ),
        const SizedBox(height: AppSpacing.medium),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.medium),
          decoration: BoxDecoration(
            color: AppColors.successBackground,
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.verified_user_rounded, color: AppColors.success),
              SizedBox(width: AppSpacing.small),
              Expanded(
                child: Text(
                  'Other students can never access your '
                  'attendance or marks, regardless of your '
                  'basic-profile visibility setting.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationCard() {
    return _SectionCard(
      title: 'Notifications',
      subtitle: 'Choose which academic updates you want to receive.',
      icon: Icons.notifications_none_rounded,
      children: [
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          secondary: const Icon(
            Icons.how_to_reg_outlined,
            color: AppColors.primary,
          ),
          title: const Text(
            'Attendance reminders',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          subtitle: const Text(
            'Receive an alert when a teacher starts attendance.',
          ),
          value: _attendanceReminders,
          onChanged: (value) {
            setState(() {
              _attendanceReminders = value;
            });
          },
        ),
        const Divider(),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          secondary: const Icon(
            Icons.analytics_outlined,
            color: AppColors.primary,
          ),
          title: const Text(
            'Marks publication alerts',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          subtitle: const Text(
            'Receive an alert when a teacher publishes marks.',
          ),
          value: _marksAlerts,
          onChanged: (value) {
            setState(() {
              _marksAlerts = value;
            });
          },
        ),
        const Divider(),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          secondary: const Icon(
            Icons.calendar_month_outlined,
            color: AppColors.primary,
          ),
          title: const Text(
            'Schedule updates',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          subtitle: const Text(
            'Receive an alert when a class time '
            'or room changes.',
          ),
          value: _scheduleAlerts,
          onChanged: (value) {
            setState(() {
              _scheduleAlerts = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildAccountSecurityCard() {
    return _SectionCard(
      title: 'Account security',
      subtitle: 'Manage password and session security.',
      icon: Icons.security_rounded,
      children: [
        const _SecurityInformation(
          icon: Icons.email_outlined,
          label: 'Verified email',
          value: 'afsana.2204001@cuet.ac.bd',
        ),
        const SizedBox(height: AppSpacing.medium),
        const _SecurityInformation(
          icon: Icons.login_rounded,
          label: 'Last sign-in',
          value: '31 August 2026 · 9:12 AM',
        ),
        const SizedBox(height: AppSpacing.large),
        LayoutBuilder(
          builder: (context, constraints) {
            final changePasswordButton = OutlinedButton.icon(
              onPressed: _showChangePasswordDialog,
              icon: const Icon(Icons.password_rounded),
              label: const Text('Change password'),
            );

            final signOutButton = FilledButton.icon(
              onPressed: _showSignOutDialog,
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign out'),
            );

            if (constraints.maxWidth >= 520) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  changePasswordButton,
                  const SizedBox(width: AppSpacing.medium),
                  signOutButton,
                ],
              );
            }

            return Column(
              children: [
                SizedBox(width: double.infinity, child: changePasswordButton),
                const SizedBox(height: AppSpacing.medium),
                SizedBox(width: double.infinity, child: signOutButton),
              ],
            );
          },
        ),
      ],
    );
  }

  Future<void> _showChangePasswordDialog() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.password_rounded,
            color: AppColors.primary,
            size: 40,
          ),
          title: const Text('Change password'),
          content: const Text(
            'A secure password-reset link will be sent '
            'to your verified institutional email when '
            'Firebase authentication is connected.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSignOutDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.logout_rounded,
            color: AppColors.warning,
            size: 40,
          ),
          title: const Text('Sign out?'),
          content: const Text(
            'Are you sure you want to sign out '
            'of the Student workspace?',
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
              child: const Text('Sign out'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Sign-out will be enabled when Firebase '
          'authentication is connected.',
        ),
      ),
    );
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard();

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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final avatar = Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: AppColors.informationBackground,
              borderRadius: BorderRadius.circular(AppRadius.large),
            ),
            child: const Center(
              child: Text(
                'AR',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          );

          final information = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Afsana Rahman',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: AppSpacing.extraSmall),
              const Text(
                'Student ID: 2204001',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.medium),
              const Wrap(
                spacing: AppSpacing.small,
                runSpacing: AppSpacing.small,
                children: [
                  _ProfileLabel(text: 'CSE Department'),
                  _ProfileLabel(text: '22 Batch'),
                  _ProfileLabel(text: 'Section A'),
                ],
              ),
            ],
          );

          if (constraints.maxWidth >= 560) {
            return Row(
              children: [
                avatar,
                const SizedBox(width: AppSpacing.large),
                Expanded(child: information),
                const Icon(
                  Icons.verified_rounded,
                  color: AppColors.success,
                  size: 30,
                ),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              avatar,
              const SizedBox(height: AppSpacing.regular),
              information,
            ],
          );
        },
      ),
    );
  }
}

class _ProfileLabel extends StatelessWidget {
  final String text;

  const _ProfileLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.medium,
        vertical: AppSpacing.extraSmall,
      ),
      decoration: BoxDecoration(
        color: AppColors.informationBackground,
        borderRadius: BorderRadius.circular(AppRadius.circular),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _PersonalInformationCard extends StatelessWidget {
  const _PersonalInformationCard();

  @override
  Widget build(BuildContext context) {
    return const _SectionCard(
      title: 'Personal information',
      subtitle: 'Your verified contact details.',
      icon: Icons.person_outline_rounded,
      children: [
        _InformationRow(
          icon: Icons.badge_outlined,
          label: 'Full name',
          value: 'Afsana Rahman',
        ),
        SizedBox(height: AppSpacing.medium),
        _InformationRow(
          icon: Icons.email_outlined,
          label: 'Institutional email',
          value: 'afsana.2204001@cuet.ac.bd',
        ),
        SizedBox(height: AppSpacing.medium),
        _InformationRow(
          icon: Icons.phone_outlined,
          label: 'Phone number',
          value: '+880 17XX-XXXXXX',
        ),
      ],
    );
  }
}

class _AcademicInformationCard extends StatelessWidget {
  const _AcademicInformationCard();

  @override
  Widget build(BuildContext context) {
    return const _SectionCard(
      title: 'Academic information',
      subtitle: 'Official information assigned by the institution.',
      icon: Icons.school_outlined,
      children: [
        _InformationRow(
          icon: Icons.numbers_rounded,
          label: 'Student ID',
          value: '2204001',
        ),
        SizedBox(height: AppSpacing.medium),
        _InformationRow(
          icon: Icons.apartment_rounded,
          label: 'Department',
          value: 'Computer Science and Engineering',
        ),
        SizedBox(height: AppSpacing.medium),
        _InformationRow(
          icon: Icons.groups_rounded,
          label: 'Batch and section',
          value: '22 Batch · Section A',
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.large),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.informationBackground,
                    borderRadius: BorderRadius.circular(AppRadius.small),
                  ),
                  child: Icon(icon, color: AppColors.primary),
                ),
                const SizedBox(width: AppSpacing.medium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        subtitle,
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
            const SizedBox(height: AppSpacing.large),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InformationRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InformationRow({
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

class _ProtectedRecordTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String access;

  const _ProtectedRecordTile({
    required this.icon,
    required this.title,
    required this.access,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.small),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: AppSpacing.medium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  access,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.small),
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
                Icon(Icons.lock_rounded, color: AppColors.success, size: 14),
                SizedBox(width: AppSpacing.extraSmall),
                Text(
                  'Protected',
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
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

class _SecurityInformation extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SecurityInformation({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
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
      ),
    );
  }
}
