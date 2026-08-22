import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:work_key/data/models/applications_response_model.dart';
import 'package:work_key/screens/applications/application_status_theme.dart';
import 'package:work_key/screens/applications/applications_strings.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/utils/constants.dart';
import 'package:work_key/shared/components/company_logo.dart';
import 'package:work_key/localization/app_localizations.dart';
import 'application_details_screen.dart';
import '../application_navigation.dart';

class ApplicationCard extends StatelessWidget {
  final JobApplication application;
  const ApplicationCard({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    final theme = ApplicationStatusTheme.from(
      application.status.key,
      colorScheme: Theme.of(context).colorScheme,
    );
    final strings = ApplicationsStrings.of(context);
    return AnimatedPressableCard(
      onTap: () => navigateTo(
        context,
        ApplicationDetailsScreen(applicationId: application.id),
      ),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surfaceContainer,
              theme.background.withValues(alpha: .35),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: .10),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CompanyLogo(
                  size: 50,
                  url: application.job.company.logoUrl,
                  companyName: application.job.company.name,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DefaultText(
                        text: application.job.title,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 16.5,
                          height: 1.3,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      DefaultText(
                        text: application.job.company.name,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.background,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: DefaultText(
                    text: application.status.label,
                    style: TextStyle(
                      color: theme.foreground,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            if (application.job.location.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: context.appMuted,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: DefaultText(
                      text: application.job.location,
                      style: TextStyle(color: context.appMuted, fontSize: 11.5),
                    ),
                  ),
                ],
              ),
            ],
            if (application.nextAction != null &&
                application.allowedActions.contains(
                  application.nextAction!.type.key,
                )) ...[
              const SizedBox(height: 13),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.appSoftBrand,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: DefaultText(
                        text: _actionText(context, application.nextAction!),
                        style: const TextStyle(
                          color: HomeColors.purple,
                          fontSize: 12,
                          height: 1.4,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    DefaultTextButton(
                      text: application.nextAction!.type.key == 'complete_test'
                          ? context.tr('applications.start_test')
                          : context.tr('applications.open_request'),
                      onPressed: () => ApplicationNavigation.openNextAction(
                        context,
                        application.nextAction!,
                      ),
                      textStyle: const TextStyle(
                        color: HomeColors.purple,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: DefaultText(
                    text: _updated(context, application.lastStatusChangedAt),
                    style: TextStyle(color: context.appMuted, fontSize: 10.5),
                  ),
                ),
                DefaultTextButton(
                  text: strings.viewDetails,
                  onPressed: () async {
                    await navigateTo(
                      context,
                      ApplicationDetailsScreen(applicationId: application.id),
                    );
                    if (context.mounted) {}
                  },
                  textStyle: const TextStyle(
                    color: HomeColors.brand,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _actionText(BuildContext context, NextAction action) {
    final deadline = DateTime.tryParse(action.deadline ?? '');
    final suffix = deadline == null
        ? ''
        : ' • ${DateFormat('MMM d, h:mm a', Localizations.localeOf(context).toLanguageTag()).format(deadline.toLocal())}';
    return (action.label.isNotEmpty ? action.label : action.type.label) +
        suffix;
  }

  String _updated(BuildContext context, String? raw) {
    final date = DateTime.tryParse(raw ?? '');
    if (date == null) return context.tr('applications.updated_recently');
    final days = DateTime.now().difference(date).inDays;
    return days <= 0
        ? context.tr('applications.updated_today')
        : days == 1
        ? context.tr('applications.updated_yesterday')
        : context.tr('applications.updated_days', values: {'count': days});
  }
}
