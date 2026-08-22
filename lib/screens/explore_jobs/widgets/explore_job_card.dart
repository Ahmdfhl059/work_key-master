import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:work_key/data/models/job_model.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/utils/constants.dart';
import 'package:work_key/screens/jobs/job_details_screen.dart';
import 'package:work_key/shared/components/company_logo.dart';
import 'package:work_key/localization/app_localizations.dart';

class ExploreJobCard extends StatelessWidget {
  final JobModel job;
  final bool showMatch;
  const ExploreJobCard({super.key, required this.job, required this.showMatch});

  @override
  Widget build(BuildContext context) => AnimatedPressableCard(
    onTap: () =>
        navigateTo(context, JobDetailsScreen(jobId: job.id, initialJob: job)),
    borderRadius: BorderRadius.circular(26),
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            Theme.of(context).colorScheme.surfaceContainerHighest,
            Theme.of(context).colorScheme.surfaceContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: HomeColors.brand.withValues(alpha: .22)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F18A949),
            blurRadius: 26,
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
              CompanyLogo(
                size: 52,
                url: job.company.logo,
                companyName: job.company.name,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DefaultText(
                      text: job.title,
                      style: TextStyle(
                        color: context.appInk,
                        fontSize: 17,
                        height: 1.3,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    DefaultText(
                      text: job.company.name.isEmpty
                          ? 'Company'
                          : job.company.name,
                      style: TextStyle(color: context.appMuted, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
              if (showMatch && job.matchScore != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: context.appSoftBrand,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: DefaultText(
                    text: '${_scoreLabel(job.matchScore!)}%',
                    style: const TextStyle(
                      color: HomeColors.purple,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          if (job.hasApplied || job.isExpired || job.isNew) ...[
            const SizedBox(height: 10),
            _StateBadge(
              icon: job.hasApplied
                  ? Icons.check_circle_rounded
                  : job.isExpired
                  ? Icons.event_busy_rounded
                  : Icons.fiber_new_rounded,
              text: job.hasApplied
                  ? (job.viewerApplicationStatus.isEmpty
                        ? context.tr('jobs.already_applied')
                        : job.viewerApplicationStatus)
                  : context.tr(job.isExpired ? 'jobs.expired' : 'jobs.new'),
              color: job.isExpired && !job.hasApplied
                  ? const Color(0xFFB24A4A)
                  : HomeColors.brand,
              background: job.isExpired && !job.hasApplied
                  ? const Color(0xFFFBEAEA)
                  : const Color(0xFFE5F6E9),
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              if (job.location.isNotEmpty)
                _Chip(icon: Icons.location_on_outlined, text: job.location),
              if (job.workMode.isNotEmpty)
                _Chip(icon: Icons.laptop_rounded, text: _pretty(job.workMode)),
              if (job.employmentType.isNotEmpty)
                _Chip(
                  icon: Icons.schedule_rounded,
                  text: _pretty(job.employmentType),
                ),
            ],
          ),
          if (job.skills.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: job.skills
                  .take(4)
                  .map((skill) => _SkillChip(skill.name))
                  .toList(),
            ),
          ],
          const SizedBox(height: 13),
          Row(
            children: [
              DefaultText(
                text: _published(context, job.createdAt),
                style: TextStyle(color: context.appMuted, fontSize: 10.5),
              ),
              const Spacer(),
              const Icon(
                Icons.arrow_forward_rounded,
                color: HomeColors.purple,
                size: 19,
              ),
            ],
          ),
        ],
      ),
    ),
  );

  String _pretty(String text) => text.replaceAll('_', ' ');
  String _scoreLabel(num score) {
    final safe = score.clamp(0, 100);
    return safe == safe.roundToDouble()
        ? safe.round().toString()
        : safe.toStringAsFixed(1);
  }

  String _published(BuildContext context, String raw) {
    final date = DateTime.tryParse(raw);
    return date == null
        ? context.tr('Recently published')
        : DateFormat(
            'MMM d, yyyy',
            Localizations.localeOf(context).toLanguageTag(),
          ).format(date.toLocal());
  }
}

class _StateBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final Color background;
  const _StateBadge({
    required this.icon,
    required this.text,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Chip({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(9),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: context.appMuted),
        const SizedBox(width: 4),
        DefaultText(
          text: text,
          style: TextStyle(color: context.appMuted, fontSize: 10.5),
        ),
      ],
    ),
  );
}

class _SkillChip extends StatelessWidget {
  final String text;
  const _SkillChip(this.text);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: context.appSoftBrand,
      borderRadius: BorderRadius.circular(8),
    ),
    child: DefaultText(
      text: text,
      style: const TextStyle(
        color: HomeColors.purple,
        fontSize: 10,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
