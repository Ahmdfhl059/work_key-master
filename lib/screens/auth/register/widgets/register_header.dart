import 'package:flutter/material.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/localization/app_localizations.dart';

class RegisterHeader extends StatelessWidget {
  const RegisterHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DefaultText(
          text: context.tr('auth.register'),
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: colors.primary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 15,
              color: colors.onSurface,
              height: 1.5,
            ),
            children: [
              TextSpan(
                text: context.tr('auth.register_subtitle'),
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 16),
              ),
              TextSpan(
                text: ' Work Key',
                style: TextStyle(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
