/// Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_voximplant/flutter_voximplant.dart';
import 'package:peer2peer_sales_education/screens/active_call/active_call.dart';
import 'package:peer2peer_sales_education/screens/call_failed/call_failed.dart';
import 'package:peer2peer_sales_education/screens/incoming_call/incoming_call.dart';
import 'package:peer2peer_sales_education/screens/login/login.dart';
import 'package:peer2peer_sales_education/screens/main/main.dart';
import 'package:peer2peer_sales_education/services/auth_service.dart';
import 'package:peer2peer_sales_education/services/call/call_service.dart';
import 'package:peer2peer_sales_education/services/call/callkit_service.dart';
// import 'package:peer2peer_sales_education/services/push/push_service_android.dart';
// import 'package:peer2peer_sales_education/services/push/push_service_ios.dart';
import 'package:peer2peer_sales_education/theme/voximplant_theme.dart';
import 'package:peer2peer_sales_education/utils/log.dart';
import 'package:peer2peer_sales_education/utils/navigation_helper.dart';
import 'package:peer2peer_sales_education/utils/notification_helper.dart';

class SimpleBlocDelegate extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    log(event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    log(transition);
  }

  @override
  void onError(BlocBase cubit, Object error, StackTrace stackTrace) {
    super.onError(cubit, error, stackTrace);
    log(error);
  }
}

VIClientConfig get defaultConfig => VIClientConfig();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = SimpleBlocDelegate();

  AuthService();
  CallService();
  if (Platform.isIOS) {
    // PushServiceIOS();
    CallKitService();
  } else if (Platform.isAndroid) {
    // PushServiceAndroid();
    NotificationHelper();
  }

  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: VoximplantColors.primary,
        primaryColorDark: VoximplantColors.primaryDark,
      ),
      navigatorKey: NavigationHelper.navigatorKey,
      initialRoute: AppRoutes.login,
      onGenerateRoute: (routeSettings) {
        if (routeSettings.name == AppRoutes.login) {
          return PageRouteBuilder(
            pageBuilder: (_, a1, a2) => BlocProvider<LoginBloc>(
              create: (context) => LoginBloc(),
              child: const LoginPage(),
            ),
          );
        } else if (routeSettings.name == AppRoutes.main) {
          return PageRouteBuilder(
            pageBuilder: (_, a1, a2) => BlocProvider<MainBloc>(
              create: (context) => MainBloc(),
              child: const MainPage(),
            ),
          );
        } else if (routeSettings.name == AppRoutes.activeCall) {
          ActiveCallPageArguments arguments =
              routeSettings.arguments as ActiveCallPageArguments;
          return PageRouteBuilder(
            pageBuilder: (_, a1, a2) => BlocProvider<ActiveCallBloc>(
              create: (context) =>
                  ActiveCallBloc(arguments.isIncoming, arguments.endpoint),
              child: const ActiveCallPage(),
            ),
          );
        } else if (routeSettings.name == AppRoutes.incomingCall) {
          return PageRouteBuilder(
            pageBuilder: (context, a1, a2) => BlocProvider<IncomingCallBloc>(
              create: (context) => IncomingCallBloc(),
              child: IncomingCallPage(
                arguments: routeSettings.arguments as IncomingCallPageArguments,
              ),
            ),
          );
        } else if (routeSettings.name == AppRoutes.callFailed) {
          return MaterialPageRoute(
            builder: (context) => CallFailedPage(
              routeSettings.arguments as CallFailedPageArguments,
            ),
          );
        }
        return null;
      },
    );
  }
}
