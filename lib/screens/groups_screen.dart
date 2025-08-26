import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';
import '../models/group_model.dart';
import 'group_chat_screen.dart';
import '../providers/auth_provider.dart';

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
    final TextEditingController addByUsernameController = TextEditingController();
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final List<String> memberIds = [];
    final List<String> memberLabels = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create New Group'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: addByUsernameController,
                        decoration: const InputDecoration(
                          labelText: 'Add by username',
                          hintText: 'e.g., john_doe',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) async {
                          await _addMemberByUsername(addByUsernameController, auth, memberIds, memberLabels, setState);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        await _addMemberByUsername(addByUsernameController, auth, memberIds, memberLabels, setState);
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (memberIds.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (int i = 0; i < memberIds.length; i++)
                        Chip(
                          label: Text(memberLabels[i]),
                          onDeleted: () {
                            setState(() {
                              memberIds.removeAt(i);
                              memberLabels.removeAt(i);
                            });
                          },
                        ),
                    ],
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (groupNameController.text.trim().isEmpty) return;

                // Always include current user
                final String? currentUserId = auth.currentUser?.uid;
                final List<String> finalMembers = [
                  if (currentUserId != null && currentUserId.isNotEmpty) currentUserId,
                  ...memberIds,
                ];
                final uniqueMembers = finalMembers.toSet().toList();

                // Require at least 2 members (including current user)
                if (uniqueMembers.length < 2) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Add at least one more member to create a group'),
                      ),
                    );
                  }
                  return;
                }

                _firebaseService.createGroup(
                  groupNameController.text.trim(),
                  uniqueMembers,
                );
                Navigator.pop(context);
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addMemberByUsername(
    TextEditingController controller,
    AuthProvider auth,
    List<String> memberIds,
    List<String> memberLabels,
    void Function(void Function()) setState,
  ) async {
    final term = controller.text.trim();
    if (term.isEmpty) return;

    final result = await auth.searchUser(term);
    if (result == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found')),
        );
      }
      return;
    }

    if (memberIds.contains(result.uid)) {
      controller.clear();
      return;
    }

    // Prevent adding self twice (we add current user on create)
    if (result.uid == auth.currentUser?.uid) {
      controller.clear();
      return;
    }

    setState(() {
      memberIds.add(result.uid);
      memberLabels.add(result.fullName.isNotEmpty ? result.fullName : result.username);
    });
    controller.clear();
  }
}
