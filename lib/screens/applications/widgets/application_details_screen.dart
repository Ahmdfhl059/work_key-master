import 'package:flutter/material.dart';
import 'package:work_key/data/models/applications_response_model.dart';
import 'package:work_key/data/repo/application_repo.dart';
import 'package:work_key/screens/applications/application_status_theme.dart';
import 'package:work_key/screens/interviews/interview_details_screen.dart';
import 'package:work_key/screens/applications/application_navigation.dart';
import 'package:work_key/screens/applications/information_request_screen.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/utils/constants.dart';

import '../../../localization/app_localizations.dart';

class ApplicationDetailsScreen extends StatefulWidget {
  final int applicationId;

  const ApplicationDetailsScreen({super.key, required this.applicationId});

  @override
  State<ApplicationDetailsScreen> createState() =>
      _ApplicationDetailsScreenState();
}

class _ApplicationDetailsScreenState extends State<ApplicationDetailsScreen> {
  final repo = ApplicationRepo();
  late Future<JobApplication> future;

  @override
  void initState() {
    super.initState();
    future = repo.getTypedApplicationDetails(widget.applicationId);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    appBar: AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      title: Text(context.tr('applications.details')),
    ),
    body: FutureBuilder<JobApplication>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _DetailsLoading();
        }
        if (snapshot.hasError || snapshot.data == null) {
          return Center(
            child: ModernRetryButton(
              onRetry: () => setState(
                () => future = repo.getTypedApplicationDetails(
                  widget.applicationId,
                ),
              ),
            ),
          );
        }
        return _DetailsContent(
          application: snapshot.data!,
          onWithdraw: _withdraw,
        );
      },
    ),
  );

  Future<void> _withdraw(JobApplication application) async {
    final controller = TextEditingController();
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(context.tr('applications.withdraw_title')),
            content: TextField(
              controller: controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: context.tr('applications.withdraw_reason'),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(context.tr('common.cancel')),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(context.tr('applications.withdraw')),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;
    await repo.withdrawTypedApplication(
      application.id,
      reason: controller.text,
    );
    if (mounted) Navigator.pop(context, true);
  }
}

class _DetailsContent extends StatelessWidget {
  final JobApplication application;
  final ValueChanged<JobApplication> onWithdraw;

  const _DetailsContent({required this.application, required this.onWithdraw});

