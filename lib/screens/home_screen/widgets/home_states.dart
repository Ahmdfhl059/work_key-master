import 'package:flutter/material.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/utils/constants.dart';
import 'package:work_key/utils/shared%20preferences.dart';

class HomeLoadingView extends StatelessWidget {
  const HomeLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticated = CacheHelper.getData(key: 'token') != null;
    return ResponsiveContent(
      child: ListView(
        padding: const EdgeInsets.only(top: 20, bottom: 120),
        children: authenticated
            ? const [_MemberHomeSkeleton()]
            : const [_GuestHomeSkeleton()],
      ),
    );
  }
}

class _MemberHomeSkeleton extends StatelessWidget {
  const _MemberHomeSkeleton();

  @override
  Widget build(BuildContext context) => const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderSkeleton(),
          SizedBox(height: 20),
          _SearchSkeleton(),
          SizedBox(height: 20),
          _ProfileSkeleton(),
          SizedBox(height: 20),
          _ActionSkeleton(),
          SizedBox(height: 32),
          _SectionTitleSkeleton(width: 190),
          SizedBox(height: 14),
          _HorizontalJobsSkeleton(),
          SizedBox(height: 32),
          _SectionTitleSkeleton(width: 175),
          SizedBox(height: 14),
          _CompaniesSkeleton(),
          SizedBox(height: 32),
          _SectionTitleSkeleton(width: 160),
          SizedBox(height: 14),
          JobCardSkeleton(),
          SizedBox(height: 12),
          JobCardSkeleton(),
        ],
      );
}

class _GuestHomeSkeleton extends StatelessWidget {
  const _GuestHomeSkeleton();

  @override
  Widget build(BuildContext context) => const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderSkeleton(),
          SizedBox(height: 16),
          SkeletonBox(width: double.infinity, height: 330, radius: 27),
          SizedBox(height: 20),
          _SearchSkeleton(),
          SizedBox(height: 32),
          _SectionTitleSkeleton(width: 175),
          SizedBox(height: 14),
          _HorizontalJobsSkeleton(),
          SizedBox(height: 32),
          _SectionTitleSkeleton(width: 180),
          SizedBox(height: 14),
          _CompaniesSkeleton(),
          SizedBox(height: 32),
          _SectionTitleSkeleton(width: 205),
          SizedBox(height: 14),
          SkeletonBox(width: double.infinity, height: 104, radius: 22),
          SizedBox(height: 12),
          SkeletonBox(width: double.infinity, height: 104, radius: 22),
        ],
      );
}

class _HeaderSkeleton extends StatelessWidget {
  const _HeaderSkeleton();
  @override
  Widget build(BuildContext context) => const Row(children: [
        SkeletonBox(width: 56, height: 56, radius: 28),
        SizedBox(width: 13),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SkeletonBox(width: 95, height: 11),
          SizedBox(height: 8),
          SkeletonBox(width: 155, height: 18),
        ])),
        SkeletonBox(width: 46, height: 46, radius: 15),
      ]);
}

class _SearchSkeleton extends StatelessWidget {
  const _SearchSkeleton();
  @override
  Widget build(BuildContext context) => const SkeletonBox(width: double.infinity, height: 58, radius: 18);
}

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();
  @override
  Widget build(BuildContext context) => const Row(children: [
        SkeletonBox(width: 76, height: 76, radius: 38),
        SizedBox(width: 18),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SkeletonBox(width: 145, height: 16),
          SizedBox(height: 9),
          SkeletonBox(width: 220, height: 11),
          SizedBox(height: 8),
          SkeletonBox(width: 110, height: 11),
        ])),
      ]);
}

class _ActionSkeleton extends StatelessWidget {
  const _ActionSkeleton();
  @override
  Widget build(BuildContext context) => const SkeletonBox(width: double.infinity, height: 92, radius: 22);
}

class _SectionTitleSkeleton extends StatelessWidget {
  final double width;
  const _SectionTitleSkeleton({required this.width});
  @override
  Widget build(BuildContext context) => SkeletonBox(width: width, height: 20);
}

class _HorizontalJobsSkeleton extends StatelessWidget {
  const _HorizontalJobsSkeleton();
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Row(children: const [
          SizedBox(width: 310, child: JobCardSkeleton()),
          SizedBox(width: 12),
          SizedBox(width: 310, child: JobCardSkeleton()),
        ]),
      );
}

class _CompaniesSkeleton extends StatelessWidget {
  const _CompaniesSkeleton();
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Row(children: const [
          SkeletonBox(width: 180, height: 112, radius: 22),
          SizedBox(width: 10),
          SkeletonBox(width: 180, height: 112, radius: 22),
          SizedBox(width: 10),
          SkeletonBox(width: 180, height: 112, radius: 22),
        ]),
      );
}

class HomeErrorView extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;
  const HomeErrorView({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => RefreshIndicator(
        onRefresh: onRetry,
        child: ResponsiveContent(
          maxWidth: 560,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 110),
            children: [
              const Icon(Icons.cloud_off_rounded, size: 68, color: HomeColors.muted),
              const SizedBox(height: 20),
              const DefaultText(text: 'Unable to load Home', style: TextStyle(color: HomeColors.ink, fontSize: 21, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              DefaultText(text: message, style: const TextStyle(color: HomeColors.muted, height: 1.5)),
              const SizedBox(height: 22),
              DefaultButton(
                background: HomeColors.brand,
                text: 'Try again',
                fontSize: 14,
                borderRadius: 14,
                uppercase: false,
                onPress: () {
                  onRetry();
                },
              ),
            ],
          ),
        ),
      );
}

class HomeAccessView extends StatelessWidget {
  final bool suspended;
  const HomeAccessView.suspended({super.key}) : suspended = true;
  const HomeAccessView.wrongRole({super.key}) : suspended = false;

  @override
  Widget build(BuildContext context) => ResponsiveContent(
        maxWidth: 560,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(suspended ? Icons.lock_clock_rounded : Icons.phonelink_lock_rounded, color: suspended ? HomeColors.warning : HomeColors.brand, size: 72),
              const SizedBox(height: 20),
              DefaultText(text: suspended ? 'Account suspended' : 'Home is for job seekers', style: const TextStyle(color: HomeColors.ink, fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              DefaultText(
                text: suspended ? 'Your account is currently unavailable. Please contact support for more information.' : 'Sign in with a job seeker account to access the mobile Home experience.',
                style: const TextStyle(color: HomeColors.muted, height: 1.6),
              ),
            ],
          ),
        ),
      );
}
