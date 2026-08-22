import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

// تم إزالة السلاش من النهاية لمنع تكراره في الطلبات //
final ipAddress = "https://workey.onrender.com/api/v1";
final baseURL = ipAddress;
final ip = ipAddress;

final defaultColor = ('#18A949');

final Color primary = HexColor('#18A949');
final Color secondary = HexColor('#1B2831');
final Color background = HexColor('#F7F9F8');
final Color border = HexColor('#E1E6E3');

/// Shared Workey home palette. Keeping it here prevents section widgets from
/// inventing their own colors and makes future branding changes predictable.
abstract final class HomeColors {
  static const Color ink = Color(0xFF1B2831);
  static const Color muted = Color(0xFF63716A);
  static const Color canvas = Color(0xFFF7F9F8);
  static const Color surface = Color(0xFFFDFDFD);
  static const Color brand = Color(0xFF18A949);
  static const Color brandDark = Color(0xFF0B7B35);
  static const Color accent = Color(0xFF29B148);
  // Legacy semantic aliases retained so every existing screen picks up the
  // approved identity without retaining the old blue/purple palette.
  static const Color purple = Color(0xFF0FA348);
  static const Color softPurple = Color(0xFFE8F7ED);
  static const Color softBlue = Color(0xFFEAF6ED);
  static const Color divider = Color(0xFFE1E6E3);
  static const Color warning = Color(0xFFF59E36);
}

/// Theme-aware semantic colors for ordinary application surfaces.
///
/// Brand colors remain in [HomeColors], while text, borders and surfaces use
/// the active [ColorScheme] so light widgets never leak into dark mode.
extension WorkeyThemeColors on BuildContext {
  Color get appInk => Theme.of(this).colorScheme.onSurface;
  Color get appMuted => Theme.of(this).colorScheme.onSurfaceVariant;
  Color get appDivider => Theme.of(this).colorScheme.outlineVariant;
  Color get appCanvas => Theme.of(this).scaffoldBackgroundColor;
  Color get appSurface => Theme.of(this).colorScheme.surfaceContainer;
  Color get appSoftBrand =>
      Theme.of(this).colorScheme.primaryContainer.withValues(alpha: .62);
}

class FilterConstants {
  static const List<String> syrianGovernorates = [
    'Damascus',
    'Rif Dimashq',
    'Aleppo',
    'Hama',
    'Homs',
    'Latakia',
    'Tartus',
    'Idlib',
    'Al-Hasakah',
    'Deir ez-Zor',
    'Ar-Raqqah',
    'As-Suwayda',
    'Daraa',
    'Quneitra',
  ];

  static const List<String> jobFields = [
    'Software Engineering',
    'Marketing',
    'Sales',
    'Graphics Design',
    'Finance',
    'Human Resources',
    'Healthcare',
    'Education',
    'Customer Service',
  ];

  static const List<String> careerLevels = [
    'Entry Level',
    'Junior',
    'Mid Level',
    'Senior',
    'Expert',
    'Manager',
  ];

  static const List<String> workTypes = [
    'Full Time',
    'Part Time',
    'Freelance',
    'Remote',
    'Internship',
    'Contract',
  ];
}

class TargetConstants {
  static const List<String> governorates = [
    'Damascus',
    'Rif Dimashq',
    'Aleppo',
    'Hama',
    'Homs',
    'Latakia',
    'Tartus',
    'Idlib',
    'Al-Hasakah',
    'Deir ez-Zor',
    'Ar-Raqqah',
    'As-Suwayda',
    'Daraa',
    'Quneitra',
  ];

  static const List<String> jobFields = [
    'Software Engineering',
    'Marketing',
    'Sales',
    'Graphics Design',
    'Finance',
    'Human Resources',
    'Healthcare',
    'Education',
    'Customer Service',
  ];

  static const List<String> educationLevels = [
    'High School',
    'Diploma',
    'Bachelor Degree',
    'Master Degree',
    'PhD',
  ];

  static const List<String> careerLevels = [
    'Entry Level',
    'Junior',
    'Mid Level',
    'Senior',
    'Expert',
    'Manager',
  ];

  static const List<String> workTypes = [
    'Full Time',
    'Part Time',
    'Freelance',
    'Remote',
    'Internship',
  ];
}
