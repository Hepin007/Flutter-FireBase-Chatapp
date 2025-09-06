import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';
import '../models/group_model.dart';
import '../models/user_model.dart';
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
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final List<String> selectedMemberIds = [];
    final List<String> selectedMemberLabels = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create New Group'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Group name input
                TextField(
                  controller: groupNameController,
                  decoration: const InputDecoration(
                    labelText: 'Group Name',
                    hintText: 'Enter group name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Selected members
                if (selectedMemberIds.isNotEmpty) ...[
                  const Text(
                    'Selected Members:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (int i = 0; i < selectedMemberIds.length; i++)
                        Chip(
                          label: Text(selectedMemberLabels[i]),
                          onDeleted: () {
                            setState(() {
                              selectedMemberIds.removeAt(i);
                              selectedMemberLabels.removeAt(i);
                            });
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Available users from chat list
                const Text(
                  'Select from your contacts:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: StreamBuilder<List<UserModel>>(
                    stream: _firebaseService.getUserChats(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      
                      List<UserModel> users = snapshot.data ?? [];
                      if (users.isEmpty) {
                        return const Center(
                          child: Text('No contacts found. Start chatting with someone first!'),
                        );
                      }
                      
                      return ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          final isSelected = selectedMemberIds.contains(user.uid);
                          
                          return CheckboxListTile(
                            title: Text(user.fullName.isNotEmpty ? user.fullName : user.username),
                            subtitle: Text('@${user.username}'),
                            value: isSelected,
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  selectedMemberIds.add(user.uid);
                                  selectedMemberLabels.add(user.fullName.isNotEmpty ? user.fullName : user.username);
                                } else {
                                  final index = selectedMemberIds.indexOf(user.uid);
                                  if (index != -1) {
                                    selectedMemberIds.removeAt(index);
                                    selectedMemberLabels.removeAt(index);
                                  }
                                }
                              });
                            },
                          );
                        },
                      );
                    },
                  ),
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
                if (groupNameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a group name')),
                  );
                  return;
                }

                // Always include current user
                final String? currentUserId = auth.currentUser?.uid;
                final List<String> finalMembers = [
                  if (currentUserId != null && currentUserId.isNotEmpty) currentUserId,
                  ...selectedMemberIds,
                ];
                final uniqueMembers = finalMembers.toSet().toList();

                // Require at least 2 members (including current user)
                if (uniqueMembers.length < 2) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Select at least one more member to create a group'),
                    ),
                  );
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

}
