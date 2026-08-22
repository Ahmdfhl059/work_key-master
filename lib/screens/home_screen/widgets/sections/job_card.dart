import 'package:flutter/material.dart';
import 'package:work_key/data/models/home_response_model.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/utils/constants.dart';
import 'package:work_key/screens/jobs/job_details_screen.dart';
import 'package:work_key/shared/components/company_logo.dart';
import 'package:work_key/localization/app_localizations.dart';

import '../home_shared.dart';

class HomeJobCard extends StatelessWidget {
  final HomeJobModel job;
  final bool recommended;
  const HomeJobCard({super.key, required this.job, required this.recommended});

  String _pretty(String value) => value
      .replaceAll('_', ' ')
      .split(' ')
      .map(
        (word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1)}',
      )
      .join(' ');

  @override
  Widget build(BuildContext context) => AnimatedPressableCard(
    onTap: job.id < 0
        ? null
        : () => navigateTo(context, JobDetailsScreen(jobId: job.id)),
    borderRadius: BorderRadius.circular(24),
    child: HomeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CompanyLogo(
                size: 46,
                url: job.companyLogoUrl,
                companyName: job.companyName ?? '',
              ),
              const Spacer(),
              if (recommended && job.matchScore != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6B55C8), Color(0xFF4D63D2)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${_scoreLabel(job.matchScore!)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (job.hasApplied || job.isExpired || job.isNew) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              decoration: BoxDecoration(
                color: job.isExpired && !job.hasApplied
                    ? const Color(0xFFFBEAEA)
                    : const Color(0xFFE5F6E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    job.hasApplied
                        ? Icons.check_circle_rounded
                        : job.isExpired
                        ? Icons.event_busy_rounded
                        : Icons.fiber_new_rounded,
                    size: 14,
                    color: job.isExpired && !job.hasApplied
                        ? const Color(0xFFB24A4A)
                        : HomeColors.brand,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    job.hasApplied
                        ? (job.applicationStatus.isEmpty
                              ? context.tr('jobs.already_applied')
                              : job.applicationStatus)
                        : context.tr(
                            job.isExpired ? 'jobs.expired' : 'jobs.new',
                          ),
                    style: TextStyle(
                      color: job.isExpired && !job.hasApplied
                          ? const Color(0xFFB24A4A)
                          : HomeColors.brand,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          DefaultText(
            text: job.title,
            style: TextStyle(
              color: context.appInk,
              fontSize: 16.5,
              height: 1.3,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          DefaultText(
            text: job.companyName ?? 'Featured company',
            style: TextStyle(
              color: context.appMuted,
              fontSize: 12.5,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (job.workMode != null) HomeTag(_pretty(job.workMode!)),
              if (job.employmentType != null)
                HomeTag(_pretty(job.employmentType!)),
              if (job.location != null) HomeTag(job.location!),
            ],
          ),
          const SizedBox(height: 14),
          DefaultText(
            text: _relativeDate(context, job.publishedAt),
            style: TextStyle(color: context.appMuted, fontSize: 10.5),
          ),
        ],
      ),
    ),
  );

  String _relativeDate(BuildContext context, String? raw) {
    final date = DateTime.tryParse(raw ?? '')?.toLocal();
    if (date == null) return context.tr('Recently published');
    final days = DateTime.now().difference(date).inDays;
    if (days <= 0) return context.tr('Published today');
    if (days == 1) return context.tr('Published yesterday');
    return context.tr('home.published_days', values: {'count': days});
  }

  String _scoreLabel(num score) {
    final safe = score.clamp(0, 100);
    return safe == safe.roundToDouble()
        ? safe.round().toString()
        : safe.toStringAsFixed(1);
  }
}
