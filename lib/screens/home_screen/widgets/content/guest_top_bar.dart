import 'package:flutter/material.dart';
import 'package:work_key/screens/auth/login/login_screen.dart';
import 'package:work_key/screens/auth/register/register_screen.dart';
import 'package:work_key/shared/components/animated_app_logo.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/utils/constants.dart';

class GuestTopBar extends StatelessWidget {
  const GuestTopBar({super.key});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < 390;
      return Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: AdaptiveAppLogo(width: compact ? 112 : 142, height: 48),
            ),
          ),
          DefaultTextButton(
            text: 'Sign in',
            onPressed: () => navigateTo(context, const LoginScreen()),
            textStyle: TextStyle(
              color: context.appInk,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: compact ? 112 : 132,
            child: DefaultButton(
              background: HomeColors.brand,
              text: compact ? 'Register' : 'Create account',
              fontSize: 12,
              height: 44,
              borderRadius: 13,
              uppercase: false,
              onPress: () => navigateTo(context, const RegisterScreen()),
            ),
          ),
        ],
      );
    },
  );
}
