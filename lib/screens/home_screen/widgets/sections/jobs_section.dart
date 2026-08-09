import 'package:flutter/material.dart';
import 'package:work_key/data/models/home_response_model.dart';

import '../home_shared.dart';
import 'job_card.dart';

class HomeJobsSection extends StatefulWidget {
  final String title;
  final String? subtitle;
  final List<HomeJobModel> jobs;
  final bool recommended;
  final String emptyMessage;
  final bool horizontal;
  final VoidCallback? onViewMore;

  const HomeJobsSection({
    super.key,
    required this.title,
    this.subtitle,
    required this.jobs,
    this.recommended = false,
    required this.emptyMessage,
    this.horizontal = false,
    this.onViewMore,
  });

  @override
  State<HomeJobsSection> createState() => _HomeJobsSectionState();
}

class _HomeJobsSectionState extends State<HomeJobsSection> {
  static const int _initialCount = 3;

  @override
  Widget build(BuildContext context) {
    final visibleJobs = widget.jobs.take(_initialCount).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSectionHeader(
          title: widget.title,
          subtitle: widget.subtitle,
          onViewAll: widget.jobs.isNotEmpty ? widget.onViewMore : null,
          actionLabel: 'View more',
        ),
        const SizedBox(height: 14),
        if (widget.jobs.isEmpty)
          HomeEmptyState(
            icon: widget.recommended
                ? Icons.auto_awesome_outlined
                : Icons.work_outline_rounded,
            title: widget.emptyMessage,
            message: 'Pull down to check again.',
          )
        else
          AnimatedSize(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            child: widget.horizontal
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: visibleJobs
                          .map(
                            (job) => Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: SizedBox(
                                width: (MediaQuery.sizeOf(context).width * .74)
                                    .clamp(248.0, 300.0)
                                    .toDouble(),
                                child: HomeJobCard(
                                  job: job,
                                  recommended: widget.recommended,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  )
                : Column(
                    children: visibleJobs
                        .map(
                          (job) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: HomeJobCard(
                              job: job,
                              recommended: widget.recommended,
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
      ],
    );
  }
}
