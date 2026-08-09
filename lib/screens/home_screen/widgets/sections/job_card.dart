import 'package:flutter/material.dart';
import 'package:work_key/data/models/home_response_model.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/utils/constants.dart';
import 'package:work_key/screens/jobs/job_details_screen.dart';

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
  Widget build(BuildContext context) => InkWell(
    onTap: job.id < 0
        ? null
        : () => navigateTo(context, JobDetailsScreen(jobId: job.id)),
    borderRadius: BorderRadius.circular(22),
    child: HomeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: recommended
                      ? HomeColors.softPurple
                      : HomeColors.softBlue,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.business_rounded,
                  color: recommended ? HomeColors.purple : HomeColors.brand,
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 14),
          DefaultText(
            text: job.title,
            style: const TextStyle(
              color: HomeColors.ink,
              fontSize: 16.5,
              height: 1.3,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          DefaultText(
            text: job.companyName ?? 'Featured company',
            style: const TextStyle(
              color: HomeColors.muted,
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
            text: _relativeDate(job.publishedAt),
            style: const TextStyle(color: HomeColors.muted, fontSize: 10.5),
          ),
        ],
      ),
    ),
  );

  String _relativeDate(String? raw) {
    final date = DateTime.tryParse(raw ?? '')?.toLocal();
    if (date == null) return 'Recently published';
    final days = DateTime.now().difference(date).inDays;
    if (days <= 0) return 'Published today';
    if (days == 1) return 'Published yesterday';
    return 'Published $days days ago';
  }
}
