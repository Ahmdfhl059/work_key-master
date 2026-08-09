import 'package:flutter/material.dart';

import '../../utils/constants.dart';

enum AppTheme {
  blueLight("Blue Light"),
  blueDark("Blue Dark");

  final String name;

  const AppTheme(this.name);
}

final appThemeData = {
  AppTheme.blueLight: ThemeData(
    iconTheme: IconThemeData(color: secondary),
    primaryColor: Colors.white,
    shadowColor: Colors.black87,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    cardColor: primary,
    bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.white),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(backgroundColor: Colors.white),
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        color: Colors.black,
        fontSize: 35,
        fontWeight: FontWeight.bold,
      ),
      labelMedium: TextStyle(color: secondary, fontSize: 14),
      labelSmall: TextStyle(
        color: Colors.black,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),

  AppTheme.blueDark: ThemeData(
    iconTheme: IconThemeData(color: Colors.white),
    brightness: Brightness.dark,
    primaryColor: Colors.grey.shade800,
    shadowColor: Colors.white70,
    scaffoldBackgroundColor: primary,
    cardColor: primary,
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: Colors.grey.shade800,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(backgroundColor: primary),
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        color: Colors.white,
        fontSize: 35,
        fontWeight: FontWeight.bold,
      ),

      labelMedium: TextStyle(color: Colors.white, fontSize: 14),
      labelSmall: TextStyle(
        color: Colors.black,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
};
