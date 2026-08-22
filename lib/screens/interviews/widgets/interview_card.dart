import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/models/interview_model.dart';
import '../../../shared/components/components.dart';
import '../../../utils/constants.dart';
import '../interview_strings.dart';
import '../interview_theme.dart';

class InterviewCard extends StatelessWidget {
  final InterviewModel interview;
  final VoidCallback onTap;

  const InterviewCard({
    super.key,
    required this.interview,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final strings = InterviewStrings.of(context);
    final theme = InterviewVisualTheme.from(interview.status.key);
    final date = interview.scheduledStartAt;
    return Semantics(
      button: true,
      label: '${interview.type.label}, ${interview.jobTitle}',
      child: AnimatedPressableCard(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.surfaceContainer,
                theme.background.withValues(alpha: .30),
              ],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: interview.needsConfirmation
                  ? HomeColors.purple.withValues(alpha: .32)
                  : context.appDivider,
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
                  _CompanyLogo(
                    url: interview.companyLogoUrl,
                    name: interview.companyName,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DefaultText(
                          text: interview.jobTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 16,
                            height: 1.3,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        DefaultText(
                          text: interview.companyName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusBadge(
                    label: interview.status.label.isEmpty
                        ? interview.status.key
                        : interview.status.label,
                    theme: theme,
                  ),
                ],
              ),
              if (date != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [context.appSoftBrand, Color(0xFFF7F6FF)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.event_available_rounded,
                        color: HomeColors.purple,
                        size: 20,
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: DefaultText(
                          text: DateFormat('EEE, MMM d • h:mm a').format(date),
                          style: TextStyle(
                            color: context.appInk,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (interview.durationMinutes > 0)
                        DefaultText(
                          text: strings.minutes(interview.durationMinutes),
                          style: TextStyle(
                            color: context.appMuted,
                            fontSize: 10.5,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 13),
              Row(
                children: [
                  _InfoChip(
                    icon: interview.isOnline
                        ? Icons.videocam_outlined
                        : Icons.location_on_outlined,
                    label: interview.mode.label.isEmpty
                        ? interview.mode.key
                        : interview.mode.label,
                  ),
                  if (interview.type.label.isNotEmpty) ...[
                    const SizedBox(width: 7),
                    Flexible(
                      child: _InfoChip(
                        icon: Icons.groups_2_outlined,
                        label: interview.type.label,
                      ),
                    ),
                  ],
                  const Spacer(),
                  DefaultTextButton(
                    text: interview.needsConfirmation
                        ? strings.confirm
                        : strings.viewDetails,
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
          ),
        ),
      ),
    );
  }
}

class _CompanyLogo extends StatelessWidget {
  final String? url;
  final String name;
  const _CompanyLogo({this.url, required this.name});

  @override
  Widget build(BuildContext context) => CircleAvatar(
    radius: 26,
    backgroundColor: context.appSoftBrand,
    foregroundImage: url?.isNotEmpty == true ? NetworkImage(url!) : null,
    onForegroundImageError: url?.isNotEmpty == true ? (_, __) {} : null,
    child: url?.isNotEmpty == true
        ? null
        : Text(
            name.isEmpty ? 'W' : name.characters.first.toUpperCase(),
            style: const TextStyle(
              color: HomeColors.purple,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
  );
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final InterviewVisualTheme theme;
  const _StatusBadge({required this.label, required this.theme});

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(maxWidth: 112),
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: theme.background,
      borderRadius: BorderRadius.circular(20),
    ),
    child: DefaultText(
      text: label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: theme.foreground,
        fontSize: 9.5,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(maxWidth: 150),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    decoration: BoxDecoration(
      color: context.appCanvas,
      borderRadius: BorderRadius.circular(9),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: context.appMuted, size: 13),
        const SizedBox(width: 4),
        Flexible(
          child: DefaultText(
            text: label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: context.appMuted, fontSize: 9.5),
          ),
        ),
      ],
    ),
  );
}