  @override
  Widget build(BuildContext context) {
    final theme = ApplicationStatusTheme.from(
      application.status.key,
      colorScheme: Theme.of(context).colorScheme,
    );
    return ResponsiveContent(
      maxWidth: 760,
      child: ListView(
        padding: const EdgeInsets.only(top: 12, bottom: 40),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
                colors: [Color(0xFF4D63D2), Color(0xFF7651B5)],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x244D63D2),
                  blurRadius: 25,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white,
                      foregroundImage:
                          application.job.company.logoUrl?.isNotEmpty == true
                          ? NetworkImage(application.job.company.logoUrl!)
                          : null,
                      child: const Icon(
                        Icons.business_rounded,
                        color: HomeColors.purple,
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DefaultText(
                            text: application.job.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              height: 1.3,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 5),
                          DefaultText(
                            text: application.job.company.name,
                            style: const TextStyle(
                              color: Color(0xFFE8F7ED),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    if (application.job.location.isNotEmpty)
                      _HeaderTag(
                        Icons.location_on_outlined,
                        application.job.location,
                      ),
                    if (application.job.workMode.isNotEmpty)
                      _HeaderTag(
                        Icons.laptop_rounded,
                        application.job.workMode,
                      ),
                    if (application.job.employmentType.isNotEmpty)
                      _HeaderTag(
                        Icons.schedule_rounded,
                        application.job.employmentType,
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.background,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: theme.foreground.withValues(alpha: .16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.track_changes_rounded,
                    color: theme.foreground,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DefaultText(
                        text: context.tr('applications.current_status'),
                        style: TextStyle(
                          color: context.appMuted,
                          fontSize: 10.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      DefaultText(
                        text: application.status.label,
                        style: TextStyle(
                          color: theme.foreground,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (application.coverLetter.isNotEmpty) ...[
            const SizedBox(height: 16),
            _Section(
              title: context.tr('jobs.cover_letter'),
              icon: Icons.mail_outline_rounded,
              child: DefaultText(
                text: application.coverLetter,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.55,
                ),
              ),
            ),
          ],
          if (application.screeningAnswers.isNotEmpty) ...[
            const SizedBox(height: 16),
            _Section(
              title: context.tr('applications.screening_answers'),
              icon: Icons.rule_rounded,
              child: Column(
                children: application.screeningAnswers
                    .map(
                      (answer) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.question_mark_rounded,
                                  size: 16,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                ),
                                const SizedBox(width: 7),
                                Expanded(
                                  child: Text(
                                    answer.question,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Padding(
                              padding: const EdgeInsetsDirectional.only(
                                start: 23,
                              ),
                              child: Text(
                                answer.answer.isEmpty
                                    ? context.tr('applications.no_answer')
                                    : answer.answer,
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
          if (application.nextAction != null) ...[
            const SizedBox(height: 16),
            _Section(
              title: context.tr('applications.next_step'),
              icon: Icons.bolt_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultText(
                    text: application.nextAction!.label.isEmpty
                        ? application.nextAction!.type.label
                        : application.nextAction!.label,
                    style: TextStyle(color: context.appMuted, height: 1.5),
                  ),
                  const SizedBox(height: 10),
                  FilledButton.icon(
                    onPressed: () => ApplicationNavigation.openNextAction(
                      context,
                      application.nextAction!,
                    ),
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: Text(context.tr('applications.open_request')),
                  ),
                ],
              ),
            ),
          ],
          if (application.statusHistory.isNotEmpty) ...[
            const SizedBox(height: 16),
            _Section(
              title: context.tr('applications.timeline'),
              icon: Icons.timeline_rounded,
              child: Column(
                children: application.statusHistory.asMap().entries.map((
                  entry,
                ) {
                  final event = entry.value;
                  final last =
                      entry.key == application.statusHistory.length - 1;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: context.appSoftBrand,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 16,
                              color: HomeColors.purple,
                            ),
                          ),
                          if (!last)
                            Container(
                              width: 2,
                              height: 45,
                              color: context.appDivider,
                            ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 3, bottom: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DefaultText(
                                text: event.status.label,
                                style: TextStyle(
                                  color: context.appInk,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (event.note?.isNotEmpty == true) ...[
                                const SizedBox(height: 4),
                                DefaultText(
                                  text: event.note!,
                                  style: TextStyle(
                                    color: context.appMuted,
                                    fontSize: 11.5,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
          if (application.currentTest != null) ...[
            const SizedBox(height: 16),
            _Section(
              title: context.tr('applications.current_test'),
              icon: Icons.quiz_outlined,
              child: Text(context.tr('applications.test_available')),
            ),
          ],
          if (application.relevantInterview != null) ...[
            const SizedBox(height: 16),
            _Section(
              title: context.tr('applications.interview'),
              icon: Icons.video_call_outlined,
              child: Row(
                children: [
                  Expanded(
                    child: DefaultText(
                      text: context.tr('applications.interview_ready'),
                      style: TextStyle(color: context.appMuted, height: 1.45),
                    ),
                  ),
                  const SizedBox(width: 10),
                  DefaultTextButton(
                    text: context.tr('applications.view'),
                    onPressed: () {
                      final id = int.tryParse(
                        '${application.relevantInterview?['id'] ?? application.relevantInterview?['resource_id'] ?? ''}',
                      );
                      if (id != null) {
                        navigateTo(
                          context,
                          InterviewDetailsScreen(interviewId: id),
                        );
                      }
                    },
                    textStyle: const TextStyle(
                      color: HomeColors.purple,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (application.latestInformationRequest != null) ...[
            const SizedBox(height: 16),
            _Section(
              title: context.tr('applications.information_request'),
              icon: Icons.description_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.tr('applications.information_requested')),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () {
                      final request = application.latestInformationRequest!;
                      final id = int.tryParse(
                        '${request['id'] ?? request['resource_id'] ?? ''}',
                      );
                      if (id != null) {
                        navigateTo(
                          context,
                          InformationRequestScreen(informationRequestId: id),
                        );
                      }
                    },
                    icon: const Icon(Icons.description_outlined),
                    label: Text(context.tr('applications.open_request')),
                  ),
                ],
              ),
            ),
          ],
          if (application.allowedActions.contains('withdraw')) ...[
            const SizedBox(height: 22),
            OutlinedButton(
              onPressed: () => onWithdraw(application),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFB44343),
              ),
              child: Text(context.tr('Withdraw application')),
            ),
          ],
        ],
      ),
    );
  }
}

class _HeaderTag extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HeaderTag(this.icon, this.text);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .15),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.white),
        const SizedBox(width: 5),
        DefaultText(
          text: text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _Section({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Theme.of(context).colorScheme.surfaceContainer,
          Theme.of(context).colorScheme.primaryContainer.withValues(alpha: .20),
        ],
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: context.appSoftBrand,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: HomeColors.purple),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: DefaultText(
                text: title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}

class _DetailsLoading extends StatelessWidget {
  const _DetailsLoading();

  @override
  Widget build(BuildContext context) => ResponsiveContent(
    maxWidth: 760,
    child: ListView(
      padding: const EdgeInsets.only(top: 12),
      children: [
        Container(
          height: 210,
          decoration: BoxDecoration(
            color: context.appSoftBrand,
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(
          3,
          (_) => Container(
            height: 115,
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    ),
  );
}
