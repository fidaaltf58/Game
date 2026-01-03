import 'dart:convert';
import '../models/user.dart';
import 'storage_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _storage = StorageService();
  final List<User> _users = [];
  User? _currentUser;

  User? get currentUser => _currentUser;

  Future<void> init() async {
    await _loadUsers();
    await _loadCurrentUser();
  }

  Future<void> _loadUsers() async {
    final usersJson = await _storage.getString('users');
    if (usersJson != null) {
      final List<dynamic> usersList = json.decode(usersJson);
      _users.clear();
      _users.addAll(usersList.map((u) => User.fromJson(u)).toList());
    }
  }

  Future<void> _saveUsers() async {
    final usersJson = json.encode(_users.map((u) => u.toJson()).toList());
    await _storage.saveString('users', usersJson);
  }

  Future<void> _loadCurrentUser() async {
    final username = await _storage.getString('current_user');
    if (username != null) {
      _currentUser = _users.firstWhere(
            (user) => user.username == username,
        orElse: () => _users.first,
      );
    }
  }

  Future<bool> register(String username, String password) async {
    if (_users.any((user) => user.username == username)) {
      return false;
    }
    _users.add(User(username: username, password: password));
    await _saveUsers();
    return true;
  }

  Future<bool> login(String username, String password) async {
    try {
      _currentUser = _users.firstWhere(
            (user) => user.username == username && user.password == password,
      );
      await _storage.saveString('current_user', username);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    await _storage.remove('current_user');
  }

  Future<void> updateScore(String gameType, int level, int score) async {
    if (_currentUser != null) {
      switch (gameType) {
        case 'recycle':
          if (level == 1) _currentUser!.recycleLevel1Score = score;
          if (level == 2) _currentUser!.recycleLevel2Score = score;
          if (level == 3) _currentUser!.recycleLevel3Score = score;
          break;
        case 'plant':
          if (level == 1) _currentUser!.plantLevel1Score = score;
          if (level == 2) _currentUser!.plantLevel2Score = score;
          if (level == 3) _currentUser!.plantLevel3Score = score;
          break;
        case 'clean':
          if (level == 1) _currentUser!.cleanLevel1Score = score;
          if (level == 2) _currentUser!.cleanLevel2Score = score;
          if (level == 3) _currentUser!.cleanLevel3Score = score;
          break;
      }
      await _saveUsers();
    }
  }

  int getTotalScore() {
    if (_currentUser == null) return 0;
    return _currentUser!.recycleLevel1Score +
        _currentUser!.recycleLevel2Score +
        _currentUser!.recycleLevel3Score +
        _currentUser!.plantLevel1Score +
        _currentUser!.plantLevel2Score +
        _currentUser!.plantLevel3Score +
        _currentUser!.cleanLevel1Score +
        _currentUser!.cleanLevel2Score +
        _currentUser!.cleanLevel3Score;
  }
}