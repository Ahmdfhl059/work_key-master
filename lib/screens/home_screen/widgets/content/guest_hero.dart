import 'package:flutter/material.dart';
import 'package:work_key/data/models/home_response_model.dart';
import 'package:work_key/screens/auth/login/login_screen.dart';
import 'package:work_key/screens/auth/register/register_screen.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/utils/constants.dart';

class GuestHero extends StatelessWidget {
  final HomeHeroModel? hero;

  const GuestHero({super.key, this.hero});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final wide = constraints.maxWidth >= 720;
      final content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 15),
              SizedBox(width: 7),
              DefaultText(
                text: 'BUILD YOUR FUTURE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          DefaultText(
            text: hero?.title.isNotEmpty == true
                ? hero!.title
                : 'Your next opportunity starts here',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: wide ? 38 : 28,
              height: 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: DefaultText(
              text: hero?.description.isNotEmpty == true
                  ? hero!.description
                  : 'Discover opportunities that fit your skills, goals, and ambitions.',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: const Color(0xFFDCE7FF),
                fontSize: wide ? 16 : 14,
                height: 1.55,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              SizedBox(
                width: 150,
                child: DefaultButton(
                  background: Colors.white,
                  textColor: HomeColors.brand,
                  text: hero?.primaryAction?.label ?? 'Create account',
                  fontSize: 13,
                  height: 50,
                  borderRadius: 14,
                  uppercase: false,
                  onPress: () => navigateTo(context, const RegisterScreen()),
                ),
              ),
              SizedBox(
                width: 130,
                child: DefaultTextButton(
                  text: hero?.secondaryAction?.label ?? 'Sign in',
                  onPressed: () => navigateTo(context, const LoginScreen()),
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
      return Container(
        constraints: BoxConstraints(minHeight: wide ? 360 : 330),
        padding: EdgeInsets.all(wide ? 40 : 24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [HomeColors.brandDark, HomeColors.brand, HomeColors.purple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(wide ? 32 : 26),
          boxShadow: const [
            BoxShadow(
              color: Color(0x2918A949),
              blurRadius: 32,
              offset: Offset(0, 16),
            ),
          ],
        ),
        child: Stack(
          children: [
            const Positioned(right: -55, top: -80, child: _Orb(size: 230)),
            if (wide)
              Row(
                children: [
                  Expanded(flex: 3, child: content),
                  const Spacer(flex: 2),
                ],
              )
            else
              content,
          ],
        ),
      );
    },
  );
}

class _Orb extends StatelessWidget {
  final double size;

  const _Orb({required this.size});

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: const BoxDecoration(
      color: Color(0x13FFFFFF),
      shape: BoxShape.circle,
    ),
  );
}
