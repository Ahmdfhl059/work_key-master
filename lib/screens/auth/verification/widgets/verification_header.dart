import 'package:flutter/material.dart';
import 'package:work_key/shared/components/components.dart';

class VerificationHeader extends StatelessWidget {
  const VerificationHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DefaultText(
          text: "Verification",
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
        SizedBox(height: 12),
        DefaultText(
          text: "We have sent a 6-digit verification code to your email address. Please enter it below to continue.",
          style: TextStyle(color: Colors.grey, fontSize: 15, height: 1.5),
        ),
      ],
    );
  }
}
