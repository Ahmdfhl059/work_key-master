import 'package:flutter/material.dart';
import 'package:work_key/shared/components/components.dart';

import '../auth_navigation.dart';

class GuestAccessButton extends StatelessWidget {
  const GuestAccessButton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () => AuthNavigation.continueAsGuest(context),
        icon: const Icon(Icons.explore_outlined, size: 20),
        label: DefaultText(
          text: 'Continue as guest',
          style: TextStyle(
            color: colors.primary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primary,
          side: BorderSide(color: colors.primary, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}
