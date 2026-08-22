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

class _AnimatedHomeNavIcon extends StatefulWidget {
  final bool selected;
  const _AnimatedHomeNavIcon({required this.selected});

  @override
  State<_AnimatedHomeNavIcon> createState() => _AnimatedHomeNavIconState();
}

class _AnimatedHomeNavIconState extends State<_AnimatedHomeNavIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    if (widget.selected) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _AnimatedHomeNavIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected && !oldWidget.selected) {
      _controller.repeat(reverse: true);
    } else if (!widget.selected && oldWidget.selected) {
      _controller
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, child) {
      final pulse = widget.selected ? _controller.value : 0.0;
      return Transform.translate(
        offset: Offset(0, widget.selected ? -3 - (pulse * 2) : 0),
        child: Transform.rotate(
          angle: widget.selected ? (pulse - .5) * .06 : 0,
          child: Transform.scale(
            scale: widget.selected ? 1 + (pulse * .07) : 1,
            child: child,
          ),
        ),
      );
    },
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      width: widget.selected ? 50 : 38,
      height: widget.selected ? 50 : 38,
      padding: EdgeInsets.all(widget.selected ? 5 : 2),
      decoration: BoxDecoration(
        color: widget.selected
            ? Theme.of(context).colorScheme.primaryContainer
            : Colors.transparent,
        shape: BoxShape.circle,
        boxShadow: widget.selected
            ? [
                BoxShadow(
                  color: HomeColors.brand.withValues(alpha: .24),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
                ),
              ]
            : null,
      ),
      child: Image.asset('assets/images/brand_icon.png'),
    ),
  );
}

class _WorkeyBottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _WorkeyBottomNavigation({
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      child: SizedBox(
        height: 88,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              height: 72,
              decoration: BoxDecoration(
                color: colors.surfaceContainer.withValues(alpha: .98),
                borderRadius: BorderRadius.circular(27),
                border: Border.all(
                  color: colors.primary.withValues(alpha: dark ? .22 : .13),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: dark ? .38 : .13),
                    blurRadius: 34,
                    offset: const Offset(0, 14),
                    spreadRadius: -5,
                  ),
                  BoxShadow(
                    color: colors.primary.withValues(alpha: .10),
                    blurRadius: 24,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _NavItem(
                    index: 0,
                    selectedIndex: selectedIndex,
                    icon: Icons.travel_explore_outlined,
                    selectedIcon: Icons.travel_explore_rounded,
                    label: context.tr('nav.explore'),
                    onTap: onSelected,
                  ),
                  _NavItem(
                    index: 1,
                    selectedIndex: selectedIndex,
                    icon: Icons.description_outlined,
                    selectedIcon: Icons.description_rounded,
                    label: context.tr('nav.applications'),
                    onTap: onSelected,
                  ),
                  const Expanded(child: SizedBox()),
                  _NavItem(
                    index: 3,
                    selectedIndex: selectedIndex,
                    icon: Icons.bolt_outlined,
                    selectedIcon: Icons.bolt_rounded,
                    label: context.tr('nav.activity'),
                    onTap: onSelected,
                  ),
                  _NavItem(
                    index: 4,
                    selectedIndex: selectedIndex,
                    icon: Icons.person_outline_rounded,
                    selectedIcon: Icons.person_rounded,
                    label: context.tr('nav.profile'),
                    onTap: onSelected,
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              child: GestureDetector(
                onTap: () => onSelected(2),
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 360),
                      curve: Curves.easeOutBack,
                      width: selectedIndex == 2 ? 62 : 56,
                      height: selectedIndex == 2 ? 62 : 56,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [colors.primary, const Color(0xFF087B3C)],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.surfaceContainer,
                          width: 5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colors.primary.withValues(alpha: .42),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/brand_icon.png',
                        color: Colors.white,
                        colorBlendMode: BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.tr('nav.home'),
                      style: TextStyle(
                        color: selectedIndex == 2
                            ? colors.primary
                            : colors.onSurfaceVariant,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final int selectedIndex;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.index,
    required this.selectedIndex,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = index == selectedIndex;
    final colors = Theme.of(context).colorScheme;
    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                width: selected ? 38 : 32,
                height: 30,
                decoration: BoxDecoration(
                  color: selected
                      ? colors.primary.withValues(alpha: .13)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  selected ? selectedIcon : icon,
                  size: selected ? 21 : 20,
                  color: selected ? colors.primary : colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.fade,
                style: TextStyle(
                  color: selected ? colors.primary : colors.onSurfaceVariant,
                  fontSize: 9,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedBrandHeader extends StatelessWidget {
  const _AnimatedBrandHeader();

  @override
  Widget build(BuildContext context) => SafeArea(
    bottom: false,
    child: TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutBack,
      builder: (context, value, child) => Opacity(
        opacity: value.clamp(0, 1),
        child: Transform.translate(
          offset: Offset(0, (1 - value) * -16),
          child: Transform.scale(scale: .92 + (.08 * value), child: child),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(18, 7, 18, 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.surfaceContainer,
              Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: .28),
            ],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: .13),
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: .09),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary,
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const AnimatedAppLogo(width: 132, height: 36),
            const SizedBox(width: 12),
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
