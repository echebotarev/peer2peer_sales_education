/// Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.
import 'package:flutter/material.dart';
import 'package:peer2peer_sales_education/screens/active_call/active_call.dart';
import 'package:peer2peer_sales_education/screens/call_failed/call_failed_page.dart';
import 'package:peer2peer_sales_education/screens/incoming_call/incoming_call.dart';
import 'package:peer2peer_sales_education/screens/login/login.dart';
import 'package:peer2peer_sales_education/screens/main/main_page.dart';

class NavigationHelper {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Future<void> pushToIncomingCall({
    required String caller,
  }) =>
      navigatorKey.currentState!.pushReplacementNamed(
        AppRoutes.incomingCall,
        arguments: IncomingCallPageArguments(endpoint: caller),
      );

  static Future<void> pushToActiveCall({
    required bool isIncoming,
    required String callTo,
  }) =>
      navigatorKey.currentState!.pushReplacementNamed(
        AppRoutes.activeCall,
        arguments: ActiveCallPageArguments(
          isIncoming: isIncoming,
          endpoint: callTo,
        ),
      );

  static Future<void> pop() => navigatorKey.currentState!.maybePop();
}

class AppRoutes {
  static const String login = LoginPage.routeName;
  static const String main = MainPage.routeName;
  static const String incomingCall = IncomingCallPage.routeName;
  static const String activeCall = ActiveCallPage.routeName;
  static const String callFailed = CallFailedPage.routeName;
}
