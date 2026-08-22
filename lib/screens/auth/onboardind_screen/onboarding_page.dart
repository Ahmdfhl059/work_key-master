import 'package:flutter/material.dart';

//import '../../../../core/constants/app_colors.dart';

class OnboardingPage extends StatelessWidget {
  final String image;
  final String title;
  final String description;

  const OnboardingPage({
    super.key,
    required this.image,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        children: [
          const SizedBox(height: 30),

          Image.asset(image, height: 300),

          const SizedBox(height: 30),

          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
            ),
          ),

          const SizedBox(height: 15),

          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
