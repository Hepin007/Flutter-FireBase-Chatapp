import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

// Simple Authentication Provider - Easy to understand for beginners
class AuthProvider extends ChangeNotifier {
  // Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Current user - null if not logged in
  UserModel? _currentUser;
  
  // Getter to access current user from other parts of the app
  UserModel? get currentUser => _currentUser;

  // Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  // Initialize the provider
  AuthProvider() {
    // Listen for authentication state changes
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        // User is logged in, get their data
        _getUserData(user.uid);
      } else {
        // User is logged out
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  // Get user data from Firestore
  Future<void> _getUserData(String uid) async {
    try {
      // Get user document from Firestore
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      
      if (doc.exists) {
        // Convert document data to UserModel
        _currentUser = UserModel.fromMap(doc.data() as Map<String, dynamic>);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error getting user data: $e');
    }
  }

  // Register a new user
  Future<bool> register({
    required String email,
    required String password,
    required String username,
    required String phoneNumber,
    required String fullName,
  }) async {
    try {
      // Enforce unique username (case-insensitive)
      final String usernameLower = username.trim().toLowerCase();
      final QuerySnapshot existing = await _firestore
          .collection('users')
          .where('usernameLower', isEqualTo: usernameLower)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        // Username already taken
        return false;
      }

      // Create user with email and password
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user model
      UserModel newUser = UserModel(
        uid: result.user!.uid,
        username: username,
        email: email,
        phoneNumber: phoneNumber,
        fullName: fullName,
      );

      // Save user data to Firestore
      final Map<String, dynamic> userData = newUser.toMap();
      // Store lowercase username to allow case-insensitive uniqueness checks/search
      userData['usernameLower'] = usernameLower;
      await _firestore
          .collection('users')
          .doc(result.user!.uid)
          .set(userData);

      return true;
    } catch (e) {
      debugPrint('Registration error: $e');
      return false;
    }
  }

  // Login user
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      // Sign in with email and password
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }

  // Search user by username or phone number
  Future<UserModel?> searchUser(String searchTerm) async {
    try {
      final String term = searchTerm.trim();
      if (term.isEmpty) return null;

      // First try exact username match (case-insensitive)
      QuerySnapshot exactUsernameQuery = await _firestore
          .collection('users')
          .where('usernameLower', isEqualTo: term.toLowerCase())
          .limit(1)
          .get();

      if (exactUsernameQuery.docs.isNotEmpty) {
        return UserModel.fromMap(
          exactUsernameQuery.docs.first.data() as Map<String, dynamic>,
        );
      }

      // Try partial username match (starts with)
      QuerySnapshot partialUsernameQuery = await _firestore
          .collection('users')
          .where('usernameLower', isGreaterThanOrEqualTo: term.toLowerCase())
          .where('usernameLower', isLessThan: '${term.toLowerCase()}\uf8ff')
          .limit(1)
          .get();

      if (partialUsernameQuery.docs.isNotEmpty) {
        return UserModel.fromMap(
          partialUsernameQuery.docs.first.data() as Map<String, dynamic>,
        );
      }

      // Search by phone number (exact match)
      QuerySnapshot phoneQuery = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: term)
          .limit(1)
          .get();

      if (phoneQuery.docs.isNotEmpty) {
        return UserModel.fromMap(
          phoneQuery.docs.first.data() as Map<String, dynamic>,
        );
      }

      return null; // User not found
    } catch (e) {
      debugPrint('Search error: $e');
      return null;
    }
  }
}
