import 'package:flutter/material.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/utils/constants.dart';
import 'package:work_key/shared/components/company_logo.dart';

import '../../../localization/app_localizations.dart';

class HomeCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;

  const HomeCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final branded = color == null;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? .24 : .075),
            blurRadius: 22,
            offset: const Offset(0, 10),
            spreadRadius: -8,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            gradient: branded
                ? LinearGradient(
                    begin: AlignmentDirectional.topStart,
                    end: AlignmentDirectional.bottomEnd,
                    colors: [
                      colors.surfaceContainer,
                      colors.secondaryContainer.withValues(
                        alpha: dark ? .17 : .24,
                      ),
                      colors.tertiaryContainer.withValues(
                        alpha: dark ? .12 : .18,
                      ),
                    ],
                    stops: const [0, .72, 1],
                  )
                : null,
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: dark ? .72 : .9),
            ),
            borderRadius: BorderRadius.circular(26),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _CardPatternPainter(
                      lineColor: colors.secondary.withValues(
                        alpha: dark ? .14 : .09,
                      ),
                      dotColor: colors.tertiary.withValues(
                        alpha: dark ? .34 : .26,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(padding: padding, child: child),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardPatternPainter extends CustomPainter {
  final Color lineColor;
  final Color dotColor;

  const _CardPatternPainter({required this.lineColor, required this.dotColor});

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = lineColor
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    final startX = size.width * .72;
    for (var i = 0; i < 3; i++) {
      final offset = i * 12.0;
      canvas.drawLine(
        Offset(startX + offset, 0),
        Offset(size.width, size.height * .34 + offset),
        line,
      );
    }
    final dot = Paint()..color = dotColor;
    canvas.drawCircle(Offset(size.width - 24, size.height - 20), 3.2, dot);
    canvas.drawCircle(Offset(size.width - 39, size.height - 20), 1.8, dot);
  }

  @override
  bool shouldRepaint(covariant _CardPatternPainter oldDelegate) =>
      oldDelegate.lineColor != lineColor || oldDelegate.dotColor != dotColor;
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
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 20,
                height: 1.2,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              DefaultText(
                text: subtitle!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12.5,
                  height: 1.35,
                ),
              ),
            ],
          ],
        ),
      ),
      if (onViewAll != null)
        DefaultTextButton(
          text: actionLabel,
          onPressed: onViewAll,
          textStyle: const TextStyle(
            color: HomeColors.purple,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
    ],
  );
}

class HomeEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;

  const HomeEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
  });

  @override
  Widget build(BuildContext context) => HomeCard(
    child: Column(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: context.appSoftBrand,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: HomeColors.brand, size: 27),
        ),
        const SizedBox(height: 12),
        DefaultText(
          text: title,
          style: TextStyle(
            color: context.appInk,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 4),
          DefaultText(
            text: message!,
            style: TextStyle(
              color: context.appMuted,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ],
    ),
  );
}

class HomeNetworkAvatar extends StatelessWidget {
  final String? url;
  final double radius;
  final bool business;

  const HomeNetworkAvatar({
    super.key,
    this.url,
    required this.radius,
    this.business = false,
  });

  @override
  Widget build(BuildContext context) => business
      ? CompanyLogo(url: url, size: radius * 2)
      : CircleAvatar(
          radius: radius,
          backgroundColor: context.appSoftBrand,
          foregroundImage: url?.isNotEmpty == true ? NetworkImage(url!) : null,
          onForegroundImageError: url?.isNotEmpty == true ? (_, __) {} : null,
          child: Icon(
            Icons.person_rounded,
            color: HomeColors.brand,
            size: radius,
          ),
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
            Expanded(
              child: DefaultText(
                text: context.tr('home.search_hint'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: context.appMuted, fontSize: 13.5),
              ),
            ),
            Container(width: 1, height: 24, color: context.appDivider),
            const SizedBox(width: 12),
            SizedBox(
              width: 38,
              height: 38,
              child: DefaultIconButton(
                onPressed: onTap ?? () {},
                size: 20,
                color: context.appInk,
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
    decoration: BoxDecoration(
      color: Theme.of(
        context,
      ).colorScheme.primaryContainer.withValues(alpha: .34),
      borderRadius: BorderRadius.circular(11),
      border: Border.all(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: .10),
      ),
    ),
    child: DefaultText(
      text: text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontSize: 10.5,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
