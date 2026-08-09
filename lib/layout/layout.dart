import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:work_key/logic/notifications_cubit/notifications_cubit.dart';
import 'package:work_key/logic/notifications_cubit/notifications_state.dart';
import 'package:work_key/shared/images/image.dart';

import '../screens/home_screen/home_screen.dart';
import '../screens/explore_jobs/explore_jobs_screen.dart';
import '../screens/applications/applications_screen.dart';
import '../screens/activity/activity_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../shared/components/components.dart';
import '../utils/constants.dart';

class Layout extends StatefulWidget {
  const Layout({super.key});

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  int currentIndex = 0;
  late final List<Widget> _screens;
  final Set<int> _visitedTabs = {0};

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(),
      ExploreJobsScreen(onBack: () => _selectTab(0)),
      const ApplicationsScreen(),
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
      backgroundColor: background,
      appBar: AppBar(
        centerTitle: true,
        surfaceTintColor: background,
        backgroundColor: background,
        elevation: 0,
        leading: DefaultIconButton(
          onPressed: () {},
          icon: Icon(FontAwesomeIcons.barsStaggered, color: primary, size: 22),
        ),
        title: Image.asset(AppImages.logo, height: 50, width: 200),
        actions: [
          // أيقونة الإشعارات مع العداد الحقيقي
          BlocBuilder<NotificationsCubit, NotificationsStates>(
            builder: (context, state) {
              int count = 0;
              if (state is GetUnreadCountSuccessState) count = state.count;

              return Stack(
                alignment: Alignment.topRight,
                children: [
                  //  DefaultIconButton(
                  //  // onPressed: () => navigateTo(context, const NotificationsScreen()),
                  //   icon: Icon(FontAwesomeIcons.bell, color: primary, size: 22),
                  // ),
                  if (count > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: CircleAvatar(
                        radius: 8,
                        backgroundColor: Colors.red,
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          DefaultIconButton(
            onPressed: () {},
            icon: Icon(FontAwesomeIcons.comment, color: primary, size: 22),
          ),
        ],
      ),
      extendBody: true,
      body: IndexedStack(
        index: currentIndex,
        children: List.generate(_screens.length, (index) {
          if (!_visitedTabs.contains(index)) return const SizedBox.shrink();
          return AnimatedOpacity(
            opacity: currentIndex == index ? 1 : 0,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: _screens[index],
          );
        }),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              blurRadius: 30,
              color: Colors.black.withValues(alpha: 0.1),
            ),
          ],
        ),
        child: SafeArea(
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              labelTextStyle: WidgetStateProperty.resolveWith(
                (states) => TextStyle(
                  fontSize: states.contains(WidgetState.selected) ? 10.5 : 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            child: NavigationBar(
              height: 72,
              selectedIndex: currentIndex,
              backgroundColor: Colors.transparent,
              elevation: 0,
              indicatorColor: HomeColors.softPurple,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined, size: 22),
                  selectedIcon: Icon(
                    Icons.home_rounded,
                    size: 22,
                    color: HomeColors.purple,
                  ),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.travel_explore_outlined, size: 22),
                  selectedIcon: Icon(
                    Icons.travel_explore_rounded,
                    size: 22,
                    color: HomeColors.purple,
                  ),
                  label: 'Explore',
                ),
                NavigationDestination(
                  icon: Icon(Icons.assignment_outlined, size: 22),
                  selectedIcon: Icon(
                    Icons.assignment_rounded,
                    size: 22,
                    color: HomeColors.purple,
                  ),
                  label: 'Applications',
                ),
                NavigationDestination(
                  icon: Icon(Icons.notifications_none_rounded, size: 22),
                  selectedIcon: Icon(
                    Icons.notifications_rounded,
                    size: 22,
                    color: HomeColors.purple,
                  ),
                  label: 'Activity',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded, size: 22),
                  selectedIcon: Icon(
                    Icons.person_rounded,
                    size: 22,
                    color: HomeColors.purple,
                  ),
                  label: 'Profile',
                ),
              ],
              onDestinationSelected: (i) {
                _selectTab(i);
              },
            ),
          ),
        ),
      ),
    );
  }
}
