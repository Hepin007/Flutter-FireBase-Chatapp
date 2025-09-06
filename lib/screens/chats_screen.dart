import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/user_model.dart';
import 'chat_screen.dart';

// Simple Chats Screen - Easy to understand for beginners
class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseService();

    return StreamBuilder<List<UserModel>>(
      stream: firebaseService.getUserChats(),
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

        List<UserModel> users = snapshot.data ?? [];

        if (users.isEmpty) {
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
          itemCount: users.length,
          itemBuilder: (context, index) {
            UserModel user = users[index];
            return Dismissible(
              key: ValueKey(user.uid),
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
                firebaseService.deleteChatForCurrentUser(user.uid, deleteMessages: false);
                // Show immediate feedback since the chat is already removed from UI
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chat removed')),
                );
              },
              child: _buildChatTile(context, user),
            );
          },
        );
      },
    );
  }

  // Build individual chat tile
  Widget _buildChatTile(BuildContext context, UserModel user) {
    return ListTile(
      // User avatar
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Text(
          user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      
      // User name and status
      title: Text(
        user.fullName.isNotEmpty ? user.fullName : user.username,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      
      subtitle: Text(
        user.isOnline ? 'Online' : 'Offline',
        style: TextStyle(
          color: user.isOnline ? Colors.green : Colors.grey,
          fontSize: 12,
        ),
      ),
      
      // Tap to open chat
      onTap: () {
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
      
      // Trailing icon
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }
}
