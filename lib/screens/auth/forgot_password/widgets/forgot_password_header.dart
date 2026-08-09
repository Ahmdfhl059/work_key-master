import 'package:flutter/material.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/utils/constants.dart';

class ForgotPasswordHeader extends StatelessWidget {
  const ForgotPasswordHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DefaultText(
          text: "Forgot Password?",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        DefaultText(
          text: "Enter your registered email address to receive a password reset code.",
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
