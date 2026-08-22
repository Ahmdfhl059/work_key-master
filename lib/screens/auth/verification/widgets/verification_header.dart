import 'package:flutter/material.dart';
import 'package:work_key/shared/components/components.dart';

class VerificationHeader extends StatelessWidget {
  const VerificationHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DefaultText(
          text: "Verification",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        DefaultText(
          text:
              "We have sent a 6-digit verification code to your email address. Please enter it below to continue.",
          style: TextStyle(
            color: colors.onSurfaceVariant,
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
