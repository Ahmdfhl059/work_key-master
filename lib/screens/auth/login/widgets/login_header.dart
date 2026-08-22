import 'package:flutter/material.dart';
import 'package:work_key/shared/components/animated_app_logo.dart';
import 'package:work_key/shared/components/components.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const AdaptiveAppLogo(width: 190, height: 54),
          const SizedBox(height: 25),
          const DefaultText(
            text: "Welcome Back!",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          DefaultText(
            text: "Login to discover your next opportunity",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
