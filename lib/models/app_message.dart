class AppMessage {
  const AppMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.sentAt,
  });

  final String id;
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime sentAt;

  factory AppMessage.fromJson(Map<String, dynamic> json) {
    return AppMessage(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      text: json['text'] as String,
      sentAt: DateTime.parse(json['sentAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'sentAt': sentAt.toIso8601String(),
    };
  }

  bool belongsToChat(String firstUserId, String secondUserId) {
    return (senderId == firstUserId && receiverId == secondUserId) ||
        (senderId == secondUserId && receiverId == firstUserId);
  }
}
