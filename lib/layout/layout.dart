import 'package:flutter/material.dart';
import 'package:work_key/logic/notifications_cubit/notifications_cubit.dart';
import 'package:work_key/localization/app_localizations.dart';
import 'package:work_key/shared/components/animated_app_logo.dart';

import '../screens/home_screen/home_screen.dart';
import '../screens/explore_jobs/explore_jobs_screen.dart';
import '../screens/applications/applications_screen.dart';
import '../screens/activity/activity_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../utils/constants.dart';

part 'widgets/home_nav_icon.dart';
part 'widgets/bottom_navigation.dart';
part 'widgets/animated_brand_header.dart';

class Layout extends StatefulWidget {
  const Layout({super.key});

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  int currentIndex = 2;
  late final List<Widget> _screens;
  final Set<int> _visitedTabs = {2};

  @override
  void initState() {
    super.initState();
    _screens = [
      ExploreJobsScreen(onBack: () => _selectTab(2)),
      ApplicationsScreen(onExplore: () => _selectTab(0)),
      const HomeScreen(),
      const ActivityScreen(),
      const ProfileScreen(),
    ];
    // جلب عداد الإشعارات عند تشغيل التطبيق
    NotificationsCubit.get(context).getUnreadCount();
  }

  void _selectTab(int index) {
    if (index == currentIndex) return;
    setState(() {
      currentIndex = index;
      _visitedTabs.add(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      extendBody: true,
      body: Column(
        children: [
          const _AnimatedBrandHeader(),
          Expanded(
            child: IndexedStack(
              index: currentIndex,
              children: List.generate(_screens.length, (index) {
                if (!_visitedTabs.contains(index)) {
                  return const SizedBox.shrink();
                }
                return AnimatedOpacity(
                  opacity: currentIndex == index ? 1 : 0,
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  child: _screens[index],
                );
              }),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _WorkeyBottomNavigation(
        selectedIndex: currentIndex,
        onSelected: _selectTab,
      ),
    );
  }
}
