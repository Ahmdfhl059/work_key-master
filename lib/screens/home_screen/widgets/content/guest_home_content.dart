import 'package:flutter/material.dart';
import 'package:work_key/data/models/home_response_model.dart';
import 'package:work_key/screens/auth/register/register_screen.dart';
import 'package:work_key/screens/explore_jobs/explore_jobs_screen.dart';
import 'package:work_key/shared/components/components.dart';

import '../home_sections.dart';
import 'guest_hero.dart';
import 'guest_top_bar.dart';
import 'join_banner.dart';

class GuestHomeContent extends StatelessWidget {
  final HomeResponseModel home;

  const GuestHomeContent({super.key, required this.home});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const GuestTopBar(),
      const SizedBox(height: 16),
      GuestHero(hero: home.hero),
      const SizedBox(height: 32),
      HomeJobsSection(
        title: 'Latest opportunities',
        jobs: home.latestJobs,
        horizontal: true,
        onViewMore: () => navigateTo(context, const ExploreJobsScreen()),
        emptyMessage: 'No recent jobs right now',
      ),
      const SizedBox(height: 32),
      HomeCompaniesSection(companies: home.featuredCompanies),
      if (home.appFeatures.isNotEmpty) ...[
        const SizedBox(height: 32),
        HomeFeaturesSection(features: home.appFeatures),
      ],
      const SizedBox(height: 24),
      HomeJoinBanner(onTap: () => navigateTo(context, const RegisterScreen())),
    ],
  );
}
