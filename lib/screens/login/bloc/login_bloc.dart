/// Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.
import 'dart:io';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:flutter_voximplant/flutter_voximplant.dart';
import 'package:peer2peer_sales_education/screens/login/login.dart';
import 'package:peer2peer_sales_education/services/auth_service.dart';
import 'package:peer2peer_sales_education/utils/notification_helper.dart';
import 'package:peer2peer_sales_education/utils/log.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthService _authService = AuthService();

  LoginBloc() : super(LoginInitial()) {
    on<LoadLastUser>(_loadLastUser);
    on<LoginWithPassword>(_loginWithPassword);
  }

  Future<void> _loadLastUser(
      LoadLastUser event, Emitter<LoginState> emit) async {
    if (Platform.isAndroid &&
        await NotificationHelper().didNotificationLaunchApp()) {
      // print('Launched from notification, skipping autologin');
      // emit('');
    } else {
      final lastUser = await _authService.getUsername();
      emit(LoginLastUserLoaded(lastUser: lastUser ?? ''));

      bool canUseAccessToken = await _authService.canUseAccessToken();
      if (canUseAccessToken) {
        emit(LoginInProgress());
        try {
          await _authService.loginWithAccessToken();
          emit(LoginSuccess());
        } on VIException catch (e) {
          emit(LoginFailure(errorCode: e.code, errorDescription: e.message));
        }
      }
    }
  }

  Future<void> _loginWithPassword(
      LoginWithPassword event, Emitter<LoginState> emit) async {
    emit(LoginInProgress());

    String username = '${event.username}.voximplant.com';
    String pwd = event.password;

    try {
      await _authService.loginWithPassword(username, pwd);
      emit(LoginSuccess());
    } on VIException catch (e) {
      emit(LoginFailure(errorCode: e.code, errorDescription: e.message));
    }
  }

  // @override
  // Stream<LoginState> mapEventToState(LoginEvent event) async* {
  //   if (event is LoadLastUser) {
  //     if (Platform.isAndroid &&
  //         await NotificationHelper().didNotificationLaunchApp()) {
  //       print('Launched from notification, skipping autologin');
  //       return;
  //     }
  //     String? lastUser = await _authService.getUsername();
  //     yield LoginLastUserLoaded(lastUser: lastUser ?? '');
  //     bool canUseAccessToken = await _authService.canUseAccessToken();
  //     if (canUseAccessToken) {
  //       yield LoginInProgress();
  //       try {
  //         await _authService.loginWithAccessToken();
  //         yield LoginSuccess();
  //       } on VIException catch (e) {
  //         yield LoginFailure(errorCode: e.code, errorDescription: e.message);
  //       }
  //     }
  //   }
  //   if (event is LoginWithPassword) {
  // yield LoginInProgress();
  // try {
  //   await _authService.loginWithPassword(
  //       '${event.username}.voximplant.com', event.password);
  //   yield LoginSuccess();
  // } on VIException catch (e) {
  //   yield LoginFailure(errorCode: e.code, errorDescription: e.message);
  // }
  //   }
  // }
}
