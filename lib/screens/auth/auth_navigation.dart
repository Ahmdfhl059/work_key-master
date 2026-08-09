import 'package:flutter/material.dart';
import 'package:work_key/screens/home_screen/home_screen.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/utils/shared%20preferences.dart';

abstract final class AuthNavigation {
  static Future<void> continueAsGuest(BuildContext context) async {
    await CacheHelper.removeData(key: 'token');
    if (context.mounted) navigateAndFinish(context, const GuestHomePage());
  }
}
