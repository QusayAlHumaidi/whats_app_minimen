import 'dart:html';

abstract class AppStorage {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class WebStorage implements AppStorage {
  @override
  Future<String?> read(String key) async {
    return window.localStorage[key];
  }

  @override
  Future<void> write(String key, String value) async {
    window.localStorage[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    window.localStorage.remove(key);
  }
}

AppStorage createStorage() => WebStorage();
