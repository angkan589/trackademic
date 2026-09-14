import 'package:flutter/material.dart';
import 'package:trackademic/core/services/notification_service.dart';
import 'package:trackademic/core/theme/app_colors.dart';
import 'package:trackademic/core/theme/app_dimensions.dart';
import 'package:trackademic/core/widgets/app_depth_background.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  static const _service = NotificationService();

  late final Stream<List<TrackademicNotification>> _stream;
  bool _markingAll = false;

  @override
  void initState() {
    super.initState();
    _stream = _service.watchCurrent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Notifications'),
        actions: [
          TextButton.icon(
            onPressed: _markingAll ? null : _markAllRead,
            icon: _markingAll
                ? const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.done_all_rounded),
            label: const Text('Read all'),
          ),
          const SizedBox(width: AppSpacing.small),
        ],
      ),
      body: StreamBuilder<List<TrackademicNotification>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _NotificationState(
              icon: Icons.cloud_off_rounded,
              title: 'Notifications unavailable',
              message: snapshot.error.toString(),
            );
          }

          final notifications = snapshot.data ?? const [];

          if (notifications.isEmpty) {
            return const _NotificationState(
              icon: Icons.notifications_active_outlined,
              title: 'You are all caught up',
              message: 'Course, attendance, schedule, and marks updates appear here.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.large),
            itemCount: notifications.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: AppSpacing.medium),
            itemBuilder: (context, index) {
              final notification = notifications[index];

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 850),
                  child: DepthSurface(
                    padding: const EdgeInsets.all(AppSpacing.regular),
                    onTap: () => _openNotification(notification),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DepthIconBadge(
                          icon: _iconFor(notification.type),
                          color: notification.isRead
                              ? AppColors.textTertiary
                              : AppColors.primary,
                        ),
                        const SizedBox(width: AppSpacing.regular),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      notification.title,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: notification.isRead
                                            ? FontWeight.w700
                                            : FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  if (!notification.isRead)
                                    Container(
                                      width: 9,
                                      height: 9,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.small),
                              Text(
                                notification.message,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  height: 1.45,
                                ),
                              ),
                              if (notification.createdAt != null) ...[
                                const SizedBox(height: AppSpacing.small),
                                Text(
                                  _relativeTime(notification.createdAt!),
                                  style: const TextStyle(
                                    color: AppColors.textTertiary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _openNotification(
    TrackademicNotification notification,
  ) async {
    if (!notification.isRead) {
      try {
        await _service.markRead(notification.id);
      } on NotificationServiceException catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
        return;
      }
    }

    if (mounted) {
      Navigator.of(context).pop(notification);
    }
  }

  Future<void> _markAllRead() async {
    setState(() => _markingAll = true);

    try {
      await _service.markAllRead();
    } on NotificationServiceException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (mounted) setState(() => _markingAll = false);
    }
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'attendance':
        return Icons.how_to_reg_rounded;
      case 'marks':
        return Icons.analytics_rounded;
      case 'schedule':
        return Icons.calendar_month_rounded;
      case 'course':
      case 'join_request':
        return Icons.school_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  String _relativeTime(DateTime value) {
    final difference = DateTime.now().difference(value);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';

    return '${value.day.toString().padLeft(2, '0')}/'
        '${value.month.toString().padLeft(2, '0')}/${value.year}';
  }
}

class _NotificationState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _NotificationState({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: DepthSurface(
            child: Column(
              children: [
                DepthIconBadge(icon: icon, size: 68),
                const SizedBox(height: AppSpacing.large),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSpacing.small),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
