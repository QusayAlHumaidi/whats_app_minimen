import 'package:flutter/material.dart';

import '../models/app_message.dart';
import '../models/app_user.dart';
import '../services/local_chat_store.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.currentUser,
    required this.otherUser,
  });

  final AppUser currentUser;
  final AppUser otherUser;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _store = LocalChatStore();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  late Future<List<AppMessage>> _messagesFuture;

  @override
  void initState() {
    super.initState();
    _messagesFuture = _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<List<AppMessage>> _loadMessages() {
    return _store.getChatMessages(widget.currentUser.id, widget.otherUser.id);
  }

  void _refreshMessages() {
    setState(() {
      _messagesFuture = _loadMessages();
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) {
      return;
    }

    _messageController.clear();
    await _store.sendMessage(
      senderId: widget.currentUser.id,
      receiverId: widget.otherUser.id,
      text: text,
    );
    _refreshMessages();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          title: Row(
            children: [
              CircleAvatar(
                radius: 19,
                backgroundColor: const Color(0xFFD9FDD3),
                child: Text(
                  widget.otherUser.name.trim()[0].toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF075E54),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.otherUser.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Text(
                      'متصل الآن',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'تحديث',
              onPressed: _refreshMessages,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFECE5DD),
          ),
          child: Column(
            children: [
              Expanded(
                child: FutureBuilder<List<AppMessage>>(
                  future: _messagesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final messages = snapshot.data ?? [];
                    if (messages.isEmpty) {
                      return Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3C4),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('ابدأ المحادثة برسالة قصيرة'),
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 12,
                      ),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isMine =
                            message.senderId == widget.currentUser.id;
                        return _MessageBubble(
                          message: message,
                          isMine: isMine,
                        );
                      },
                    );
                  },
                ),
              ),
              _MessageInput(
                controller: _messageController,
                onSend: _sendMessage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMine});

  final AppMessage message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.76,
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.fromLTRB(10, 7, 10, 5),
          decoration: BoxDecoration(
            color: isMine ? const Color(0xFFD9FDD3) : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(10),
              topRight: const Radius.circular(10),
              bottomLeft: Radius.circular(isMine ? 10 : 2),
              bottomRight: Radius.circular(isMine ? 2 : 10),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message.text,
                style: const TextStyle(fontSize: 15, height: 1.35),
              ),
              const SizedBox(height: 3),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(message.sentAt),
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                  if (isMine) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.done_all,
                      size: 15,
                      color: Color(0xFF53BDEB),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _MessageInput extends StatelessWidget {
  const _MessageInput({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: 'رسالة',
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.emoji_emotions_outlined),
                  suffixIcon: const Icon(Icons.attach_file),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF00A884),
              child: IconButton(
                tooltip: 'إرسال',
                onPressed: onSend,
                icon: const Icon(Icons.send, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
