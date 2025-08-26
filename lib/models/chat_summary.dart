// Simple Chat Summary Model - for per-user chat list
class ChatSummary {
  final String chatId;               // Combined chat ID (sorted user IDs)
  final String otherUserId;          // The other participant user ID
  final String lastMessage;          // Last message preview
  final DateTime lastTimestamp;      // Last activity time

  ChatSummary({
    required this.chatId,
    required this.otherUserId,
    required this.lastMessage,
    required this.lastTimestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'otherUserId': otherUserId,
      'lastMessage': lastMessage,
      'lastTimestamp': lastTimestamp,
    };
  }

  factory ChatSummary.fromMap(Map<String, dynamic> map) {
    return ChatSummary(
      chatId: map['chatId'] ?? '',
      otherUserId: map['otherUserId'] ?? '',
      lastMessage: map['lastMessage'] ?? '',
      lastTimestamp: map['lastTimestamp']?.toDate() ?? DateTime.now(),
    );
  }
}


