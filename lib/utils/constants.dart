import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

// تم إزالة السلاش من النهاية لمنع تكراره في الطلبات //
final ipAddress = "https://workey.onrender.com/api/v1";
final baseURL = ipAddress; 
final ip = ipAddress;

final defaultColor = ('#2BB7C3');

final Color primary = HexColor('#FF1B4FBF');
final Color secondary = HexColor('#2A2A2A');
final Color background = HexColor('0xFFF8F9FD');
final Color border = HexColor('#585858');

/// Shared Workey home palette. Keeping it here prevents section widgets from
/// inventing their own colors and makes future branding changes predictable.
abstract final class HomeColors {
  static const Color ink = Color(0xFF15213A);
  static const Color muted = Color(0xFF66738A);
  static const Color canvas = Color(0xFFF4F7FC);
  static const Color surface = Colors.white;
  static const Color brand = Color(0xFF2457C5);
  static const Color brandDark = Color(0xFF163A8A);
  static const Color accent = Color(0xFF16A58F);
  static const Color purple = Color(0xFF6554D9);
  static const Color softPurple = Color(0xFFF0EEFF);
  static const Color softBlue = Color(0xFFEAF1FF);
  static const Color divider = Color(0xFFE5EAF2);
  static const Color warning = Color(0xFFF59E36);
}


class FilterConstants {
  static const List<String> syrianGovernorates = [
    'Damascus', 'Rif Dimashq', 'Aleppo', 'Hama', 'Homs',
    'Latakia', 'Tartus', 'Idlib', 'Al-Hasakah',
    'Deir ez-Zor', 'Ar-Raqqah', 'As-Suwayda', 'Daraa', 'Quneitra'
  ];

  static const List<String> jobFields = [
    'Software Engineering', 'Marketing', 'Sales', 'Graphics Design',
    'Finance', 'Human Resources', 'Healthcare', 'Education', 'Customer Service'
  ];

  static const List<String> careerLevels = [
    'Entry Level', 'Junior', 'Mid Level', 'Senior', 'Expert', 'Manager'
  ];

  static const List<String> workTypes = [
    'Full Time', 'Part Time', 'Freelance', 'Remote', 'Internship', 'Contract'
  ];
}


class TargetConstants {
  static const List<String> governorates = [
    'Damascus', 'Rif Dimashq', 'Aleppo', 'Hama', 'Homs', 'Latakia', 'Tartus', 'Idlib', 'Al-Hasakah', 'Deir ez-Zor', 'Ar-Raqqah', 'As-Suwayda', 'Daraa', 'Quneitra'
  ];

  static const List<String> jobFields = [
    'Software Engineering', 'Marketing', 'Sales', 'Graphics Design', 'Finance', 'Human Resources', 'Healthcare', 'Education', 'Customer Service'
  ];

  static const List<String> educationLevels = [
    'High School', 'Diploma', 'Bachelor Degree', 'Master Degree', 'PhD'
  ];

  static const List<String> careerLevels = [
    'Entry Level', 'Junior', 'Mid Level', 'Senior', 'Expert', 'Manager'
  ];

  static const List<String> workTypes = [
    'Full Time', 'Part Time', 'Freelance', 'Remote', 'Internship'
  ];
}
