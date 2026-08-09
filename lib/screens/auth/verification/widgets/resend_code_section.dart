import 'package:flutter/material.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/utils/constants.dart';

class ResendCodeSection extends StatelessWidget {
  final VoidCallback onResend;
  const ResendCodeSection({super.key, required this.onResend});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DefaultText(
          text: "Didn't receive the code? ",
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        DefaultTextButton(
          onPressed: onResend,
          text: "Resend",
          textStyle: TextStyle(
            color: primary,
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
