import 'dart:convert';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // Simple in-memory storage that persists during app lifecycle
  final Map<String, String> _storage = {};

  Future<void> saveString(String key, String value) async {
    _storage[key] = value;
  }

  Future<String?> getString(String key) async {
    return _storage[key];
  }

  Future<void> saveBool(String key, bool value) async {
    _storage[key] = value.toString();
  }

  Future<bool?> getBool(String key) async {
    final value = _storage[key];
    if (value == null) return null;
    return value == 'true';
  }

  Future<void> saveInt(String key, int value) async {
    _storage[key] = value.toString();
  }

  Future<int?> getInt(String key) async {
    final value = _storage[key];
    if (value == null) return null;
    return int.tryParse(value);
  }

  Future<void> remove(String key) async {
    _storage.remove(key);
  }

  Future<void> clear() async {
    _storage.clear();
  }
}