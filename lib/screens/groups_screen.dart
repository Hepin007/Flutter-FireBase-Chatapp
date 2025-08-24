import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/group_model.dart';
import 'group_chat_screen.dart';

// Simple Groups Screen - Easy to understand for beginners
class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Create group button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _showCreateGroupDialog,
              icon: const Icon(Icons.add),
              label: const Text('Create New Group'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ),
        
        // Groups list
        Expanded(
          child: StreamBuilder<List<GroupModel>>(
            stream: _firebaseService.getUserGroups(),
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

              List<GroupModel> groups = snapshot.data ?? [];

              if (groups.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.group_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No groups yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Create a group to start group chatting',
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
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  GroupModel group = groups[index];
                  return _buildGroupTile(context, group);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // Build individual group tile
  Widget _buildGroupTile(BuildContext context, GroupModel group) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        // Group avatar
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            group.groupName.isNotEmpty ? group.groupName[0].toUpperCase() : 'G',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        // Group info
        title: Text(
          group.groupName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        
        subtitle: Text(
          '${group.members.length} members',
          style: const TextStyle(fontSize: 12),
        ),
        
        // Tap to open group chat
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GroupChatScreen(
                groupId: group.groupId,
                groupName: group.groupName,
              ),
            ),
          );
        },
        
        // Trailing icon
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  // Show create group dialog
  void _showCreateGroupDialog() {
    final TextEditingController groupNameController = TextEditingController();
    final TextEditingController memberController = TextEditingController();
    List<String> members = [];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: groupNameController,
              decoration: const InputDecoration(
                labelText: 'Group Name',
                hintText: 'Enter group name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: memberController,
              decoration: const InputDecoration(
                labelText: 'Add Member (User ID)',
                hintText: 'Enter user ID to add',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            if (members.isNotEmpty)
              Text('Members: ${members.join(', ')}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (groupNameController.text.trim().isNotEmpty) {
                // Add current user to members
                members.add('current_user_id'); // In real app, get from auth
                
                _firebaseService.createGroup(
                  groupNameController.text.trim(),
                  members,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
