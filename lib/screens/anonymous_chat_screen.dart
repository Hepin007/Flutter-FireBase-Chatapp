import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import 'anonymous_chat_room_screen.dart';

// Simple Anonymous Chat Screen - Easy to understand for beginners
class AnonymousChatScreen extends StatefulWidget {
  const AnonymousChatScreen({super.key});

  @override
  State<AnonymousChatScreen> createState() => _AnonymousChatScreenState();
}

class _AnonymousChatScreenState extends State<AnonymousChatScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  String? _currentChatId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Icon(
                    Icons.visibility_off,
                    size: 48,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Anonymous Chat',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Chat anonymously with other users. Your identity will be hidden.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Join or create chat buttons
          if (_currentChatId == null) ...[
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _joinRandomChat,
                icon: const Icon(Icons.join_full),
                label: const Text('Join Random Chat'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _createNewChat,
                icon: const Icon(Icons.add),
                label: const Text('Create New Chat Room'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ] else ...[
            // Current chat info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Current Chat Room',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Room ID: ${_currentChatId!.substring(0, 8)}...',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => _openChatRoom(),
                icon: const Icon(Icons.chat),
                label: const Text('Enter Chat Room'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _leaveChat,
                icon: const Icon(Icons.exit_to_app),
                label: const Text('Leave Chat'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Instructions
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How it works:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('• Join a random chat room to chat with others'),
                  Text('• Create a new room and share the ID with friends'),
                  Text('• All messages are anonymous'),
                  Text('• Leave anytime to end the conversation'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Join random chat
  Future<void> _joinRandomChat() async {
    try {
      // For simplicity, we'll create a new chat room
      // In a real app, you'd find an existing room
      String chatId = await _firebaseService.createAnonymousChat();
      
      setState(() {
        _currentChatId = chatId;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Joined chat room!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Create new chat
  Future<void> _createNewChat() async {
    try {
      String chatId = await _firebaseService.createAnonymousChat();
      
      setState(() {
        _currentChatId = chatId;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Created chat room! ID: ${chatId.substring(0, 8)}...'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Open chat room
  void _openChatRoom() {
    if (_currentChatId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AnonymousChatRoomScreen(
            chatId: _currentChatId!,
          ),
        ),
      );
    }
  }

  // Leave chat
  void _leaveChat() {
    setState(() {
      _currentChatId = null;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Left chat room'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
