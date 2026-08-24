part of '../layout.dart';

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
