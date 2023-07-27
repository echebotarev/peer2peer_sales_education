/// Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:peer2peer_sales_education/services/auth_service.dart';
import 'package:peer2peer_sales_education/utils/log.dart';
import 'package:peer2peer_sales_education/utils/notification_helper.dart';

class PushServiceAndroid {
  final FirebaseMessaging _firebaseMessaging;

  factory PushServiceAndroid() => _cache ?? PushServiceAndroid._();
  static late PushServiceAndroid _cache;
  PushServiceAndroid._() : _firebaseMessaging = FirebaseMessaging() {
    _configure();
    _cache = this;
  }

  Future<void> _configure() async {
    _log('configure');
    _firebaseMessaging.configure(onBackgroundMessage: backgroundMessageHandler);
    _firebaseMessaging.onTokenRefresh.listen(_onToken);
    String token = await _firebaseMessaging.getToken();
    _onToken(token);
    return Future.value();
  }

  static Future<void> backgroundMessageHandler(
    Map<String, dynamic> message,
  ) async {
    _log('onBackgroundMessage: $message');
    if (!message.containsKey('data')) {
      return Future.value();
    }

    final Map<String, dynamic> data =
        Map<String, dynamic>.from(message['data']);

    if (!data.containsKey('voximplant')) {
      return Future.value();
    }

    await AuthService().pushNotificationReceived(data);

    Map<String, dynamic> callDetails = jsonDecode(data['voximplant']);
    final String displayName = callDetails['display_name'];

    NotificationHelper().displayNotification(
      title: 'Incoming call',
      description: "from $displayName",
      payload: displayName,
    );

    return;
  }

  Future<void> _onToken(String token) async {
    _log("onToken: $token");
    AuthService().voipToken = token;
  }

  static void _log<T>(T message) {
    log('PushServiceAndroid: ${message.toString()}');
  }
}
