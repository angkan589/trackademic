import 'package:flutter/material.dart';
import 'package:trackademic/core/theme/app_colors.dart';
import 'package:trackademic/core/theme/app_dimensions.dart';
import 'package:trackademic/features/teacher/dashboard/presentation/teacher_dashboard_screen.dart';
import 'package:trackademic/features/teacher/schedule/presentation/teacher_schedule_screen.dart';
import 'package:trackademic/features/teacher/attendance/presentation/teacher_create_attendance_screen.dart';
import 'package:trackademic/features/teacher/courses/presentation/teacher_courses_screen.dart';
import 'package:trackademic/features/teacher/marks/presentation/teacher_marks_screen.dart';

class WorkspaceDestination {
  final String label;
  final String description;
  final IconData icon;
  final IconData selectedIcon;

  const WorkspaceDestination({
    required this.label,
    required this.description,
    required this.icon,
    required this.selectedIcon,
  });
}

class RoleWorkspaceScreen extends StatefulWidget {
  final String roleName;
  final List<WorkspaceDestination> destinations;

  const RoleWorkspaceScreen({
    required this.roleName,
    required this.destinations,
    super.key,
  });

  @override
  State<RoleWorkspaceScreen> createState() => _RoleWorkspaceScreenState();
}

class _RoleWorkspaceScreenState extends State<RoleWorkspaceScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 900;
    final destination = widget.destinations[_selectedIndex];

    final Widget content;

    if (widget.roleName == 'Teacher' && _selectedIndex == 0) {
      content = const TeacherDashboardScreen();
    } else if (widget.roleName == 'Teacher' && _selectedIndex == 1) {
      content = const TeacherCreateAttendanceScreen();
    } else if (widget.roleName == 'Teacher' && _selectedIndex == 2) {
      content = const TeacherCoursesScreen();
    } else if (widget.roleName == 'Teacher' && _selectedIndex == 3) {
      content = const TeacherMarksScreen();
    } else if (widget.roleName == 'Teacher' && _selectedIndex == 4) {
      content = const TeacherScheduleScreen();
    } else {
      content = _ModulePlaceholder(
        roleName: widget.roleName,
        destination: destination,
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.roleName} Workspace'),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              tooltip: 'Profile',
              onPressed: () {},
              icon: const CircleAvatar(
                radius: 17,
                backgroundColor: AppColors.informationBackground,
                child: Icon(
                  Icons.person_outline_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: isDesktop
          ? Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _selectDestination,
                  labelType: NavigationRailLabelType.all,
                  backgroundColor: AppColors.surface,
                  destinations: widget.destinations.map((item) {
                    return NavigationRailDestination(
                      icon: Icon(item.icon),
                      selectedIcon: Icon(item.selectedIcon),
                      label: Text(item.label),
                    );
                  }).toList(),
                ),
                const VerticalDivider(),
                Expanded(child: content),
              ],
            )
          : content,
      bottomNavigationBar: isDesktop
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _selectDestination,
              destinations: widget.destinations.map((item) {
                return NavigationDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(item.selectedIcon),
                  label: item.label,
                );
              }).toList(),
            ),
    );
  }

  void _selectDestination(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

class _ModulePlaceholder extends StatelessWidget {
  final String roleName;
  final WorkspaceDestination destination;

  const _ModulePlaceholder({required this.roleName, required this.destination});

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
              Text(
                destination.label,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                destination.description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.extraLarge),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.extraLarge),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.large),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.informationBackground,
                        borderRadius: BorderRadius.circular(AppRadius.large),
                      ),
                      child: Icon(
                        destination.selectedIcon,
                        size: 36,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.large),
                    Text(
                      '$roleName ${destination.label}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.small),
                    const Text(
                      'This module is ready for its complete UI design.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
