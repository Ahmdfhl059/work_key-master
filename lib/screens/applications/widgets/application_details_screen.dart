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

part 'application_details/content.dart';
part 'application_details/shared.dart';
part 'application_details/states.dart';

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
