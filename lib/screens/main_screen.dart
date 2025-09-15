import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../widgets/notification_badge.dart';
import 'chats_screen.dart';
import 'search_screen.dart';
import 'groups_screen.dart';
import 'anonymous_chat_screen.dart';
import 'profile_screen.dart';

// Simple Main Screen - Easy to understand for beginners
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Current selected tab index
  int _currentIndex = 0;

  // List of screens for each tab
  final List<Widget> _screens = [
    const ChatsScreen(),
    const SearchScreen(),
    const GroupsScreen(),
    const AnonymousChatScreen(),
    const ProfileScreen(),
  ];

  // List of tab titles
  final List<String> _titles = [
    'Chats',
    'Search',
    'Groups',
    'Anonymous',
    'Profile',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize notification provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
      notificationProvider.startListening();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar with title and logout button
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      
      // Main body - shows the selected screen
      body: _screens[_currentIndex],
      
      // Bottom navigation bar
      bottomNavigationBar: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          return BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Colors.grey,
            items: [
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    const Icon(Icons.chat),
                    if (notificationProvider.hasUnreadMessages)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: NotificationBadge(
                          count: notificationProvider.formattedTotalUnreadCount,
                          size: 16,
                        ),
                      ),
                  ],
                ),
                label: 'Chats',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Search',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.group),
                label: 'Groups',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.visibility_off),
                label: 'Anonymous',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          );
        },
      ),
    );
  }

  // Logout function
  Future<void> _logout() async {
    // Store context reference before any async operations
    final currentContext = context;
    final navigator = Navigator.of(currentContext);
    final authProvider = Provider.of<AuthProvider>(currentContext, listen: false);
    
    // Show confirmation dialog
    bool? confirm = await showDialog<bool>(
      context: currentContext,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Navigate back to login screen immediately
      navigator.pushReplacementNamed('/login');
      // Logout in background
      authProvider.logout();
    }
  }
}
