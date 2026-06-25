import 'dart:convert';

import '../models/app_message.dart';
import '../models/app_user.dart';
import 'storage.dart';

class LocalChatStore {
  static const _usersKey = 'mini_whatsapp_users';
  static const _messagesKey = 'mini_whatsapp_messages';

  List<AppUser>? _usersCache;
  List<AppMessage>? _messagesCache;

  Future<List<T>> _readList<T>({
    required String key,
    required T Function(Map<String, dynamic> json) parser,
  }) async {
    try {
      final contents = await storage.read(key);
      if (contents == null || contents.trim().isEmpty) {
        return [];
      }

      final decoded = jsonDecode(contents) as List<dynamic>;
      return decoded
          .map((item) => parser(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _writeList({
    required String key,
    required List<Map<String, dynamic>> data,
  }) async {
    await storage.write(key, jsonEncode(data));
  }

  Future<List<AppUser>> getUsers() async {
    if (_usersCache != null) {
      return List<AppUser>.from(_usersCache!);
    }

    final users = await _readList<AppUser>(
      key: _usersKey,
      parser: (json) => AppUser.fromJson(json),
    );
    _usersCache = List<AppUser>.from(users);
    return _usersCache!;
  }

  Future<void> saveUsers(List<AppUser> users) async {
    _usersCache = List<AppUser>.from(users);
    await _writeList(
      key: _usersKey,
      data: users.map((user) => user.toJson()).toList(),
    );
  }

  Future<AppUser?> login(String phone, String password) async {
    final users = await getUsers();
    for (final user in users) {
      if (user.phone == phone && user.password == password) {
        return user;
      }
    }
    return null;
  }

  Future<String?> register({
    required String name,
    required String phone,
    required String password,
  }) async {
    final users = await getUsers();
    final normalizedPhone = phone.trim();

    final exists = users.any((user) => user.phone == normalizedPhone);
    if (exists) {
      return 'رقم الهاتف مسجل مسبقاً';
    }

    users.add(
      AppUser(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name.trim(),
        phone: normalizedPhone,
        password: password,
      ),
    );
    await saveUsers(users);
    return null;
  }

  Future<List<AppMessage>> getMessages() async {
    if (_messagesCache != null) {
      return List<AppMessage>.from(_messagesCache!);
    }

    final messages = await _readList<AppMessage>(
      key: _messagesKey,
      parser: (json) => AppMessage.fromJson(json),
    );
    messages.sort((first, second) => first.sentAt.compareTo(second.sentAt));
    _messagesCache = List<AppMessage>.from(messages);
    return _messagesCache!;
  }

  Future<void> saveMessages(List<AppMessage> messages) async {
    _messagesCache = List<AppMessage>.from(messages);
    await _writeList(
      key: _messagesKey,
      data: messages.map((message) => message.toJson()).toList(),
    );
  }

  Future<List<AppMessage>> getChatMessages(
    String currentUserId,
    String otherUserId,
  ) async {
    final messages = await getMessages();
    return messages
        .where((message) => message.belongsToChat(currentUserId, otherUserId))
        .toList();
  }

  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String text,
  }) async {
    final messages = await getMessages();
    messages.add(
      AppMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        senderId: senderId,
        receiverId: receiverId,
        text: text.trim(),
        sentAt: DateTime.now(),
      ),
    );
    await saveMessages(messages);
  }

  Future<AppMessage?> getLastMessage(
    String currentUserId,
    String otherUserId,
  ) async {
    final chatMessages = await getChatMessages(currentUserId, otherUserId);
    if (chatMessages.isEmpty) {
      return null;
    }
    return chatMessages.last;
  }
}
