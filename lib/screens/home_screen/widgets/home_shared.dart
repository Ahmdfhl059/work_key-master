import 'package:flutter/material.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/utils/constants.dart';

class HomeCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;

  const HomeCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.color = HomeColors.surface,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: HomeColors.divider),
          boxShadow: const [
            BoxShadow(color: Color(0x0A15213A), blurRadius: 20, offset: Offset(0, 8)),
          ],
        ),
        child: child,
      );
}

class HomeSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onViewAll;
  final String actionLabel;

  const HomeSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onViewAll,
    this.actionLabel = 'View more',
  });

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultText(
                  text: title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: HomeColors.ink, fontSize: 20, height: 1.2, fontWeight: FontWeight.w800),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  DefaultText(text: subtitle!, style: const TextStyle(color: HomeColors.muted, fontSize: 12.5, height: 1.35)),
                ],
              ],
            ),
          ),
          if (onViewAll != null)
            DefaultTextButton(
              text: actionLabel,
              onPressed: onViewAll,
              textStyle: const TextStyle(color: HomeColors.purple, fontSize: 12.5, fontWeight: FontWeight.w700),
            ),
        ],
      );
}

class HomeEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;

  const HomeEmptyState({super.key, required this.icon, required this.title, this.message});

  @override
  Widget build(BuildContext context) => HomeCard(
        child: Column(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: const BoxDecoration(color: HomeColors.softBlue, shape: BoxShape.circle),
              child: Icon(icon, color: HomeColors.brand, size: 27),
            ),
            const SizedBox(height: 12),
            DefaultText(text: title, style: const TextStyle(color: HomeColors.ink, fontSize: 14, fontWeight: FontWeight.w700)),
            if (message != null) ...[
              const SizedBox(height: 4),
              DefaultText(text: message!, style: const TextStyle(color: HomeColors.muted, fontSize: 12, height: 1.4)),
            ],
          ],
        ),
      );
}

class HomeNetworkAvatar extends StatelessWidget {
  final String? url;
  final double radius;
  final bool business;

  const HomeNetworkAvatar({super.key, this.url, required this.radius, this.business = false});

  @override
  Widget build(BuildContext context) => CircleAvatar(
        radius: radius,
        backgroundColor: HomeColors.softBlue,
        foregroundImage: url?.isNotEmpty == true ? NetworkImage(url!) : null,
        onForegroundImageError: url?.isNotEmpty == true ? (_, __) {} : null,
        child: Icon(business ? Icons.business_rounded : Icons.person_rounded, color: HomeColors.brand, size: radius),
      );
}

class HomeSearchBar extends StatelessWidget {
  final VoidCallback? onTap;
  const HomeSearchBar({super.key, this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(22),
    child: HomeCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, color: HomeColors.brand, size: 27),
              const SizedBox(width: 12),
              const Expanded(
                child: DefaultText(
                  text: 'Search for a job, company, or skill',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: HomeColors.muted, fontSize: 13.5),
                ),
              ),
              Container(width: 1, height: 24, color: HomeColors.divider),
              const SizedBox(width: 12),
              SizedBox(
                width: 38,
                height: 38,
                child: DefaultIconButton(
                  onPressed: onTap ?? () {},
                  size: 20,
                  color: HomeColors.ink,
                  icon: const Icon(Icons.tune_rounded),
                ),
              ),
            ],
          ),
        ),
      ),
  );
}

class HomeTag extends StatelessWidget {
  final String text;
  const HomeTag(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(color: const Color(0xFFF1F4F9), borderRadius: BorderRadius.circular(9)),
        child: DefaultText(
          text: text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: HomeColors.muted, fontSize: 10.5, fontWeight: FontWeight.w600),
        ),
      );
}
