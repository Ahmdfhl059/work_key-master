import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../data/models/notification_model.dart';
import '../../logic/notifications_cubit/notifications_cubit.dart';
import '../../logic/notifications_cubit/notifications_state.dart';
import '../../localization/app_localizations.dart';
import '../../utils/constants.dart';
import '../../shared/components/components.dart';
import '../home_screen/home_navigation.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationsCubit>().getNotifications();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    appBar: AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 70,
      titleSpacing: 0,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.notifications_active_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 21,
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              context.tr('notifications.title'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: context.tr('notifications.read_all'),
          onPressed: () => context.read<NotificationsCubit>().markAllAsRead(),
          icon: const Icon(Icons.done_all_rounded),
        ),
        const SizedBox(width: 6),
      ],
    ),
    body: BlocBuilder<NotificationsCubit, NotificationsStates>(
      builder: (context, state) {
        if (state is NotificationsLoadingState) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is NotificationsErrorState) {
          return _MessageState(
            icon: Icons.cloud_off_rounded,
            text: 'notifications.load_error',
            onRetry: () =>
                context.read<NotificationsCubit>().getNotifications(),
          );
        }
        if (state is GetNotificationsSuccessState) {
          if (state.notifications.isEmpty) {
            return const _MessageState(
              icon: Icons.notifications_none_rounded,
              text: 'notifications.empty',
            );
          }
          return RefreshIndicator(
            onRefresh: () async =>
                context.read<NotificationsCubit>().getNotifications(),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
              itemCount: state.notifications.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, index) => _NotificationTile(
                notification: state.notifications[index],
                onTap: () => _openNotification(state.notifications[index]),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    ),
  );

  Future<void> _openNotification(NotificationModel notification) async {
    if (!notification.isRead) {
      await context.read<NotificationsCubit>().markAsRead(notification.id);
    }
    if (!mounted) return;
    final data = notification.data;
    final action = data['action'] is Map
        ? Map<String, dynamic>.from(data['action'] as Map)
        : const <String, dynamic>{};
    final target = action['target'] is Map
        ? Map<String, dynamic>.from(action['target'] as Map)
        : data['target'] is Map
        ? Map<String, dynamic>.from(data['target'] as Map)
        : const <String, dynamic>{};
    final type =
        '${action['type'] ?? data['action_type'] ?? data['type'] ?? notification.type}';
    final route =
        '${action['route'] ?? data['route'] ?? data['action_url'] ?? ''}';
    final id =
        target['id'] ??
        data['resource_id'] ??
        data['target_id'] ??
        data['job_application_id'] ??
        data['application_id'] ??
        data['job_id'] ??
        data['interview_id'] ??
        data['test_assignment_id'];
    HomeNavigation.openTarget(context, type, id: id?.toString(), value: route);
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  const _NotificationTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(notification.createdAt)?.toLocal();
    return Material(
      color: notification.isRead
          ? Theme.of(context).colorScheme.surfaceContainer
          : context.appSoftBrand,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: notification.isRead
                    ? Theme.of(context).scaffoldBackgroundColor
                    : HomeColors.purple,
                child: Icon(
                  _icon(notification.type),
                  color: notification.isRead
                      ? Theme.of(context).colorScheme.onSurfaceVariant
                      : Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.message?.trim().isNotEmpty == true
                          ? notification.message!
                          : context.tr('notifications.new_update'),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: notification.isRead
                            ? FontWeight.w600
                            : FontWeight.w800,
                        height: 1.35,
                      ),
                    ),
                    if (date != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        DateFormat(
                          'MMM d, h:mm a',
                          Localizations.localeOf(context).toLanguageTag(),
                        ).format(date),
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!notification.isRead)
                const Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: CircleAvatar(
                    radius: 4,
                    backgroundColor: HomeColors.purple,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _icon(String type) {
    final value = type.toLowerCase();
    if (value.contains('test')) return Icons.quiz_rounded;
    if (value.contains('interview')) return Icons.video_call_rounded;
    if (value.contains('application'))
      return Icons.assignment_turned_in_rounded;
    return Icons.notifications_rounded;
  }
}

class _MessageState extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onRetry;
  const _MessageState({required this.icon, required this.text, this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 54,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 12),
        Text(context.tr(text)),
        if (onRetry != null) ...[
          const SizedBox(height: 16),
          ModernRetryButton(onRetry: () => onRetry?.call()),
        ],
      ],
    ),
  );
}
