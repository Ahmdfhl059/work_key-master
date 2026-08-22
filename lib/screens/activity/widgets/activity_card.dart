import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:work_key/data/models/activity_response_model.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/utils/constants.dart';
import 'package:work_key/shared/components/company_logo.dart';

class ActivityCard extends StatelessWidget {
  final ActivityItem item;
  final VoidCallback onTap;
  final bool compact;
  const ActivityCard({
    super.key,
    required this.item,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final company = item.company?.name ?? '';
    final logo = item.company?.logoUrl;
    final date = item.dueAt ?? item.startsAt ?? item.occurredAt;
    final color = _color(item.type.key);
    return Semantics(
      button: item.action != null,
      label:
          '${item.isRead ? '' : 'Unread, '}${item.title}${item.isOverdue ? ', overdue' : ''}',
      child: AnimatedPressableCard(
        onTap: item.action != null || item.notificationId != null
            ? onTap
            : null,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: compact ? 285 : double.infinity,
          padding: EdgeInsets.all(compact ? 15 : 17),
          decoration: BoxDecoration(
            color: item.isRead
                ? Theme.of(context).colorScheme.surfaceContainer
                : Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withValues(alpha: .3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: item.isOverdue
                  ? const Color(0xFFE9A4A4)
                  : item.isRead
                  ? Theme.of(context).colorScheme.outlineVariant
                  : HomeColors.purple.withValues(alpha: .28),
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: .10),
                blurRadius: 22,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      CompanyLogo(
                        size: 46,
                        url: logo,
                        companyName: company,
                        backgroundColor: color.withValues(alpha: .12),
                        foregroundColor: color,
                        fallbackIcon: _icon(item.type.key),
                      ),
                      if (!item.isRead)
                        const Positioned(
                          right: 0,
                          top: 0,
                          child: CircleAvatar(
                            radius: 5,
                            backgroundColor: HomeColors.purple,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DefaultText(
                          text: item.title,
                          maxLines: compact ? 2 : 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 14.5,
                            height: 1.35,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (company.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          DefaultText(
                            text: company,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: context.appMuted,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (item.isOverdue)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DefaultText(
                        text: 'Overdue',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                ],
              ),
              if (item.description.isNotEmpty) ...[
                const SizedBox(height: 11),
                DefaultText(
                  text: item.description,
                  maxLines: compact ? 2 : 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.appMuted,
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
              if (date != null) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      item.isOverdue
                          ? Icons.warning_amber_rounded
                          : Icons.schedule_rounded,
                      size: 15,
                      color: item.isOverdue
                          ? const Color(0xFFB44343)
                          : context.appMuted,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: DefaultText(
                        text: _date(date),
                        style: TextStyle(
                          color: item.isOverdue
                              ? const Color(0xFFB44343)
                              : context.appMuted,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (item.action != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DefaultText(
                        text: item.type.label,
                        style: TextStyle(
                          color: color,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    DefaultTextButton(
                      text: item.action!.label.isNotEmpty
                          ? item.action!.label
                          : _actionLabel(item.action!.type.key),
                      onPressed: onTap,
                      textStyle: const TextStyle(
                        color: HomeColors.purple,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _date(String raw) {
    final value = DateTime.tryParse(raw)?.toLocal();
    return value == null ? raw : DateFormat('MMM d • h:mm a').format(value);
  }

  String _actionLabel(String key) => key == 'start_test'
      ? 'Start test'
      : key == 'continue_test'
      ? 'Continue test'
      : key == 'submit_information'
      ? 'Send information'
      : key == 'confirm_interview'
      ? 'Confirm attendance'
      : 'View details';
  IconData _icon(String key) => key == 'test'
      ? Icons.quiz_outlined
      : key == 'interview'
      ? Icons.video_call_outlined
      : key == 'information_request'
      ? Icons.description_outlined
      : key == 'final_decision'
      ? Icons.verified_outlined
      : Icons.notifications_none_rounded;
  Color _color(String key) => key == 'test'
      ? HomeColors.warning
      : key == 'interview'
      ? const Color(0xFF168F91)
      : key == 'final_decision'
      ? const Color(0xFF279267)
      : HomeColors.purple;
}
