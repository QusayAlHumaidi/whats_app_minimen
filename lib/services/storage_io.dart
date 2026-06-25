import 'dart:io';

import 'package:path_provider/path_provider.dart';

abstract class AppStorage {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class FileStorage implements AppStorage {
  Future<File> _file(String key) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$key.json');
    if (!await file.exists()) {
      await file.create(recursive: true);
      await file.writeAsString('');
    }
    return file;
  }

  @override
  Future<String?> read(String key) async {
    final file = await _file(key);
    final contents = await file.readAsString();
    return contents.isEmpty ? null : contents;
  }

  @override
  Future<void> write(String key, String value) async {
    final file = await _file(key);
    await file.writeAsString(value);
  }

  @override
  Future<void> delete(String key) async {
    final file = await _file(key);
    if (await file.exists()) {
      await file.delete();
    }
  }
}

AppStorage createStorage() => FileStorage();
