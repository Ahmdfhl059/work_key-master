import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../utils/dio_methods.dart';
import '../utils/shared preferences.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class PushNotificationService with WidgetsBindingObserver {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  static const _channel = AndroidNotificationChannel(
    'workey_notifications',
    'Work Key notifications',
    description: 'Job, application, test, and interview updates',
    importance: Importance.high,
  );

  final _localNotifications = FlutterLocalNotificationsPlugin();
  Timer? _retryTimer;
  bool _initialized = false;
  bool _syncing = false;
  int _retryAttempt = 0;
  String? _queuedToken;

  Future<void> initialize() async {
    // The supplied Firebase configuration is for Android only. Other targets
    // keep working until their platform-specific Firebase file is supplied.
    if (kIsWeb || !Platform.isAndroid) return;
    if (_initialized) return;
    await Firebase.initializeApp();
    _initialized = true;
    WidgetsBinding.instance.addObserver(this);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await FirebaseMessaging.instance.setAutoInitEnabled(true);

    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
    FirebaseMessaging.instance.onTokenRefresh.listen(
      (token) => unawaited(syncTokenWithBackend(token)),
    );
    // A slow/cold backend must never delay the first application frame.
    unawaited(syncTokenWithBackend());
  }

  Future<void> syncTokenWithBackend([String? refreshedToken]) async {
    if (kIsWeb || !Platform.isAndroid) return;
    final authToken = CacheHelper.getData(key: 'token')?.toString();
    if (authToken == null || authToken.isEmpty) return;

    if (_syncing) {
      _queuedToken = refreshedToken ?? _queuedToken;
      return;
    }
    _syncing = true;

    try {
      final fcmToken =
          refreshedToken ?? await FirebaseMessaging.instance.getToken();
      if (fcmToken == null || fcmToken.isEmpty) return;
      final response = await RemoteApi.post(
        '/device-tokens',
        body: {
          'token': fcmToken,
          'platform': 'android',
          'locale': CacheHelper.getData(key: 'LOCALE')?.toString() ?? 'en',
        },
      );
      final root = response.data is Map
          ? Map<String, dynamic>.from(response.data)
          : <String, dynamic>{};
      if (root['success'] == false) {
        throw StateError(
          root['message']?.toString() ?? 'Device token registration failed',
        );
      }
      final data = root['data'];
      if (data is Map && data['id'] != null) {
        await CacheHelper.saveData(
          key: 'device_token_id',
          value: int.tryParse('${data['id']}') ?? -1,
        );
      }
      await CacheHelper.saveData(key: 'fcm_token', value: fcmToken);
      _retryTimer?.cancel();
      _retryTimer = null;
      _retryAttempt = 0;
      debugPrint('FCM device token synchronized successfully.');
    } catch (error) {
      debugPrint('Could not sync FCM token: $error');
      _scheduleRetry();
    } finally {
      _syncing = false;
      final queuedToken = _queuedToken;
      _queuedToken = null;
      if (queuedToken != null) {
        unawaited(syncTokenWithBackend(queuedToken));
      }
    }
  }

  void _scheduleRetry() {
    if (_retryTimer?.isActive == true) return;
    const delays = [
      Duration(seconds: 8),
      Duration(seconds: 20),
      Duration(minutes: 1),
      Duration(minutes: 3),
      Duration(minutes: 10),
    ];
    final delay = delays[_retryAttempt.clamp(0, delays.length - 1)];
    if (_retryAttempt < delays.length - 1) _retryAttempt++;
    _retryTimer = Timer(delay, () {
      _retryTimer = null;
      unawaited(syncTokenWithBackend());
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(syncTokenWithBackend());
    }
  }

  Future<void> unregisterCurrentDevice() async {
    _retryTimer?.cancel();
    _retryTimer = null;
    _retryAttempt = 0;
    final id = CacheHelper.getData(key: 'device_token_id');
    if (id == null || int.tryParse('$id') == null) return;
    try {
      await RemoteApi.delete('/device-tokens/$id');
    } catch (_) {
      // Logout must still continue if the token was already disabled.
    } finally {
      await CacheHelper.removeData(key: 'device_token_id');
      await CacheHelper.removeData(key: 'fcm_token');
    }
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    final title = notification?.title ?? message.data['title']?.toString();
    final body = notification?.body ?? message.data['body']?.toString();
    if (title == null && body == null) return;

    await _localNotifications.show(
      id: message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'workey_notifications',
          'Work Key notifications',
          channelDescription: 'Job, application, test, and interview updates',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: message.data.toString(),
    );
  }
}
