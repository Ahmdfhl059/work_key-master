import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:work_key/data/models/activity_response_model.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/utils/constants.dart';

class ActivityCard extends StatelessWidget {
  final ActivityItem item;
  final VoidCallback onTap;
  final bool compact;
  const ActivityCard({super.key, required this.item, required this.onTap, this.compact = false});

  @override Widget build(BuildContext context) {
    final company = item.company?.name ?? '';
    final logo = item.company?.logoUrl;
    final date = item.dueAt ?? item.startsAt ?? item.occurredAt;
    final color = _color(item.type.key);
    return Semantics(
      button: item.action != null, label: '${item.isRead ? '' : 'Unread, '}${item.title}${item.isOverdue ? ', overdue' : ''}',
      child: InkWell(
        onTap: item.action != null || item.notificationId != null ? onTap : null,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: compact ? 285 : double.infinity,
          padding: EdgeInsets.all(compact ? 15 : 17),
          decoration: BoxDecoration(color: item.isRead ? Colors.white : const Color(0xFFF9F7FF), borderRadius: BorderRadius.circular(20), border: Border.all(color: item.isOverdue ? const Color(0xFFE9A4A4) : item.isRead ? HomeColors.divider : HomeColors.purple.withValues(alpha: .28)), boxShadow: const [BoxShadow(color: Color(0x0815213A), blurRadius: 16, offset: Offset(0, 7))]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Stack(children: [
                CircleAvatar(radius: 23, backgroundColor: color.withValues(alpha: .12), foregroundImage: logo?.isNotEmpty == true ? NetworkImage(logo!) : null, child: Icon(_icon(item.type.key), color: color, size: 21)),
                if (!item.isRead) const Positioned(right: 0, top: 0, child: CircleAvatar(radius: 5, backgroundColor: HomeColors.purple)),
              ]),
              const SizedBox(width: 11),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                DefaultText(text: item.title, maxLines: compact ? 2 : 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: HomeColors.ink, fontSize: 14.5, height: 1.35, fontWeight: FontWeight.w800)),
                if (company.isNotEmpty) ...[const SizedBox(height: 3), DefaultText(text: company, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: HomeColors.muted, fontSize: 11.5))],
              ])),
              if (item.isOverdue) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), decoration: BoxDecoration(color: const Color(0xFFFFE8E8), borderRadius: BorderRadius.circular(12)), child: const DefaultText(text: 'Overdue', style: TextStyle(color: Color(0xFFB44343), fontSize: 9.5, fontWeight: FontWeight.w800))),
            ]),
            if (item.description.isNotEmpty) ...[const SizedBox(height: 11), DefaultText(text: item.description, maxLines: compact ? 2 : 4, overflow: TextOverflow.ellipsis, style: const TextStyle(color: HomeColors.muted, fontSize: 12, height: 1.45))],
            if (date != null) ...[const SizedBox(height: 10), Row(children: [Icon(item.isOverdue ? Icons.warning_amber_rounded : Icons.schedule_rounded, size: 15, color: item.isOverdue ? const Color(0xFFB44343) : HomeColors.muted), const SizedBox(width: 5), Expanded(child: DefaultText(text: _date(date), style: TextStyle(color: item.isOverdue ? const Color(0xFFB44343) : HomeColors.muted, fontSize: 10.5, fontWeight: FontWeight.w600)))])],
            if (item.action != null) ...[const SizedBox(height: 12), Row(children: [Expanded(child: DefaultText(text: item.type.label, style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w700))), DefaultTextButton(text: item.action!.label.isNotEmpty ? item.action!.label : _actionLabel(item.action!.type.key), onPressed: onTap, textStyle: const TextStyle(color: HomeColors.purple, fontSize: 11.5, fontWeight: FontWeight.w800))])],
          ]),
        ),
      ),
    );
  }
  String _date(String raw) { final value = DateTime.tryParse(raw)?.toLocal(); return value == null ? raw : DateFormat('MMM d • h:mm a').format(value); }
  String _actionLabel(String key) => key == 'start_test' ? 'Start test' : key == 'continue_test' ? 'Continue test' : key == 'submit_information' ? 'Send information' : key == 'confirm_interview' ? 'Confirm attendance' : 'View details';
  IconData _icon(String key) => key == 'test' ? Icons.quiz_outlined : key == 'interview' ? Icons.video_call_outlined : key == 'information_request' ? Icons.description_outlined : key == 'final_decision' ? Icons.verified_outlined : Icons.notifications_none_rounded;
  Color _color(String key) => key == 'test' ? HomeColors.warning : key == 'interview' ? const Color(0xFF168F91) : key == 'final_decision' ? const Color(0xFF279267) : HomeColors.purple;
}
