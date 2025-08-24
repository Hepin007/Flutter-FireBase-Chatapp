// Simple User Model - Easy to understand for beginners
class UserModel {
  final String uid;           // Unique user ID from Firebase
  final String username;      // User's chosen username
  final String email;         // User's email address
  final String phoneNumber;   // User's phone number
  final String fullName;      // User's full name
  final bool isOnline;        // Is user currently online?

  // Constructor - this creates a new user
  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.fullName,
    this.isOnline = false,
  });

  // Convert user data to a map (for saving to Firebase)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'phoneNumber': phoneNumber,
      'fullName': fullName,
      'isOnline': isOnline,
    };
  }

  // Create a user from a map (for reading from Firebase)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      fullName: map['fullName'] ?? '',
      isOnline: map['isOnline'] ?? false,
    );
  }
}
