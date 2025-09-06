import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/message_model.dart';
import '../models/group_model.dart';
import '../models/user_model.dart';
import '../models/chat_summary.dart';

// Simple Firebase Service - Easy to understand for beginners
class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = Uuid();

  // Send a message to another user
  Future<void> sendMessage(String receiverId, String message) async {
    try {
      // Create a unique chat ID (combine both user IDs)
      String chatId = _getChatId(receiverId);
      
      // Create message model
      MessageModel newMessage = MessageModel(
        messageId: _uuid.v4(),
        senderId: _getCurrentUserId(),
        message: message,
        timestamp: DateTime.now(),
      );

      // Save message to Firestore
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(newMessage.messageId)
          .set(newMessage.toMap());

      // Upsert chat metadata for both users
      await _upsertChatSummaryForUsers(
        chatId: chatId,
        otherUserId: receiverId,
        lastMessage: message,
        timestamp: newMessage.timestamp,
      );
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }

  // Get messages for a chat
  Stream<List<MessageModel>> getMessages(String receiverId) {
    String chatId = _getChatId(receiverId);
    
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return MessageModel.fromMap(doc.data());
          }).toList();
        });
  }

  // Create a new group
  Future<void> createGroup(String groupName, List<String> memberIds) async {
    try {
      String groupId = _uuid.v4();
      
      GroupModel newGroup = GroupModel(
        groupId: groupId,
        groupName: groupName,
        createdBy: _getCurrentUserId(),
        members: memberIds,
        createdAt: DateTime.now(),
      );

      // Save group to Firestore
      await _firestore
          .collection('groups')
          .doc(groupId)
          .set(newGroup.toMap());
    } catch (e) {
      debugPrint('Error creating group: $e');
    }
  }

  // Send message to a group
  Future<void> sendGroupMessage(String groupId, String message) async {
    try {
      MessageModel newMessage = MessageModel(
        messageId: _uuid.v4(),
        senderId: _getCurrentUserId(),
        message: message,
        timestamp: DateTime.now(),
      );

      // Save message to group chat
      await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('messages')
          .doc(newMessage.messageId)
          .set(newMessage.toMap());
    } catch (e) {
      debugPrint('Error sending group message: $e');
    }
  }

  // Get group messages
  Stream<List<MessageModel>> getGroupMessages(String groupId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return MessageModel.fromMap(doc.data());
          }).toList();
        });
  }

  // Get user's groups
  Stream<List<GroupModel>> getUserGroups() {
    return _firestore
        .collection('groups')
        .where('members', arrayContains: _getCurrentUserId())
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return GroupModel.fromMap(doc.data());
          }).toList();
        });
  }

  // Get user's chats (recent conversations)
  Stream<List<UserModel>> getUserChats() {
    // Stream chat summaries for current user and resolve to user objects
    final String currentUserId = _getCurrentUserId();
    return _firestore
        .collection('user_chats')
        .doc(currentUserId)
        .collection('chats')
        .orderBy('lastTimestamp', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          final List<UserModel> result = [];
          for (final doc in snapshot.docs) {
            final data = doc.data();
            final otherId = data['otherUserId'] as String? ?? '';
            if (otherId.isEmpty) continue;
            final userDoc = await _firestore.collection('users').doc(otherId).get();
            if (userDoc.exists) {
              result.add(UserModel.fromMap(userDoc.data() as Map<String, dynamic>));
            }
          }
          return result;
        });
  }

  // Helper method to get current user ID
  String _getCurrentUserId() {
    // Get the current user ID from Firebase Auth
    final user = _auth.currentUser;
    if (user != null) {
      return user.uid;
    }
    throw Exception('User not authenticated');
  }

  // Helper method to create chat ID
  String _getChatId(String receiverId) {
    String currentUserId = _getCurrentUserId();
    // Create a consistent chat ID by sorting user IDs
    List<String> userIds = [currentUserId, receiverId];
    userIds.sort();
    return userIds.join('_');
  }

  // Upsert chat summary for both users
  Future<void> _upsertChatSummaryForUsers({
    required String chatId,
    required String otherUserId,
    required String lastMessage,
    required DateTime timestamp,
  }) async {
    final String currentUserId = _getCurrentUserId();
    final WriteBatch batch = _firestore.batch();

    final Map<String, dynamic> currentSummary = ChatSummary(
      chatId: chatId,
      otherUserId: otherUserId,
      lastMessage: lastMessage,
      lastTimestamp: timestamp,
    ).toMap();
    final Map<String, dynamic> otherSummary = ChatSummary(
      chatId: chatId,
      otherUserId: currentUserId,
      lastMessage: lastMessage,
      lastTimestamp: timestamp,
    ).toMap();

    final DocumentReference meRef = _firestore
        .collection('user_chats')
        .doc(currentUserId)
        .collection('chats')
        .doc(otherUserId);
    final DocumentReference otherRef = _firestore
        .collection('user_chats')
        .doc(otherUserId)
        .collection('chats')
        .doc(currentUserId);

    batch.set(meRef, currentSummary, SetOptions(merge: true));
    batch.set(otherRef, otherSummary, SetOptions(merge: true));

    await batch.commit();
  }

  // Delete a chat for current user (metadata and messages option)
  Future<void> deleteChatForCurrentUser(String otherUserId, {bool deleteMessages = false}) async {
    try {
      final String currentUserId = _getCurrentUserId();
      final String chatId = _getChatId(otherUserId);

      // Remove the chat summary for current user
      await _firestore
          .collection('user_chats')
          .doc(currentUserId)
          .collection('chats')
          .doc(otherUserId)
          .delete();

      if (deleteMessages) {
        // Delete all messages in the chat thread
        final messagesRef = _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages');
        final query = await messagesRef.get();
        final WriteBatch batch = _firestore.batch();
        for (final doc in query.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }
    } catch (e) {
      debugPrint('Error deleting chat: $e');
    }
  }

  // Anonymous chat - create a temporary chat room
  Future<String> createAnonymousChat() async {
    try {
      String chatId = _uuid.v4();
      
      // Create anonymous chat document
      await _firestore
          .collection('anonymous_chats')
          .doc(chatId)
          .set({
        'chatId': chatId,
        'createdAt': DateTime.now(),
        'active': true,
      });

      return chatId;
    } catch (e) {
      debugPrint('Error creating anonymous chat: $e');
      return '';
    }
  }

  // Send anonymous message
  Future<void> sendAnonymousMessage(String chatId, String message) async {
    try {
      MessageModel newMessage = MessageModel(
        messageId: _uuid.v4(),
        senderId: 'anonymous_${_uuid.v4()}',
        message: message,
        timestamp: DateTime.now(),
      );

      await _firestore
          .collection('anonymous_chats')
          .doc(chatId)
          .collection('messages')
          .doc(newMessage.messageId)
          .set(newMessage.toMap());
    } catch (e) {
      debugPrint('Error sending anonymous message: $e');
    }
  }

  // Get anonymous chat messages
  Stream<List<MessageModel>> getAnonymousMessages(String chatId) {
    return _firestore
        .collection('anonymous_chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return MessageModel.fromMap(doc.data());
          }).toList();
        });
  }

  // Check if anonymous chat room exists
  Future<bool> checkAnonymousChatExists(String chatId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('anonymous_chats')
          .doc(chatId)
          .get();
      
      return doc.exists && (doc.data() as Map<String, dynamic>?)?['active'] == true;
    } catch (e) {
      debugPrint('Error checking anonymous chat: $e');
      return false;
    }
  }
}
