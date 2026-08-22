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

class _DetailsContent extends StatelessWidget {
  final InterviewModel interview;
  final bool confirming;
  final bool joining;
  final VoidCallback onConfirm;
  final VoidCallback onJoin;

  const _DetailsContent({
    required this.interview,
    required this.confirming,
    required this.joining,
    required this.onConfirm,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    final strings = InterviewStrings.of(context);
    final statusTheme = InterviewVisualTheme.from(interview.status.key);
    final start = interview.scheduledStartAt;
    return ResponsiveContent(
      maxWidth: 760,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(top: 10, bottom: 38),
        children: [
          _DetailsHero(interview: interview, theme: statusTheme),
          const SizedBox(height: 16),
          if (start != null)
            _ScheduleCard(
              start: start,
              end: interview.scheduledEndAt,
              duration: interview.durationMinutes,
            ),
          if (start != null) const SizedBox(height: 16),
          _DetailsSection(
            title: strings.detailsTitle,
            icon: Icons.info_outline_rounded,
            children: [
              _DetailRow(
                icon: interview.isOnline
                    ? Icons.videocam_outlined
                    : Icons.location_on_outlined,
                label: strings.mode,
                value: interview.mode.label.isEmpty
                    ? interview.mode.key
                    : interview.mode.label,
              ),
              if (interview.durationMinutes > 0)
                _DetailRow(
                  icon: Icons.timer_outlined,
                  label: strings.duration,
                  value: strings.minutes(interview.durationMinutes),
                ),
              _DetailRow(
                icon: Icons.how_to_reg_outlined,
                label: strings.confirmation,
                value: interview.confirmationStatus.label.isEmpty
                    ? interview.confirmationStatus.key
                    : interview.confirmationStatus.label,
              ),
              if (interview.location != null)
                _DetailRow(
                  icon: Icons.location_on_outlined,
                  label: strings.location,
                  value: interview.location!,
                ),
            ],
          ),
          if (interview.candidateMessage != null) ...[
            const SizedBox(height: 16),
            _MessageCard(
              icon: Icons.mark_email_read_outlined,
              title: context.tr('interviews.company_message'),
              message: interview.candidateMessage!,
              color: HomeColors.purple,
            ),
          ],
          if (interview.cancellationMessage != null) ...[
            const SizedBox(height: 16),
            _MessageCard(
              icon: Icons.event_busy_outlined,
              title: context.tr('interviews.cancellation_update'),
              message: interview.cancellationMessage!,
              color: const Color(0xFFAA4545),
            ),
          ],
          const SizedBox(height: 21),
          if (interview.needsConfirmation)
            DefaultButton(
              background: HomeColors.purple,
              text: confirming
                  ? context.tr('interviews.confirming')
                  : strings.confirm,
              uppercase: false,
              height: 54,
              borderRadius: 16,
              fontSize: 14,
              onPress: confirming ? () {} : onConfirm,
            ),
          if (interview.canOpenMeeting) ...[
            if (interview.needsConfirmation) const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: joining ? null : onJoin,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                foregroundColor: HomeColors.purple,
                side: const BorderSide(color: HomeColors.purple),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: Icon(
                interview.canJoinEmbeddedVideo
                    ? Icons.video_call_rounded
                    : Icons.open_in_new_rounded,
              ),
              label: Text(
                joining ? context.tr('interviews.opening_room') : strings.join,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailsHero extends StatelessWidget {
  final InterviewModel interview;
  final InterviewVisualTheme theme;
  const _DetailsHero({required this.interview, required this.theme});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(21),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF29B148), Color(0xFF0FA348)],
      ),
      borderRadius: BorderRadius.circular(27),
      boxShadow: const [
        BoxShadow(
          color: Color(0x2A18A949),
          blurRadius: 28,
          offset: Offset(0, 13),
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
              radius: 29,
              backgroundColor: Colors.white,
              foregroundImage: interview.companyLogoUrl?.isNotEmpty == true
                  ? NetworkImage(interview.companyLogoUrl!)
                  : null,
              child: interview.companyLogoUrl?.isNotEmpty == true
                  ? null
                  : const Icon(
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
                    text: interview.jobTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      height: 1.3,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  DefaultText(
                    text: interview.companyName,
                    style: const TextStyle(
                      color: Color(0xFFE8F7ED),
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _HeroChip(
              icon: Icons.groups_2_outlined,
              text: interview.type.label,
            ),
            _HeroChip(
              icon: theme.icon,
              text: interview.status.label.isEmpty
                  ? interview.status.key
                  : interview.status.label,
            ),
          ],
        ),
      ],
    ),
  );
}

class _HeroChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _HeroChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .15),
      borderRadius: BorderRadius.circular(11),
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
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _ScheduleCard extends StatelessWidget {
  final DateTime start;
  final DateTime? end;
  final int duration;
  const _ScheduleCard({required this.start, this.end, required this.duration});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Theme.of(context).colorScheme.surfaceContainer,
          Theme.of(context).colorScheme.primaryContainer.withValues(alpha: .24),
        ],
      ),
      borderRadius: BorderRadius.circular(21),
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    child: Row(
      children: [
        Container(
          width: 58,
          height: 63,
          decoration: BoxDecoration(
            color: context.appSoftBrand,
            borderRadius: BorderRadius.circular(17),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                DateFormat('d').format(start),
                style: TextStyle(
                  color: HomeColors.purple,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                DateFormat('MMM').format(start).toUpperCase(),
                style: TextStyle(
                  color: HomeColors.purple,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DefaultText(
                text: DateFormat('EEEE, MMMM d').format(start),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              DefaultText(
                text: end == null
                    ? DateFormat('h:mm a').format(start)
                    : '${DateFormat('h:mm a').format(start)} — ${DateFormat('h:mm a').format(end!)}',
                style: TextStyle(
                  color: context.appMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.schedule_rounded, color: HomeColors.purple),
      ],
    ),
  );
}

class _DetailsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  const _DetailsSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(21),
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: HomeColors.purple, size: 20),
            const SizedBox(width: 8),
            DefaultText(
              text: title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    ),
  );
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: context.appSoftBrand,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 17, color: HomeColors.purple),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DefaultText(
                text: label,
                style: TextStyle(color: context.appMuted, fontSize: 10),
              ),
              const SizedBox(height: 3),
              DefaultText(
                text: value,
                style: TextStyle(
                  color: context.appInk,
                  fontSize: 12.5,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _MessageCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Color color;
  const _MessageCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(19),
      border: Border.all(color: color.withValues(alpha: .15)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 21),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DefaultText(
                text: title,
                style: TextStyle(
                  color: color,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              DefaultText(
                text: message,
                style: TextStyle(
                  color: context.appMuted,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _DetailsLoading extends StatelessWidget {
  const _DetailsLoading();
  @override
  Widget build(BuildContext context) => const ResponsiveContent(
    maxWidth: 760,
    child: Padding(
      padding: EdgeInsets.only(top: 12),
      child: Column(
        children: [
          SkeletonBox(width: double.infinity, height: 185, radius: 27),
          SizedBox(height: 16),
          SkeletonBox(width: double.infinity, height: 96, radius: 21),
          SizedBox(height: 16),
          SkeletonBox(width: double.infinity, height: 240, radius: 21),
        ],
      ),
    ),
  );
}

class _DetailsError extends StatelessWidget {
  final VoidCallback onRetry;
  const _DetailsError({required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: ResponsiveContent(
      maxWidth: 420,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: HomeColors.warning,
            size: 58,
          ),
          const SizedBox(height: 14),
          DefaultText(
            text: 'interviews.details_load_error',
            textAlign: TextAlign.center,
            style: TextStyle(color: context.appMuted),
          ),
          const SizedBox(height: 18),
          ModernRetryButton(onRetry: onRetry),
        ],
      ),
    ),
  );
}
