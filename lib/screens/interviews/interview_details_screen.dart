import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/interview_model.dart';
import '../../data/repo/interviews_repo.dart';
import '../../localization/app_localizations.dart';
import '../../shared/components/components.dart';
import '../../utils/constants.dart';
import 'interview_strings.dart';
import 'interview_theme.dart';
import 'interview_video_screen.dart';

part 'widgets/interview_details/content.dart';
part 'widgets/interview_details/detail_cards.dart';
part 'widgets/interview_details/states.dart';

class InterviewDetailsScreen extends StatefulWidget {
  final int interviewId;
  final InterviewModel? initialInterview;

  const InterviewDetailsScreen({
    super.key,
    required this.interviewId,
    this.initialInterview,
  });

  @override
  State<InterviewDetailsScreen> createState() => _InterviewDetailsScreenState();
}

class _InterviewDetailsScreenState extends State<InterviewDetailsScreen> {
  final InterviewsRepo _repo = InterviewsRepo();
  InterviewModel? _interview;
  String? _error;
  bool _loading = false;
  bool _confirming = false;
  bool _joining = false;

  @override
  void initState() {
    super.initState();
    _interview = widget.initialInterview;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = _interview == null;
      _error = null;
    });
    try {
      final interview = await _repo.getInterviewDetails(widget.interviewId);
      if (mounted) setState(() => _interview = interview);
    } catch (_) {
      if (mounted && _interview == null) {
        setState(() => _error = 'We could not load the interview details.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = InterviewStrings.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context, _interview),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: DefaultText(
          text: strings.detailsTitle,
          style: TextStyle(
            color: context.appInk,
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: _loading
          ? const _DetailsLoading()
          : _error != null || _interview == null
          ? _DetailsError(onRetry: _load)
          : _DetailsContent(
              interview: _interview!,
              confirming: _confirming,
              joining: _joining,
              onConfirm: _confirm,
              onJoin: _joinInterview,
            ),
    );
  }

  Future<void> _confirm() async {
    if (_confirming || _interview?.needsConfirmation != true) return;
    final strings = InterviewStrings.of(context);
    final accepted =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            icon: const Icon(
              Icons.event_available_rounded,
              color: HomeColors.purple,
              size: 34,
            ),
            title: Text(strings.confirm),
            content: Text(strings.confirmQuestion),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(strings.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(
                  backgroundColor: HomeColors.purple,
                ),
                child: Text(strings.confirmAction),
              ),
            ],
          ),
        ) ??
        false;
    if (!accepted || !mounted) return;

    setState(() => _confirming = true);
    try {
      final confirmed = await _repo.confirmInterview(widget.interviewId);
      if (!mounted) return;
      setState(() => _interview = confirmed);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.confirmedMessage)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('Attendance could not be confirmed.')),
        ),
      );
    } finally {
      if (mounted) setState(() => _confirming = false);
    }
  }

  Future<void> _joinInterview() async {
    final interview = _interview;
    if (_joining || interview == null) return;
    setState(() => _joining = true);
    try {
      final session = await _repo.createVideoSession(interview.id);
      if (!mounted) return;
      await navigateTo(
        context,
        InterviewVideoScreen(session: session, title: interview.jobTitle),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr(
              'The in-app video room is not available yet. It opens near the interview time.',
            ),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }
}
