import 'package:flutter/material.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/utils/constants.dart';

class HomeJoinBanner extends StatelessWidget {
  final VoidCallback onTap;

  const HomeJoinBanner({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [HomeColors.ink, Color(0xFF263754)],
      ),
      borderRadius: BorderRadius.circular(24),
    ),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final text = const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DefaultText(
              text: 'Ready for your next opportunity?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 5),
            DefaultText(
              text: 'Create your profile and start applying in minutes.',
              style: TextStyle(
                color: Color(0xFFBCC7D9),
                fontSize: 11.5,
                height: 1.4,
              ),
            ),
          ],
        );
        final button = SizedBox(
          width: constraints.maxWidth < 420 ? double.infinity : 130,
          child: DefaultButton(
            background: HomeColors.purple,
            text: 'Get started',
            fontSize: 13,
            borderRadius: 12,
            uppercase: false,
            onPress: onTap,
          ),
        );
        return constraints.maxWidth < 420
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [text, const SizedBox(height: 14), button],
              )
            : Row(
                children: [
                  Expanded(child: text),
                  const SizedBox(width: 16),
                  button,
                ],
              );
      },
    ),
  );
}
