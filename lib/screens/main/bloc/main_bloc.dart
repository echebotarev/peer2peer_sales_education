/// Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.
import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter_voximplant/flutter_voximplant.dart';
import '../main.dart';
import 'package:peer2peer_sales_education/services/auth_service.dart';
import 'package:peer2peer_sales_education/services/call/call_event.dart';
import 'package:peer2peer_sales_education/services/call/call_service.dart';
// import 'package:peer2peer_sales_education/services/call/callkit_service.dart';
import 'package:peer2peer_sales_education/utils/permissions_helper.dart';
import 'package:peer2peer_sales_education/utils/log.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  final AuthService _authService = AuthService();
  final CallService _callService = CallService();
  // final CallKitService? _callKitService =
  //     Platform.isIOS ? CallKitService() : null;

  late StreamSubscription _callStateSubscription;

  MainBloc() : super(MainInitial(myDisplayName: AuthService().displayName)) {
    _authService.onDisconnected = onConnectionClosed;
    _callStateSubscription =
        _callService.subscribeToCallEvents().listen(onCallEvent);

    on<CheckPermissionsForCall>(_checkPermissionForCall);
  }

  @override
  Future<void> close() {
    _callStateSubscription.cancel();
    return super.close();
  }

  void onConnectionClosed() => add(ConnectionClosed());

  Future<void> _checkPermissionForCall(
      CheckPermissionsForCall event, Emitter<MainState> emit) async {
    var result = await checkPermissions()
        ? PermissionCheckSuccess(myDisplayName: _authService.displayName)
        : PermissionCheckFail(myDisplayName: _authService.displayName);

    log('CheckPermissionForCall $result');

    emit(result);
  }

  @override
  Stream<MainState> mapEventToState(MainEvent event) async* {
    // if (event is CheckPermissionsForCall) {
    //   yield await checkPermissions()
    //       ? PermissionCheckSuccess(myDisplayName: _authService.displayName)
    //       : PermissionCheckFail(myDisplayName: _authService.displayName);
    // }
    if (event is LogOut) {
      await _authService.logout();
      yield const LoggedOut(networkIssues: false);
    }
    if (event is ReceivedIncomingCall) {
      yield IncomingCall(
          caller: event.displayName, myDisplayName: _authService.displayName);
    }
    if (event is ConnectionClosed) {
      yield const LoggedOut(networkIssues: true);
    }
    if (event is Reconnect) {
      try {
        String displayName = await _authService.loginWithAccessToken();
        if (displayName == null) {
          return;
        }
        yield ReconnectSuccess(myDisplayName: displayName);
      } on VIException {
        _authService.onDisconnected = null;
        yield const ReconnectFailed();
      }
    }
  }

  Future<void> onCallEvent(CallEvent event) async {
    if (event is OnDisconnectedCallEvent) {
      // await _callKitService!
      //     .reportCallEnded(reason: FCXCallEndedReason.remoteEnded);
    } else if (event is OnIncomingCallEvent) {
      Platform.isIOS
          ? null
          : add(ReceivedIncomingCall(
              displayName: event.displayName ?? event.username));
    }
  }
}
