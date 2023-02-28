import 'dart:convert';

import 'package:audio_background/dev_firebase_options.dart';
import 'package:audio_background/firebase/firebase_message_type.dart';
import 'package:audio_background/utils/type_ext.dart';
import 'package:collection/collection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:developer' as developer;

import 'firebase_message.dart';

@pragma("vm:entry-point")
Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await FirebaseSetup.initializeFirebase();

  developer.log("_firebaseMessagingBackgroundHandler: ${message.toString()}");
}

@pragma("vm:entry-point")
Future _onBackgroundNotificationResponse(NotificationResponse response) async {
  await FirebaseSetup.initializeFirebase();

  developer.log("_onBackgroundNotificationResponse: ${response.toString()}");
}

class FirebaseSetup {
  static Future<FirebaseApp> initializeFirebase() async {
    return await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  FlutterLocalNotificationsPlugin? _localPlugin;
  AndroidNotificationChannel? _androidChannel;

  final List<FirebaseMessage> _firebaseMessages = [];
  List<FirebaseMessage> get firebaseMessages => _firebaseMessages;
  FirebaseMessage? get firstFirebaseMessage => _firebaseMessages.firstOrNull;

  void clearFirebaseMessages() {
    _firebaseMessages.clear();
  }

  Future<String?> firebaseToken() async {
    try {
      final settings = await _requestPermission();

      if (settings?.authorizationStatus == AuthorizationStatus.authorized) {
        return await FirebaseMessaging.instance.getToken();
      }
      return null;
    } catch (error) {
      return null;
    }
  }

  Future<NotificationSettings?> _requestPermission() async {
    try {
      return await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        provisional: false,
        sound: true,
      );
    } catch (error) {
      return null;
    }
  }

  Future checkInitialMessage() async {
    try {
      final message = await FirebaseMessaging.instance.getInitialMessage();

      if (message != null) _onMessage(message);

      FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);
    } catch (error) {
      developer.log(error.toString());
    }
  }

  Future registerNotification() async {
    try {
      await FirebaseSetup.initializeFirebase();
      await _registerChannel();
      final settings = await _requestPermission();

      if (settings?.authorizationStatus == AuthorizationStatus.authorized) {
        FirebaseMessaging.onBackgroundMessage(
            _firebaseMessagingBackgroundHandler);
        FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);
        FirebaseMessaging.onMessage.listen(_onMessage);

        String? token = await firebaseToken();
        developer.log("FirebaseSetupToken $token");
      } else {}
    } catch (error) {
      developer.log(error.toString());
    }
  }

  Future _registerChannel() async {
    try {
      _localPlugin = FlutterLocalNotificationsPlugin();
      await _localPlugin?.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings("@mipmap/launcher_icon"),
          iOS: DarwinInitializationSettings(),
        ),
        onDidReceiveNotificationResponse: _onNotificationResponse,
      );
      final platform = _localPlugin?.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      const channel = AndroidNotificationChannel(
        "high_importance_channel",
        "High Importance Notification",
        importance: Importance.max,
      );
      _androidChannel = channel;
      await platform?.createNotificationChannel(channel);
    } catch (error) {
      developer.log(error.toString());
    }
  }

  void _onNotificationResponse(NotificationResponse response) {
    developer.log('_onNotificationResponse: ${response.toString()}');
  }

  void _onMessageOpenedApp(RemoteMessage message) {}

  void _onMessage(RemoteMessage message) {
    final notification = message.notification;

    if (notification == null) return;

    try {
      _firebaseMessages.add(
        FirebaseMessage(
          title: notification.title,
          body: notification.body,
          type: FirebaseMessageTypeExt.fromString(
            XCast<String>().cast(message.data['type']),
          ),
          data: message.data,
        ),
      );

      _localPlugin?.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel?.id ?? "custom_android_channel_id",
            _androidChannel?.name ?? "custom_android_channel_name",
            importance: _androidChannel?.importance ?? Importance.max,
            priority: Priority.max,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
      developer.log("NotificationData ${message.toMap()}");
    } catch (error) {
      developer.log("$error ${(error as Error).stackTrace}");
    }
  }
}
