import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import '../models/user_model.dart';
import '../models/chat_summary.dart';
import '../providers/notification_provider.dart';
import '../widgets/notification_badge.dart';
import 'chat_screen.dart';

// Simple Chats Screen - Easy to understand for beginners
class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseService();

    return StreamBuilder<List<ChatSummary>>(
      stream: firebaseService.getUserChatSummaries(),
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

        List<ChatSummary> chatSummaries = snapshot.data ?? [];

        if (chatSummaries.isEmpty) {
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
                  'No chats yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Search for users to start chatting',
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
          itemCount: chatSummaries.length,
          itemBuilder: (context, index) {
            ChatSummary chatSummary = chatSummaries[index];
            return Dismissible(
              key: ValueKey(chatSummary.otherUserId),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              confirmDismiss: (_) async {
                return await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete chat'),
                        content: const Text('Remove this chat from your list? Messages can also be deleted.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Remove'),
                          ),
                        ],
                      ),
                    ) ??
                    false;
              },
              onDismissed: (_) {
                // Delete only metadata by default
                firebaseService.deleteChatForCurrentUser(chatSummary.otherUserId, deleteMessages: false);
                // Show immediate feedback since the chat is already removed from UI
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chat removed')),
                );
              },
              child: _buildChatTile(context, chatSummary),
            );
          },
        );
      },
    );
  }

  // Build individual chat tile
  Widget _buildChatTile(BuildContext context, ChatSummary chatSummary) {
    return FutureBuilder<UserModel?>(
      future: _getUserFromId(chatSummary.otherUserId),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(
            leading: CircleAvatar(child: CircularProgressIndicator()),
            title: Text('Loading...'),
          );
        }

        final user = userSnapshot.data;
        if (user == null) {
          return const ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text('Unknown User'),
          );
        }

        return ListTile(
          // User avatar with notification badge
          leading: Stack(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (chatSummary.unreadCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: NotificationBadge(
                    count: chatSummary.unreadCount > 4 ? '4+' : chatSummary.unreadCount.toString(),
                    size: 18,
                  ),
                ),
            ],
          ),
          
          // User name and last message
          title: Text(
            user.fullName.isNotEmpty ? user.fullName : user.username,
            style: TextStyle(
              fontWeight: chatSummary.unreadCount > 0 ? FontWeight.bold : FontWeight.w600,
            ),
          ),
          
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                chatSummary.lastMessage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: chatSummary.unreadCount > 0 ? Colors.black87 : Colors.grey[600],
                  fontWeight: chatSummary.unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatTimestamp(chatSummary.lastTimestamp),
                style: TextStyle(
                  color: chatSummary.unreadCount > 0 ? Theme.of(context).colorScheme.primary : Colors.grey,
                  fontSize: 12,
                  fontWeight: chatSummary.unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
          
          // Tap to open chat
          onTap: () async {
            // Mark messages as read when opening chat
            final firebaseService = FirebaseService();
            await firebaseService.markMessagesAsRead(chatSummary.otherUserId);
            
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  receiverId: user.uid,
                  receiverName: user.fullName.isNotEmpty ? user.fullName : user.username,
                ),
              ),
            );
          },

          // Long press to delete messages as well
          onLongPress: () async {
            final firebaseService = FirebaseService();
            final bool? deleteMsgs = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete chat messages'),
                content: const Text('Also delete all messages in this conversation? This cannot be undone.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Delete messages'),
                  ),
                ],
              ),
            );
            if (deleteMsgs == true) {
              await firebaseService.deleteChatForCurrentUser(user.uid, deleteMessages: true);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Messages deleted')),
                );
              }
            }
          },
          
          // Trailing notification badge or arrow
          trailing: chatSummary.unreadCount > 0
              ? NotificationBadge(
                  count: chatSummary.unreadCount > 4 ? '4+' : chatSummary.unreadCount.toString(),
                  size: 20,
                )
              : const Icon(Icons.arrow_forward_ios, size: 16),
        );
      },
    );
  }

  // Helper method to get user from ID
  Future<UserModel?> _getUserFromId(String userId) async {
    try {
      final firebaseService = FirebaseService();
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      
      if (userDoc.exists) {
        return UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user: $e');
      return null;
    }
  }

  // Helper method to format timestamp
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
