import 'dart:async';

import 'package:flutter/material.dart';
import 'package:work_key/layout/layout.dart';
import 'package:work_key/localization/app_localizations.dart';
import 'package:work_key/shared/components/animated_app_logo.dart';
import 'package:work_key/utils/shared%20preferences.dart';

import '../home_screen/home_screen.dart';
import 'onboardind_screen/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _ambientController;
  late final Animation<double> _fade;
  late final Animation<double> _logoScale;
  late final Animation<Offset> _contentSlide;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1050),
    );
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat();
    _fade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0, .78, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: .82, end: 1).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutBack),
    );
    _contentSlide = Tween<Offset>(begin: const Offset(0, .25), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(.2, 1, curve: Curves.easeOutCubic),
          ),
        );
    _entranceController.forward();
    _navigationTimer = Timer(const Duration(milliseconds: 2600), _navigate);
  }

  void _navigate() {
    final onboarded = CacheHelper.getData(key: 'onBoarding') != null;
    final token = CacheHelper.getData(key: 'token')?.toString();
    final Widget next = !onboarded
        ? const OnboardingScreen()
        : token?.isNotEmpty == true
        ? const Layout()
        : const GuestHomePage();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 480),
        pageBuilder: (_, animation, __) => next,
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _entranceController.dispose();
    _ambientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: colors.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxHeight < 650;
          final logoWidth = (constraints.maxWidth * .67)
              .clamp(210.0, 300.0)
              .toDouble();
          return Stack(
            fit: StackFit.expand,
            children: [
              const _SplashBackground(),
              AnimatedBuilder(
                animation: _ambientController,
                builder: (context, child) => Transform.rotate(
                  angle: _ambientController.value * 6.283,
                  child: child,
                ),
                child: const Center(child: _OrbitDecoration()),
              ),
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: constraints.maxWidth < 360 ? 22 : 30,
                  ),
                  child: Column(
                    children: [
                      const Spacer(flex: 5),
                      FadeTransition(
                        opacity: _fade,
                        child: ScaleTransition(
                          scale: _logoScale,
                          child: Semantics(
                            label: context.tr('app.name'),
                            image: true,
                            child: AdaptiveAppLogo(
                              width: logoWidth,
                              height: logoWidth / 4.54,
                              lightWordmark: dark,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: compact ? 24 : 34),
                      FadeTransition(
                        opacity: _fade,
                        child: SlideTransition(
                          position: _contentSlide,
                          child: Column(
                            children: [
                              Text(
                                context.tr('Find work that fits you'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: colors.onSurface,
                                  fontSize: 22,
                                  height: 1.2,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -.3,
                                ),
                              ),
                              SizedBox(height: 9),
                              Text(
                                context.tr(
                                  'Smarter matches. Stronger careers.',
                                ),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: colors.onSurfaceVariant,
                                  fontSize: 13,
                                  height: 1.4,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(flex: 5),
                      FadeTransition(
                        opacity: _fade,
                        child: const _ProgressLine(),
                      ),
                      SizedBox(height: compact ? 23 : 36),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SplashBackground extends StatelessWidget {
  const _SplashBackground();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? const [Color(0xFF071116), Color(0xFF0B3320), Color(0xFF0A2418)]
              : [
                  colors.surface,
                  colors.primaryContainer,
                  colors.secondaryContainer,
                ],
          stops: const [0, .52, 1],
        ),
      ),
      child: const Stack(
        children: [
          Positioned(top: -140, right: -110, child: _SoftGlow(size: 330)),
          Positioned(bottom: -170, left: -115, child: _SoftGlow(size: 360)),
        ],
      ),
    );
  }
}

class _SoftGlow extends StatelessWidget {
  final double size;

  const _SoftGlow({required this.size});

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .045),
      border: Border.all(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .08),
      ),
    ),
  );
}

class _OrbitDecoration extends StatelessWidget {
  const _OrbitDecoration();

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 350,
    height: 350,
    child: Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: .10),
              ),
            ),
          ),
        ),
        Positioned(
          top: 27,
          right: 49,
          child: Container(
            width: 9,
            height: 9,
            decoration: const BoxDecoration(
              color: Color(0xFFB9AEFF),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Color(0x99B9AEFF), blurRadius: 12)],
            ),
          ),
        ),
      ],
    ),
  );
}

class _ProgressLine extends StatelessWidget {
  const _ProgressLine();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: 86,
          child: LinearProgressIndicator(
            minHeight: 3,
            color: Theme.of(context).colorScheme.primary,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: .16),
          ),
        ),
      ),
      const SizedBox(height: 11),
      Text(
        context.tr('WORK SMARTER'),
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 2.2,
        ),
      ),
    ],
  );
}
