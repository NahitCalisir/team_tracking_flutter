import 'package:team_tracking/data/entity/users.dart';

class UsersManager {
  static final UsersManager _instance = UsersManager._internal();

  factory UsersManager() {
    return _instance;
  }

  UsersManager._internal();

  Users? _currentUser;

  Users? get currentUser => _currentUser;

  Future<void> setUser(Users user) async {
    _currentUser = user;
    // Kullanıcı bilgileri güncellendiğinde bu metodu çağırabilirsiniz.
  }
}
