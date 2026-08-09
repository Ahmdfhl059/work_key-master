import 'package:flutter/material.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/shared/images/image.dart';
import 'package:work_key/utils/constants.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          DefContainer(
            width: 80,
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: primary.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))
            ],
            child: Container(
              height: 80,
              padding: const EdgeInsets.all(12),
              child: Image.asset(AppImages.logo, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 25),
          const DefaultText(
            text: "Welcome Back!",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.5),
          ),
          const SizedBox(height: 8),
          DefaultText(
            text: "Login to discover your next opportunity",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
