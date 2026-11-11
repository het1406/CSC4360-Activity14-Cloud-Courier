import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart';
import '../models/courier_state.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Never log the payload/token or touch widgets from background execution.
  debugPrint('onBackgroundMessage: background processing only; no UI update.');
}

class FcmService extends ChangeNotifier {
  final state = CourierState();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  bool _disposed = false;
  bool _started = false;
  String permission = 'Checking';
  String tokenStatus = 'Not checked';
  String setupStatus = 'Initializing messaging';

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  void _receive(String handler, RemoteMessage message) {
    if (_disposed) return;
    state.receive(handler, message.messageId, message.data);
    _notify();
  }

  void _token(String? token) {
    if (_disposed) return;
    tokenStatus = token == null
        ? 'Unavailable'
        : 'Available (masked; ${token.length} characters)';
    _notify();
  }

  void _streamError(Object error) {
    if (_disposed) return;
    setupStatus = 'Messaging stream failed; check device connectivity.';
    _notify();
  }

  Future<void> initialize() async {
    if (_started || _disposed) return;
    _started = true;
    _subscriptions.add(
      FirebaseMessaging.onMessage.listen(
        (m) => _receive('onMessage', m),
        onError: _streamError,
      ),
    );
    _subscriptions.add(
      FirebaseMessaging.onMessageOpenedApp.listen(
        (m) => _receive('onMessageOpenedApp', m),
        onError: _streamError,
      ),
    );
    _subscriptions.add(
      _messaging.onTokenRefresh.listen(_token, onError: _streamError),
    );
    // Process the launch notification independently of permission/token retrieval.
    try {
      final initial = await _messaging.getInitialMessage();
      if (_disposed) return;
      if (initial != null) _receive('getInitialMessage', initial);
    } catch (_) {
      if (_disposed) return;
      setupStatus = 'Initial notification lookup failed.';
      _notify();
    }
    try {
      var settings = await _messaging.getNotificationSettings();
      if (_disposed) return;
      if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
        settings = await _messaging.requestPermission();
        if (_disposed) return;
      }
      permission = settings.authorizationStatus.name;
      _notify();
      _token(await _messaging.getToken());
      if (_disposed) return;
      setupStatus = 'Listeners ready';
    } catch (_) {
      if (_disposed) return;
      setupStatus =
          'Permission/token check failed. Check Firebase and Google Play services.';
    }
    _notify();
  }

  // Inspect the result privately in a debugger to obtain a Console test token.
  // Do not log, screenshot, or persist it.
  Future<String?> tokenForPrivateConsoleUse() => _messaging.getToken();

  @override
  void dispose() {
    _disposed = true;
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    _subscriptions.clear();
    super.dispose();
  }
}
