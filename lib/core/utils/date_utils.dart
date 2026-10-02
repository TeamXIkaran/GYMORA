import 'dart:async';

/// Singleton that broadcasts a session-expiry event when the backend returns
/// {"status": false, "message": "Unauthorized or token expired"}.
///
/// ApiHelper fires [notifyExpired] whenever it detects that payload.
/// The app root (MainApp) listens to [expiredStream] and redirects to login.
class SessionManager {
  SessionManager._();
  static final SessionManager instance = SessionManager._();

  final StreamController<String> _controller =
      StreamController<String>.broadcast();

  Stream<String> get expiredStream => _controller.stream;

  // Guard so multiple simultaneous 401s only fire one dialog.
  bool _handling = false;

  void notifyExpired([String message = 'Session expired. Please login again.']) {
    if (_handling) return;
    _handling = true;
    _controller.add(message);
    // Reset after a short delay so a fresh login can expire again later.
    Future.delayed(const Duration(seconds: 3), () => _handling = false);
  }

  void dispose() {
    _controller.close();
  }
}
