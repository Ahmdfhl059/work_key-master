import 'package:flutter/material.dart';
import 'package:work_key/shared/components/components.dart';

class NewPasswordSection extends StatelessWidget {
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  const NewPasswordSection({
    super.key,
    required this.passwordController,
    required this.confirmPasswordController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          controller: passwordController,
          label: "New Password",
          hint: "••••••••",
          icon: Icons.lock_reset_rounded,
          isPassword: true,
        ),
        CustomTextField(
          controller: confirmPasswordController,
          label: "Confirm New Password",
          hint: "••••••••",
          icon: Icons.lock_reset_rounded,
          isPassword: true,
        ),
      ],
    );
  }
}
