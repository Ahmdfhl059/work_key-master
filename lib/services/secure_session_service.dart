import 'package:flutter/services.dart';

abstract final class SecureSessionService {
  static const _channel = MethodChannel('workkey/secure_session');

  static Future<void> setSecure(bool enabled) async {
    try {
      await _channel.invokeMethod<void>('setSecure', {'enabled': enabled});
    } on MissingPluginException {
      // Non-Android targets do not expose FLAG_SECURE.
    }
  }
}
