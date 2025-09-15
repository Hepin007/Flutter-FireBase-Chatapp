// Simple Message Model - Easy to understand for beginners
class MessageModel {
  final String messageId;     // Unique message ID
  final String senderId;      // Who sent the message
  final String message;       // The actual message text
  final DateTime timestamp;   // When was it sent
  final bool isRead;          // Has the message been read?
  final bool isDelivered;     // Has the message been delivered?
  final bool isSeen;          // Has the message been seen?

  // Constructor - this creates a new message
  MessageModel({
    required this.messageId,
    required this.senderId,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.isDelivered = false,
    this.isSeen = false,
  });

  // Convert message data to a map (for saving to Firebase)
  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'message': message,
      'timestamp': timestamp,
      'isRead': isRead,
      'isDelivered': isDelivered,
      'isSeen': isSeen,
    };
  }

  // Create a message from a map (for reading from Firebase)
  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      messageId: map['messageId'] ?? '',
      senderId: map['senderId'] ?? '',
      message: map['message'] ?? '',
      timestamp: map['timestamp']?.toDate() ?? DateTime.now(),
      isRead: map['isRead'] ?? false,
      isDelivered: map['isDelivered'] ?? false,
      isSeen: map['isSeen'] ?? false,
    );
  }
}
