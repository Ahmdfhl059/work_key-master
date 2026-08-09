import 'package:flutter/material.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/utils/constants.dart';

class RegisterHeader extends StatelessWidget {
  const RegisterHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DefaultText(
          text: "Register",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: primary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
              height: 1.5,
            ),
            children: [
              TextSpan(
                text: "Create an ",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
              TextSpan(
                text: "account",
                style: TextStyle(color: primary, fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: " to access all the professional features of ",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
              const TextSpan(
                text: "WORKEY!",
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
