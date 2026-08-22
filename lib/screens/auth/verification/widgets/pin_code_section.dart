import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class PinCodeSection extends StatelessWidget {
  final TextEditingController controller;
  const PinCodeSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return MaterialPinField(
      length: 6,
      pinController: PinInputController(textController: controller),
      keyboardType: TextInputType.number,
      theme: MaterialPinTheme(
        shape: MaterialPinShape.outlined,
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        cellSize: const Size(40, 50),
        fillColor: colors.surfaceContainer,
        followingFillColor: colors.surfaceContainer,
        focusedFillColor: colors.primaryContainer.withValues(alpha: .5),
        filledFillColor: colors.surfaceContainer,
        borderColor: colors.outlineVariant,
        focusedBorderColor: colors.primary,
        filledBorderColor: colors.primary,
        cursorColor: colors.primary,
        textStyle: TextStyle(
          color: colors.onSurface,
          fontWeight: FontWeight.w800,
        ),
        entryAnimation: MaterialPinAnimation.fade,
        animationDuration: const Duration(milliseconds: 300),
      ),
      onChanged: (value) {},
    );
  }
}
