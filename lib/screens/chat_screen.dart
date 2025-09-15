import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/firebase_service.dart';
import '../models/message_model.dart';

// Simple Chat Screen - Easy to understand for beginners
class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;

  const ChatScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  final ScrollController _scrollController = ScrollController();
  late final Stream<List<MessageModel>> _messagesStream;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverName),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: _messagesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                List<MessageModel> messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Start the conversation!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    MessageModel message = messages[index];
                    final currentUser = Provider.of<AuthProvider>(context).currentUser;
                    final isMe = message.senderId == currentUser?.uid;
                    return _buildMessageBubble(message, isMe);
                  },
                );
              },
            ),
          ),
          
          // Message input
          _buildMessageInput(),
        ],
      ),
    );
  }

  // Build message bubble
  Widget _buildMessageBubble(MessageModel message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isMe
              ? Theme.of(context).colorScheme.primary
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
          ),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.message,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatMessageTime(message.timestamp),
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe ? Colors.white70 : Colors.grey,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  _buildMessageStatus(message),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Build message input area
  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Text input field
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          
          // Send button
          FloatingActionButton(
            onPressed: _sendMessage,
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            child: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  // Send message function
  void _sendMessage() {
    final messageText = _messageController.text.trim();
    
    // Validate message is not empty and not just whitespace
    if (messageText.isNotEmpty && messageText.length > 0) {
      _firebaseService.sendMessage(
        widget.receiverId,
        messageText,
      );
      _messageController.clear();
      
      // Scroll to bottom
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } else {
      // Show error if trying to send empty message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a message'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Build message status indicator
  Widget _buildMessageStatus(MessageModel message) {
    IconData iconData;
    Color iconColor;
    
    if (message.isSeen) {
      iconData = Icons.done_all;
      iconColor = Colors.black;
    } else if (message.isDelivered) {
      iconData = Icons.done_all;
      iconColor = Colors.white70;
    } else {
      iconData = Icons.done;
      iconColor = Colors.white70;
    }
    
    return Icon(
      iconData,
      size: 12,
      color: iconColor,
    );
  }

  // Format message time
  String _formatMessageTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate == today) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      return '${time.day}/${time.month} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _messagesStream = _firebaseService.getMessages(widget.receiverId);
    
    // Mark messages as read and seen when chat screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _firebaseService.markMessagesAsRead(widget.receiverId);
      _firebaseService.markMessagesAsSeen(widget.receiverId);
    });
  }
}
