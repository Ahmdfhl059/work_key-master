import 'package:flutter/material.dart';

class ApplicationStatusTheme {
  final Color foreground, background;
  const ApplicationStatusTheme(this.foreground, this.background);
  static ApplicationStatusTheme from(
    String status, {
    ColorScheme? colorScheme,
  }) {
    final colors =
        colorScheme ??
        ColorScheme.fromSeed(
          seedColor: const Color(0xFF18A949),
          brightness: Brightness.light,
        );
    if (status == 'accepted' || status == 'test_completed')
      return ApplicationStatusTheme(colors.primary, colors.primaryContainer);
    if (status == 'rejected')
      return ApplicationStatusTheme(colors.error, colors.errorContainer);
    if (status == 'withdrawn')
      return ApplicationStatusTheme(
        colors.onSurfaceVariant,
        colors.surfaceContainerHighest,
      );
    if (status.contains('interview') || status == 'shortlisted')
      return ApplicationStatusTheme(
        colors.secondary,
        colors.secondaryContainer,
      );
    if (status == 'test_pending' ||
        status == 'need_more_information' ||
        status == 'on_hold')
      return ApplicationStatusTheme(colors.tertiary, colors.tertiaryContainer);
    return ApplicationStatusTheme(colors.primary, colors.primaryContainer);
  }
}
