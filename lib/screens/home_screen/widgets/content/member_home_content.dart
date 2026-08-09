import 'package:flutter/material.dart';
import 'package:work_key/data/models/home_response_model.dart';
import 'package:work_key/logic/explore_jobs_cubit/explore_jobs_state.dart';
import 'package:work_key/screens/explore_jobs/explore_jobs_screen.dart';
import 'package:work_key/shared/components/components.dart';

import '../home_sections.dart';

class MemberHomeContent extends StatelessWidget {
  final HomeResponseModel home;

  const MemberHomeContent({super.key, required this.home});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      HomeMemberHeader(viewer: home.viewer),
      if (home.profileCompleteness != null &&
          home.profileCompleteness!.percentage < 100) ...[
        const SizedBox(height: 20),
        HomeProfileCard(profile: home.profileCompleteness!),
      ],
      if (home.requiredAction != null) ...[
        const SizedBox(height: 20),
        HomeRequiredActionCard(action: home.requiredAction!),
      ],
      const SizedBox(height: 32),
      HomeJobsSection(
        title: 'Recommended for you',
        subtitle: home.recommendationsAvailable
            ? 'Selected from your profile and skills'
            : null,
        jobs: home.recommendedJobs,
        recommended: true,
        horizontal: true,
        onViewMore: () => navigateTo(
          context,
          const ExploreJobsScreen(initialTab: ExploreTab.forYou),
        ),
        emptyMessage: home.recommendationsAvailable
            ? 'No new recommendations yet'
            : 'Recommendations are not available yet',
      ),
      const SizedBox(height: 32),
      HomeCompaniesSection(companies: home.featuredCompanies),
      const SizedBox(height: 32),
      HomeJobsSection(
        title: 'New opportunities',
        jobs: home.latestJobs,
        onViewMore: () => navigateTo(
          context,
          const ExploreJobsScreen(initialTab: ExploreTab.latest),
        ),
        emptyMessage: 'No recent jobs right now',
      ),
    ],
  );
}
