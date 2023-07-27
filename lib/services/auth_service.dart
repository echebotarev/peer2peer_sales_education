/// Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.
import 'package:flutter_voximplant/flutter_voximplant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:peer2peer_sales_education/main.dart';
import 'package:peer2peer_sales_education/utils/log.dart';

typedef Disconnected = void Function();

class AuthService {
  VIClient _client;
  late String _displayName;

  String get displayName => _displayName;
  Disconnected? onDisconnected;

  late String _voipToken;
  set voipToken(token) {
    _log('Token $token');
    if (token == null || token == '') {
      _log('AuthService: token is cleared');
      _client.unregisterFromPushNotifications(_voipToken);
    }
    _voipToken = token;
  }

  late VIClientState clientState;

  factory AuthService() => _cache ?? AuthService._();
  static AuthService? _cache;
  AuthService._() : _client = Voximplant().getClient(defaultConfig) {
    _client.clientStateStream.listen((state) {
      clientState = state;
      _log('AuthService: client state is changed: $state');

      if (state == VIClientState.Disconnected) {
        onDisconnected!();
      }
    });
    _cache = this;
  }

  Future<String> loginWithPassword(String username, String password) async {
    _log('AuthService: loginWithPassword');
    VIClientState clientState = await _client.getClientState();
    if (clientState == VIClientState.LoggedIn) {
      return _displayName;
    }
    if (clientState == VIClientState.Disconnected) {
      await _client.connect();
    }
    VIAuthResult authResult = await _client.login(username, password);
    // await _client.registerForPushNotifications(_voipToken);
    await _saveAuthDetails(username, authResult.loginTokens);
    _displayName = authResult.displayName;
    return _displayName;
  }

  Future<String> loginWithAccessToken([String? username]) async {
    VIClientState clientState = await _client.getClientState();
    if (clientState == VIClientState.LoggedIn) {
      return _displayName;
    } else if (clientState == VIClientState.Connecting ||
        clientState == VIClientState.LoggingIn) {
      return '';
    } else if (clientState == VIClientState.Disconnected) {
      await _client.connect();
    }
    _log('AuthService: loginWithAccessToken');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    VILoginTokens loginTokens = _getAuthDetails(prefs);
    String? user = username ?? prefs.getString('username');

    VIAuthResult authResult =
        await _client.loginWithAccessToken(user ?? '', loginTokens.accessToken);
    await _client.registerForPushNotifications(_voipToken);
    await _saveAuthDetails(user ?? '', authResult.loginTokens);
    _displayName = authResult.displayName;
    return _displayName;
  }

  Future<void> logout() async {
    await _client.disconnect();
    VILoginTokens loginTokens = VILoginTokens(
        accessExpire: 0, accessToken: '', refreshExpire: 0, refreshToken: '');
    _saveAuthDetails(null, loginTokens);
  }

  Future<String?> getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('username')?.replaceAll('.voximplant.com', '');
  }

  Future<bool> canUseAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken') != null;
  }

  Future<void> _saveAuthDetails(
      String? username, VILoginTokens? loginTokens) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('username', username ?? '');
    prefs.setString('accessToken', loginTokens!.accessToken);
    prefs.setString('refreshToken', loginTokens.refreshToken);
    prefs.setInt('accessExpire', loginTokens.accessExpire);
    prefs.setInt('refreshExpire', loginTokens.refreshExpire);
  }

  VILoginTokens _getAuthDetails(SharedPreferences prefs) {
    VILoginTokens loginTokens = VILoginTokens(
        accessExpire: 0, accessToken: '', refreshExpire: 0, refreshToken: '');
    loginTokens.accessToken = prefs.getString('accessToken') ?? '';
    loginTokens.accessExpire = prefs.getInt('accessExpire') ?? 0;
    loginTokens.refreshExpire = prefs.getInt('refreshExpire') ?? 0;
    loginTokens.refreshToken = prefs.getString('refreshToken') ?? '';

    return loginTokens;
  }

  Future<void> pushNotificationReceived(Map<String, dynamic> payload) async {
    await _client.handlePushNotification(payload);
  }

  void _log<T>(T message) {
    log('AuthService($hashCode): ${message.toString()}');
  }
}
