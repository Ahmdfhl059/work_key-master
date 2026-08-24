part of '../../interview_details_screen.dart';

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
