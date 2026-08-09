import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:work_key/data/models/applications_response_model.dart';
import 'package:work_key/screens/applications/application_status_theme.dart';
import 'package:work_key/screens/applications/applications_strings.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/utils/constants.dart';
import 'application_details_screen.dart';
import '../application_navigation.dart';

class ApplicationCard extends StatelessWidget {
  final JobApplication application;
  const ApplicationCard({super.key, required this.application});

  @override Widget build(BuildContext context) {
    final theme = ApplicationStatusTheme.from(application.status.key);
    final strings = ApplicationsStrings.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: HomeColors.divider), boxShadow: const [BoxShadow(color: Color(0x0915213A), blurRadius: 18, offset: Offset(0, 8))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CircleAvatar(radius: 25, backgroundColor: HomeColors.softPurple, foregroundImage: application.job.company.logoUrl?.isNotEmpty == true ? NetworkImage(application.job.company.logoUrl!) : null, child: const Icon(Icons.business_rounded, color: HomeColors.purple)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            DefaultText(text: application.job.title, style: const TextStyle(color: HomeColors.ink, fontSize: 16.5, height: 1.3, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4), DefaultText(text: application.job.company.name, style: const TextStyle(color: HomeColors.muted, fontSize: 12.5)),
          ])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6), decoration: BoxDecoration(color: theme.background, borderRadius: BorderRadius.circular(16)), child: DefaultText(text: application.status.label, style: TextStyle(color: theme.foreground, fontSize: 10.5, fontWeight: FontWeight.w800))),
        ]),
        if (application.job.location.isNotEmpty) ...[const SizedBox(height: 12), Row(children: [const Icon(Icons.location_on_outlined, size: 16, color: HomeColors.muted), const SizedBox(width: 5), Expanded(child: DefaultText(text: application.job.location, style: const TextStyle(color: HomeColors.muted, fontSize: 11.5)))])],
        if (application.nextAction != null && application.allowedActions.contains(application.nextAction!.type.key)) ...[
          const SizedBox(height: 13),
          Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: HomeColors.softPurple, borderRadius: BorderRadius.circular(13)), child: Row(children: [Expanded(child: DefaultText(text: _actionText(application.nextAction!), style: const TextStyle(color: HomeColors.purple, fontSize: 12, height: 1.4, fontWeight: FontWeight.w700))), DefaultTextButton(text: application.nextAction!.type.key == 'complete_test' ? 'Start test' : 'Open', onPressed: () => ApplicationNavigation.openNextAction(context, application.nextAction!), textStyle: const TextStyle(color: HomeColors.purple, fontSize: 11, fontWeight: FontWeight.w800))])),
        ],
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: DefaultText(text: _updated(application.lastStatusChangedAt), style: const TextStyle(color: HomeColors.muted, fontSize: 10.5))),
          DefaultTextButton(text: strings.viewDetails, onPressed: () async { await navigateTo(context, ApplicationDetailsScreen(applicationId: application.id)); if (context.mounted) {} }, textStyle: const TextStyle(color: HomeColors.brand, fontSize: 12, fontWeight: FontWeight.w700)),
        ]),
      ]),
    );
  }

  String _actionText(NextAction action) { final deadline = DateTime.tryParse(action.deadline ?? ''); final suffix = deadline == null ? '' : ' • ${DateFormat('MMM d, h:mm a').format(deadline.toLocal())}'; return (action.label.isNotEmpty ? action.label : action.type.label) + suffix; }
  String _updated(String? raw) { final date = DateTime.tryParse(raw ?? ''); if (date == null) return 'Recently updated'; final days = DateTime.now().difference(date).inDays; return days <= 0 ? 'Updated today' : days == 1 ? 'Updated yesterday' : 'Updated $days days ago'; }
}
