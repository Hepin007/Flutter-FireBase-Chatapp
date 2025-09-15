import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Simple Notification Provider - Easy to understand for beginners
class NotificationProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Map to store unread message counts for each chat
  Map<String, int> _unreadCounts = {};
  
  // Get unread count for a specific chat
  int getUnreadCount(String chatId) {
    return _unreadCounts[chatId] ?? 0;
  }
  
  // Get total unread count across all chats
  int get totalUnreadCount {
    return _unreadCounts.values.fold(0, (sum, count) => sum + count);
  }
  
  // Get formatted unread count for display (shows "4+" if > 4)
  String getFormattedUnreadCount(String chatId) {
    final count = getUnreadCount(chatId);
    if (count == 0) return '';
    if (count > 4) return '4+';
    return count.toString();
  }
  
  // Get formatted total unread count for display
  String get formattedTotalUnreadCount {
    final count = totalUnreadCount;
    if (count == 0) return '';
    if (count > 4) return '4+';
    return count.toString();
  }
  
  // Check if there are any unread messages
  bool get hasUnreadMessages {
    return totalUnreadCount > 0;
  }
  
  // Load unread counts for all chats
  Future<void> loadUnreadCounts() async {
    try {
      final currentUserId = _getCurrentUserId();
      
      // Get all chat summaries for current user
      final chatSummaries = await _firestore
          .collection('user_chats')
          .doc(currentUserId)
          .collection('chats')
          .get();
      
      _unreadCounts.clear();
      
      // For each chat, count unread messages
      for (final doc in chatSummaries.docs) {
        final data = doc.data();
        final otherUserId = data['otherUserId'] as String? ?? '';
        final chatId = data['chatId'] as String? ?? '';
        
        if (otherUserId.isNotEmpty && chatId.isNotEmpty) {
          final unreadCount = await _countUnreadMessages(chatId, otherUserId);
          _unreadCounts[otherUserId] = unreadCount;
        }
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading unread counts: $e');
    }
  }
  
  // Count unread messages for a specific chat
  Future<int> _countUnreadMessages(String chatId, String otherUserId) async {
    try {
      final currentUserId = _getCurrentUserId();
      
      // Get messages from the other user that are not read by current user
      final query = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('senderId', isEqualTo: otherUserId)
          .where('isRead', isEqualTo: false)
          .get();
      
      return query.docs.length;
    } catch (e) {
      debugPrint('Error counting unread messages: $e');
      return 0;
    }
  }
  
  // Mark messages as read for a specific chat
  Future<void> markMessagesAsRead(String chatId, String otherUserId) async {
    try {
      final currentUserId = _getCurrentUserId();
      
      // Update all unread messages from the other user to read
      final query = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('senderId', isEqualTo: otherUserId)
          .where('isRead', isEqualTo: false)
          .get();
      
      final batch = _firestore.batch();
      for (final doc in query.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      
      await batch.commit();
      
      // Update local count
      _unreadCounts[otherUserId] = 0;
      notifyListeners();
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
    }
  }
  
  // Increment unread count when a new message is received
  void incrementUnreadCount(String otherUserId) {
    _unreadCounts[otherUserId] = (_unreadCounts[otherUserId] ?? 0) + 1;
    notifyListeners();
  }
  
  // Reset unread count for a specific chat
  void resetUnreadCount(String otherUserId) {
    _unreadCounts[otherUserId] = 0;
    notifyListeners();
  }
  
  // Helper method to get current user ID
  String _getCurrentUserId() {
    final user = _auth.currentUser;
    if (user != null) {
      return user.uid;
    }
    throw Exception('User not authenticated');
  }
  
  // Listen to real-time updates for unread counts
  void startListening() {
    final currentUserId = _getCurrentUserId();
    
    // Listen to chat summaries changes
    _firestore
        .collection('user_chats')
        .doc(currentUserId)
        .collection('chats')
        .snapshots()
        .listen((snapshot) {
      // Reload unread counts when chat summaries change
      loadUnreadCounts();
    });
  }

  // Refresh unread counts (useful when app comes to foreground)
  Future<void> refreshUnreadCounts() async {
    await loadUnreadCounts();
  }
  
  @override
  void dispose() {
    super.dispose();
  }
}
