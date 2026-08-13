import 'package:flutter/material.dart';

import '../../utils/constants.dart';

class InterviewVisualTheme {
  final Color foreground;
  final Color background;
  final IconData icon;

  const InterviewVisualTheme(this.foreground, this.background, this.icon);

  static InterviewVisualTheme from(String status) => switch (status) {
    'confirmed' => const InterviewVisualTheme(
      Color(0xFF137A75),
      Color(0xFFE5F7F4),
      Icons.verified_rounded,
    ),
    'rescheduled' => const InterviewVisualTheme(
      Color(0xFFA66000),
      Color(0xFFFFF2DA),
      Icons.update_rounded,
    ),
    'completed' || 'evaluated' => const InterviewVisualTheme(
      Color(0xFF16785E),
      Color(0xFFE5F6F0),
      Icons.task_alt_rounded,
    ),
    'cancelled' || 'no_show' => const InterviewVisualTheme(
      Color(0xFFAA4545),
      Color(0xFFFFECEC),
      Icons.event_busy_rounded,
    ),
    _ => const InterviewVisualTheme(
      HomeColors.purple,
      HomeColors.softPurple,
      Icons.calendar_month_rounded,
    ),
  };
}
