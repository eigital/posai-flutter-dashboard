import 'package:flutter/foundation.dart';

/// Notifies [go_router] to re-run redirects after login/logout.
class AuthRefreshNotifier extends ChangeNotifier {
  void notifyAuthChanged() => notifyListeners();
}
