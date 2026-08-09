import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:work_key/data/models/job_model.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/utils/constants.dart';
import 'package:work_key/screens/jobs/job_details_screen.dart';

class ExploreJobCard extends StatelessWidget {
  final JobModel job;
  final bool showMatch;
  const ExploreJobCard({super.key, required this.job, required this.showMatch});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () =>
        navigateTo(context, JobDetailsScreen(jobId: job.id, initialJob: job)),
    borderRadius: BorderRadius.circular(22),
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: HomeColors.divider),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0915213A),
            blurRadius: 18,
            offset: Offset(0, 8),
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
                radius: 26,
                backgroundColor: HomeColors.softPurple,
                foregroundImage: job.company.logo.isNotEmpty
                    ? NetworkImage(job.company.logo)
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
                      text: job.title,
                      style: const TextStyle(
                        color: HomeColors.ink,
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
                      style: const TextStyle(
                        color: HomeColors.muted,
                        fontSize: 12.5,
                      ),
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
                    color: HomeColors.softPurple,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: DefaultText(
                    text: '${job.matchScore}%',
                    style: const TextStyle(
                      color: HomeColors.purple,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
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
                text: _published(job.createdAt),
                style: const TextStyle(color: HomeColors.muted, fontSize: 10.5),
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
  String _published(String raw) {
    final date = DateTime.tryParse(raw);
    return date == null
        ? 'Recently published'
        : DateFormat('MMM d, yyyy').format(date.toLocal());
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Chip({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFFF3F5F9),
      borderRadius: BorderRadius.circular(9),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: HomeColors.muted),
        const SizedBox(width: 4),
        DefaultText(
          text: text,
          style: const TextStyle(color: HomeColors.muted, fontSize: 10.5),
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
      color: HomeColors.softPurple,
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
