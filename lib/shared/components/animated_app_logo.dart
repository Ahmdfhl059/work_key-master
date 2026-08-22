import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../images/image.dart';

/// The original horizontal brand asset with a theme-aware wordmark.
///
/// The green mark is always taken directly from [AppImages.logo]. In dark
/// mode only the dark WORKEY wordmark area is overlaid with a light tint, so
/// the logo keeps its exact proportions and has no background rectangle.
class AdaptiveAppLogo extends StatelessWidget {
  final double width;
  final double height;
  final bool? lightWordmark;

  const AdaptiveAppLogo({
    super.key,
    this.width = 150,
    this.height = 48,
    this.lightWordmark,
  });

  @override
  Widget build(BuildContext context) {
    final useLightWordmark =
        lightWordmark ?? Theme.of(context).brightness == Brightness.dark;
    Widget image({Color? color}) => Image.asset(
      AppImages.logo,
      width: width,
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      color: color,
      colorBlendMode: color == null ? null : BlendMode.srcIn,
      gaplessPlayback: true,
    );

    if (!useLightWordmark) return image();
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          image(),
          ClipRect(
            clipper: const _WordmarkClipper(),
            child: image(color: const Color(0xFFF3F7F5)),
          ),
        ],
      ),
    );
  }
}

class _WordmarkClipper extends CustomClipper<Rect> {
  const _WordmarkClipper();

  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(size.width * .36, 0, size.width, size.height);

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => false;
}

class AnimatedAppLogo extends StatefulWidget {
  final double width;
  final double height;
  final bool compact;

  const AnimatedAppLogo({
    super.key,
    this.width = 150,
    this.height = 48,
    this.compact = false,
  });

  @override
  State<AnimatedAppLogo> createState() => _AnimatedAppLogoState();
}

class _AnimatedAppLogoState extends State<AnimatedAppLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final logo = AdaptiveAppLogo(width: widget.width, height: widget.height);
    if (reduceMotion) return logo;

    return AnimatedScale(
      scale: widget.compact ? .88 : 1,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      child: AnimatedBuilder(
        animation: _controller,
        child: logo,
        builder: (context, child) {
          final wave = math.sin(_controller.value * math.pi * 2);
          return Transform.translate(
            offset: Offset(0, wave * 1.5),
            child: Transform.scale(scale: 1 + wave * .012, child: child),
          );
        },
      ),
    );
  }
}
