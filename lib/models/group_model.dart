// Simple Group Model - Easy to understand for beginners
class GroupModel {
  final String groupId;       // Unique group ID
  final String groupName;     // Name of the group
  final String createdBy;     // Who created the group
  final List<String> members; // List of member user IDs
  final DateTime createdAt;   // When was group created

  // Constructor - this creates a new group
  GroupModel({
    required this.groupId,
    required this.groupName,
    required this.createdBy,
    required this.members,
    required this.createdAt,
  });

  // Convert group data to a map (for saving to Firebase)
  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'groupName': groupName,
      'createdBy': createdBy,
      'members': members,
      'createdAt': createdAt,
    };
  }

  // Create a group from a map (for reading from Firebase)
  factory GroupModel.fromMap(Map<String, dynamic> map) {
    return GroupModel(
      groupId: map['groupId'] ?? '',
      groupName: map['groupName'] ?? '',
      createdBy: map['createdBy'] ?? '',
      members: List<String>.from(map['members'] ?? []),
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
    );
  }
}
