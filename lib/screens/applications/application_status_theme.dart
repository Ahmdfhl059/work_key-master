import 'package:flutter/material.dart';
import 'package:work_key/utils/constants.dart';

class ApplicationStatusTheme {
  final Color foreground, background;
  const ApplicationStatusTheme(this.foreground, this.background);
  static ApplicationStatusTheme from(String status) {
    if (status == 'accepted' || status == 'test_completed') return const ApplicationStatusTheme(Color(0xFF16785E), Color(0xFFE5F6F0));
    if (status == 'rejected') return const ApplicationStatusTheme(Color(0xFFB44343), Color(0xFFFFECEC));
    if (status == 'withdrawn') return const ApplicationStatusTheme(HomeColors.muted, Color(0xFFF0F2F5));
    if (status.contains('interview') || status == 'shortlisted') return const ApplicationStatusTheme(HomeColors.purple, HomeColors.softPurple);
    if (status == 'test_pending' || status == 'need_more_information' || status == 'on_hold') return const ApplicationStatusTheme(Color(0xFFA95D00), Color(0xFFFFF2DA));
    return const ApplicationStatusTheme(HomeColors.brand, HomeColors.softBlue);
  }
}
