import 'package:flutter/material.dart';
import 'package:trackademic/core/services/auth_service.dart';
import 'package:trackademic/core/theme/app_colors.dart';
import 'package:trackademic/core/theme/app_dimensions.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  static const _authService = AuthService();

  late Future<AppUserProfile> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _authService.loadCurrentProfile();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppUserProfile>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return _ProfileLoadError(
            message:
                snapshot.error?.toString() ??
                'Your profile could not be loaded.',
            onRetry: _retry,
          );
        }

        return _buildProfile(snapshot.data!);
      },
    );
  }

  Widget _buildProfile(AppUserProfile profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.large),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Profile',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              const Text(
                'Your account and academic information from Trackademic.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
              ),
              const SizedBox(height: AppSpacing.large),
              _ProfileSummaryCard(profile: profile),
              const SizedBox(height: AppSpacing.large),
              _buildInformationSection(profile),
              const SizedBox(height: AppSpacing.large),
              const _PrivacyCard(),
              const SizedBox(height: AppSpacing.large),
              _AccountSecurityCard(
                profile: profile,
                onChangePassword: () => _sendPasswordReset(profile.email),
                onSignOut: _showSignOutDialog,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInformationSection(AppUserProfile profile) {
    final personal = _SectionCard(
      title: 'Personal information',
      subtitle: 'Information stored in your Trackademic account.',
      icon: Icons.person_outline_rounded,
      children: [
        _InformationRow(
          icon: Icons.badge_outlined,
          label: 'Full name',
          value: _valueOrNotProvided(profile.displayName),
        ),
        const SizedBox(height: AppSpacing.medium),
        _InformationRow(
          icon: Icons.email_outlined,
          label: 'Email',
          value: _valueOrNotProvided(profile.email),
        ),
      ],
    );

    final academic = _SectionCard(
      title: 'Academic information',
      subtitle: 'Information assigned to your student account.',
      icon: Icons.school_outlined,
      children: [
        _InformationRow(
          icon: Icons.numbers_rounded,
          label: 'Institution ID',
          value: _valueOrNotProvided(profile.institutionId),
        ),
        const SizedBox(height: AppSpacing.medium),
        _InformationRow(
          icon: Icons.apartment_rounded,
          label: 'Department',
          value: _valueOrNotProvided(profile.department),
        ),
        const SizedBox(height: AppSpacing.medium),
        _InformationRow(
          icon: Icons.groups_rounded,
          label: 'Batch',
          value: _valueOrNotProvided(profile.batch),
        ),
        const SizedBox(height: AppSpacing.medium),
        _InformationRow(
          icon: Icons.group_outlined,
          label: 'Section',
          value: _valueOrNotProvided(profile.section),
        ),
        const SizedBox(height: AppSpacing.medium),
        _InformationRow(
          icon: Icons.calendar_today_outlined,
          label: 'Semester',
          value: _valueOrNotProvided(profile.semester),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 820) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: personal),
              const SizedBox(width: AppSpacing.regular),
              Expanded(child: academic),
            ],
          );
        }

        return Column(
          children: [
            personal,
            const SizedBox(height: AppSpacing.regular),
            academic,
          ],
        );
      },
    );
  }

  String _valueOrNotProvided(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Not provided';
    }

    return value.trim();
  }

  Future<void> _retry() async {
    setState(() {
      _profileFuture = _authService.loadCurrentProfile();
    });
  }

  Future<void> _sendPasswordReset(String email) async {
    try {
      await _authService.sendPasswordReset(email);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset instructions sent to $email.')),
      );
    } on AuthServiceException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
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
            'Are you sure you want to sign out of Trackademic?',
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

    if (confirmed != true) {
      return;
    }

    await _authService.signOut();
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  final AppUserProfile profile;

  const _ProfileSummaryCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final initials = _initials(profile.displayName);

    final labels = <String>[
      if (profile.department?.trim().isNotEmpty == true)
        profile.department!.trim(),
      if (profile.batch?.trim().isNotEmpty == true) profile.batch!.trim(),
      if (profile.section?.trim().isNotEmpty == true) profile.section!.trim(),
      if (profile.semester?.trim().isNotEmpty == true) profile.semester!.trim(),
    ];

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
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
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
              Text(
                profile.displayName.trim().isEmpty
                    ? 'Student'
                    : profile.displayName,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: AppSpacing.extraSmall),
              Text(
                'Institution ID: ${profile.institutionId}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.medium),
              if (labels.isEmpty)
                const Text(
                  'Academic details have not been added yet.',
                  style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
                )
              else
                Wrap(
                  spacing: AppSpacing.small,
                  runSpacing: AppSpacing.small,
                  children: [
                    for (final label in labels) _ProfileLabel(text: label),
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
                if (_isEmailVerified())
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

  static String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return 'S';
    }

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  static bool _isEmailVerified() {
    return const AuthService().currentUser?.emailVerified ?? false;
  }
}

class _PrivacyCard extends StatelessWidget {
  const _PrivacyCard();

  @override
  Widget build(BuildContext context) {
    return const _SectionCard(
      title: 'Privacy and record access',
      subtitle: 'Your private academic data is protected.',
      icon: Icons.privacy_tip_outlined,
      children: [
        _ProtectedRecordTile(
          icon: Icons.fact_check_outlined,
          title: 'Attendance records',
          access: 'Available only to you and authorized teachers',
        ),
        Divider(),
        _ProtectedRecordTile(
          icon: Icons.analytics_outlined,
          title: 'Marks and results',
          access: 'Available only to you and authorized course teachers',
        ),
        Divider(),
        _ProtectedRecordTile(
          icon: Icons.location_on_outlined,
          title: 'Location',
          access: 'Used only when attendance verification requires it',
        ),
      ],
    );
  }
}

class _AccountSecurityCard extends StatelessWidget {
  final AppUserProfile profile;
  final VoidCallback onChangePassword;
  final VoidCallback onSignOut;

  const _AccountSecurityCard({
    required this.profile,
    required this.onChangePassword,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    final user = const AuthService().currentUser;

    final verified = user?.emailVerified == true ? 'Verified' : 'Not verified';

    final lastSignIn = user?.metadata.lastSignInTime;

    return _SectionCard(
      title: 'Account security',
      subtitle: 'Firebase Authentication account status.',
      icon: Icons.security_rounded,
      children: [
        _InformationRow(
          icon: Icons.email_outlined,
          label: 'Email',
          value: profile.email,
        ),
        const SizedBox(height: AppSpacing.medium),
        _InformationRow(
          icon: Icons.verified_user_outlined,
          label: 'Email verification',
          value: verified,
        ),
        const SizedBox(height: AppSpacing.medium),
        _InformationRow(
          icon: Icons.login_rounded,
          label: 'Last sign-in',
          value: _formatDateTime(lastSignIn),
        ),
        const SizedBox(height: AppSpacing.large),
        LayoutBuilder(
          builder: (context, constraints) {
            final resetButton = OutlinedButton.icon(
              onPressed: onChangePassword,
              icon: const Icon(Icons.password_rounded),
              label: const Text('Reset password'),
            );

            final signOutButton = FilledButton.icon(
              onPressed: onSignOut,
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign out'),
            );

            if (constraints.maxWidth >= 520) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  resetButton,
                  const SizedBox(width: AppSpacing.medium),
                  signOutButton,
                ],
              );
            }

            return Column(
              children: [
                SizedBox(width: double.infinity, child: resetButton),
                const SizedBox(height: AppSpacing.medium),
                SizedBox(width: double.infinity, child: signOutButton),
              ],
            );
          },
        ),
      ],
    );
  }

  static String _formatDateTime(DateTime? value) {
    if (value == null) {
      return 'Not available';
    }

    final local = value.toLocal();

    String twoDigits(int number) {
      return number.toString().padLeft(2, '0');
    }

    return '${local.year}-${twoDigits(local.month)}-${twoDigits(local.day)} '
        '${twoDigits(local.hour)}:${twoDigits(local.minute)}';
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

class _ProfileLoadError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ProfileLoadError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.danger,
              size: 48,
            ),
            const SizedBox(height: AppSpacing.medium),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.large),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
