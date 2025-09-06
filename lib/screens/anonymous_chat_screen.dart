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
                onPressed: _joinRoomById,
                icon: const Icon(Icons.key),
                label: const Text('Join Room by ID'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
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
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Room ID: $_currentChatId',
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 20),
                            onPressed: _copyRoomId,
                            tooltip: 'Copy Room ID',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Share this ID with others to let them join!',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                        fontStyle: FontStyle.italic,
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
                  Text('• Join Room by ID: Enter a specific room ID to join'),
                  Text('• Join Random Chat: Get matched with random users'),
                  Text('• Create New Room: Create a room and share the ID'),
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
      
      if (!mounted) return;
      
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
      if (!mounted) return;
      
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
      
      if (!mounted) return;
      
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
      if (!mounted) return;
      
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

  // Join room by ID
  void _joinRoomById() {
    final TextEditingController roomIdController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Join Room by ID'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter the room ID to join an existing anonymous chat room.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: roomIdController,
              decoration: const InputDecoration(
                labelText: 'Room ID',
                hintText: 'Enter room ID here...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.key),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final roomId = roomIdController.text.trim();
              if (roomId.isNotEmpty) {
                Navigator.pop(context);
                _joinSpecificRoom(roomId);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a room ID'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            child: const Text('Join Room'),
          ),
        ],
      ),
    );
  }

  // Join specific room by ID
  Future<void> _joinSpecificRoom(String roomId) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Checking room...'),
            ],
          ),
        ),
      );

      // Check if room exists
      bool roomExists = await _firebaseService.checkAnonymousChatExists(roomId);
      
      // Close loading dialog
      if (mounted) Navigator.pop(context);
      
      if (roomExists) {
        setState(() {
          _currentChatId = roomId;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Successfully joined room! You can now enter the chat.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Room not found or is inactive. Please check the room ID.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) Navigator.pop(context);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to join room: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Copy room ID to clipboard
  void _copyRoomId() {
    if (_currentChatId != null) {
      // In a real app, you'd use Clipboard.setData
      // For now, we'll show a dialog with the room ID
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Room ID'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Share this room ID with others:'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SelectableText(
                  _currentChatId!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Others can join by entering this ID in the "Join Room by ID" option.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
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
