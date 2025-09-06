import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import 'chat_screen.dart';

// Simple Search Screen - Easy to understand for beginners
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // Controller for search input
  final TextEditingController _searchController = TextEditingController();
  
  // Search results
  UserModel? _searchResult;
  
  // Loading state
  bool _isLoading = false;
  
  // Search type (username or phone)
  String _searchType = 'username';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Search type selector
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Search by:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Username'),
                          value: 'username',
                          groupValue: _searchType,
                          onChanged: (value) {
                            setState(() {
                              _searchType = value!;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Phone Number'),
                          value: 'phone',
                          groupValue: _searchType,
                          onChanged: (value) {
                            setState(() {
                              _searchType = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Search input field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: _searchType == 'username' ? 'Enter Username' : 'Enter Phone Number',
              hintText: _searchType == 'username' ? 'e.g., john_doe' : 'e.g., +1234567890',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchResult = null;
                  });
                },
              ),
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (_) => _searchUser(),
          ),
          const SizedBox(height: 16),
          
          // Search button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _searchUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Search',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Search results
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  // Build search results
  Widget _buildSearchResults() {
    if (_searchResult == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Search for users to start chatting',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      child: ListTile(
        // User avatar
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            _searchResult!.fullName.isNotEmpty 
                ? _searchResult!.fullName[0].toUpperCase() 
                : 'U',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        // User info
        title: Text(
          _searchResult!.fullName.isNotEmpty 
              ? _searchResult!.fullName 
              : _searchResult!.username,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Username: ${_searchResult!.username}'),
            Text('Phone: ${_searchResult!.phoneNumber}'),
            Text(
              _searchResult!.isOnline ? 'Online' : 'Offline',
              style: TextStyle(
                color: _searchResult!.isOnline ? Colors.green : Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        
        // Chat button
        trailing: ElevatedButton(
          onPressed: () => _startChat(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Chat'),
        ),
        
        isThreeLine: true,
      ),
    );
  }

  // Search user function
  Future<void> _searchUser() async {
    if (_searchController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a search term'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get auth provider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Search for user
      UserModel? result = await authProvider.searchUser(_searchController.text.trim());

      setState(() {
        _searchResult = result;
        _isLoading = false;
      });

      if (result == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not found'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Start chat function
  void _startChat() {
    if (_searchResult != null) {
      // Ensure chat summary exists by sending an empty system message as metadata seed is not ideal.
      // Instead, we'll create or update chat metadata with a placeholder lastMessage.
      final firebase = FirebaseService();
      firebase
          .sendMessage(_searchResult!.uid, '')
          .then((_) {})
          .catchError((_) {});

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            receiverId: _searchResult!.uid,
            receiverName: _searchResult!.fullName.isNotEmpty 
                ? _searchResult!.fullName 
                : _searchResult!.username,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
