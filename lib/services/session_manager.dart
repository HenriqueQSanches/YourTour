import '../models/user.dart';

class SessionManager {
  static User? _currentUser;

  static User? get currentUser => _currentUser;

  static void setCurrentUser(User user) {
    _currentUser = user;
  }

  static void clear() {
    _currentUser = null;
  }
}


