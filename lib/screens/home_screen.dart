import 'package:flutter/material.dart';

import '../models/app_message.dart';
import '../models/app_user.dart';
import '../services/local_chat_store.dart';
import 'chat_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.currentUser});

  final AppUser currentUser;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _store = LocalChatStore();
  late Future<List<_ChatPreview>> _previewsFuture;

  @override
  void initState() {
    super.initState();
    _previewsFuture = _loadPreviews();
  }

  Future<List<_ChatPreview>> _loadPreviews() async {
    final users = await _store.getUsers();
    final otherUsers = users
        .where((user) => user.id != widget.currentUser.id)
        .toList()
      ..sort((first, second) => first.name.compareTo(second.name));

    final previews = <_ChatPreview>[];
    for (final user in otherUsers) {
      previews.add(
        _ChatPreview(
          user: user,
          lastMessage: await _store.getLastMessage(widget.currentUser.id, user.id),
        ),
      );
    }

    previews.sort((first, second) {
      final firstDate = first.lastMessage?.sentAt;
      final secondDate = second.lastMessage?.sentAt;
      if (firstDate == null && secondDate == null) {
        return first.user.name.compareTo(second.user.name);
      }
      if (firstDate == null) {
        return 1;
      }
      if (secondDate == null) {
        return -1;
      }
      return secondDate.compareTo(firstDate);
    });

    return previews;
  }

  void _refresh() {
    setState(() {
      _previewsFuture = _loadPreviews();
    });
  }

  Future<void> _openChat(AppUser otherUser) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          currentUser: widget.currentUser,
          otherUser: otherUser,
        ),
      ),
    );
    _refresh();
  }

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('WhatsApp'),
              Text(
                widget.currentUser.name,
                style: const TextStyle(fontSize: 13, color: Colors.white70),
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'تحديث',
              onPressed: _refresh,
              icon: const Icon(Icons.refresh),
            ),
            IconButton(
              tooltip: 'تسجيل الخروج',
              onPressed: _logout,
              icon: const Icon(Icons.logout),
            ),
          ],
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(44),
            child: _WhatsAppTabs(),
          ),
        ),
        body: FutureBuilder<List<_ChatPreview>>(
          future: _previewsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final previews = snapshot.data ?? [];
            if (previews.isEmpty) {
              return const _EmptyUsersView();
            }

            return ListView.separated(
              itemCount: previews.length,
              separatorBuilder: (_, _) => const Divider(
                height: 1,
                indent: 78,
                color: Color(0xFFE1E5E8),
              ),
              itemBuilder: (context, index) {
                final preview = previews[index];
                return ListTile(
                  tileColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  leading: _UserAvatar(name: preview.user.name),
                  title: Text(
                    preview.user.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    preview.lastMessage?.text ?? 'ابدأ محادثة جديدة',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  trailing: Text(
                    _formatPreviewTime(preview.lastMessage?.sentAt),
                    style: const TextStyle(
                      color: Color(0xFF00A884),
                      fontSize: 12,
                    ),
                  ),
                  onTap: () => _openChat(preview.user),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF00A884),
          foregroundColor: Colors.white,
          onPressed: _refresh,
          child: const Icon(Icons.chat),
        ),
      ),
    );
  }

  String _formatPreviewTime(DateTime? dateTime) {
    if (dateTime == null) {
      return '';
    }
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _ChatPreview {
  const _ChatPreview({required this.user, required this.lastMessage});

  final AppUser user;
  final AppMessage? lastMessage;
}

class _WhatsAppTabs extends StatelessWidget {
  const _WhatsAppTabs();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF075E54),
      child: const Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: 12, top: 8),
              child: Icon(Icons.camera_alt, color: Colors.white70, size: 20),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.only(bottom: 12, top: 8),
              child: Text(
                'الدردشات',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.only(bottom: 12, top: 8),
              child: Text(
                'الحالة',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.only(bottom: 12, top: 8),
              child: Text(
                'المكالمات',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final letter = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    return CircleAvatar(
      radius: 26,
      backgroundColor: const Color(0xFFD9FDD3),
      child: Text(
        letter,
        style: const TextStyle(
          color: Color(0xFF075E54),
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }
}

class _EmptyUsersView extends StatelessWidget {
  const _EmptyUsersView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.groups_2, size: 76, color: Colors.grey.shade500),
            const SizedBox(height: 16),
            const Text(
              'لا يوجد مستخدمون آخرون بعد',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'أنشئ حسابًا ثانيًا من شاشة الدخول ثم عد لهذا الحساب لتبدأ المحادثة.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}
