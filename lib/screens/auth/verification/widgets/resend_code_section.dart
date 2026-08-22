import 'package:flutter/material.dart';
import 'package:work_key/shared/components/components.dart';

class ResendCodeSection extends StatelessWidget {
  final VoidCallback onResend;
  const ResendCodeSection({super.key, required this.onResend});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DefaultText(
          text: "Didn't receive the code? ",
          style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14),
        ),
        DefaultTextButton(
          onPressed: onResend,
          text: "Resend",
          textStyle: TextStyle(
            color: colors.primary,
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
