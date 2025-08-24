# Simple Chat App with Firebase

A beginner-friendly Flutter chat application with Firebase integration. This app demonstrates basic chat functionality with user authentication, real-time messaging, and multiple chat types.

## Features

- 🔐 **User Authentication**: Login and registration with Firebase Auth
- 👥 **User Search**: Find users by username or phone number
- 💬 **One-on-One Chat**: Private messaging between users
- 👥 **Group Chat**: Create groups and chat with multiple users
- 🕵️ **Anonymous Chat**: Chat anonymously in temporary rooms
- 📱 **Modern UI**: Clean Material Design interface
- 🔄 **Real-time Updates**: Messages appear instantly

## What You'll Learn

This app demonstrates these Flutter and Firebase concepts:

1. **Firebase Authentication** - User login/registration
2. **Cloud Firestore** - Real-time database
3. **State Management** - Using Provider pattern
4. **StreamBuilder** - Real-time data updates
5. **Navigation** - Multiple screens and routing
6. **UI Components** - Forms, lists, and chat bubbles

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   ├── user_model.dart       # User data structure
│   ├── message_model.dart    # Message data structure
│   └── group_model.dart      # Group data structure
├── providers/
│   └── auth_provider.dart    # Authentication state management
├── services/
│   └── firebase_service.dart # Firebase operations
└── screens/
    ├── auth_wrapper.dart     # Authentication routing
    ├── login_screen.dart     # Login screen
    ├── registration_screen.dart # Registration screen
    ├── main_screen.dart      # Main app with tabs
    ├── chats_screen.dart     # Recent conversations
    ├── chat_screen.dart      # Individual chat
    ├── search_screen.dart    # User search
    ├── groups_screen.dart    # Group management
    ├── group_chat_screen.dart # Group chat
    ├── anonymous_chat_screen.dart # Anonymous chat
    ├── anonymous_chat_room_screen.dart # Anonymous chat room
    └── profile_screen.dart   # User profile
```

## Setup Instructions

### 1. Firebase Setup

First, you need to set up Firebase:

1. **Install Firebase CLI**:
   ```bash
   npm install -g firebase-tools
   ```

2. **Login to Firebase**:
   ```bash
   firebase login
   ```

3. **Install FlutterFire CLI**:
   ```bash
   dart pub global activate flutterfire_cli
   ```

4. **Configure Firebase** (run this in your project directory):
   ```bash
   flutterfire configure --project=YOUR_PROJECT_ID
   ```

5. **Enable Firebase Services**:
   - Go to Firebase Console
   - Enable Authentication (Email/Password)
   - Enable Cloud Firestore
   - Set up security rules

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Run the App

```bash
flutter run
```

## How to Use

### Registration
1. Open the app
2. Tap "Register"
3. Fill in your details (name, username, phone, email, password)
4. Tap "Create Account"

### Login
1. Enter your email and password
2. Tap "Login"

### Finding Users
1. Go to the "Search" tab
2. Choose search type (Username or Phone)
3. Enter the username or phone number
4. Tap "Search"
5. Tap "Chat" to start a conversation

### Group Chat
1. Go to the "Groups" tab
2. Tap "Create New Group"
3. Enter group name and add members
4. Tap on a group to start chatting

### Anonymous Chat
1. Go to the "Anonymous" tab
2. Tap "Create New Chat Room" or "Join Random Chat"
3. Share the room ID with others
4. Chat anonymously

## Code Explanation

### Models
- **UserModel**: Stores user information (name, email, phone, etc.)
- **MessageModel**: Stores message data (text, sender, timestamp)
- **GroupModel**: Stores group information (name, members, etc.)

### Providers
- **AuthProvider**: Manages authentication state and user data

### Services
- **FirebaseService**: Handles all Firebase operations (send messages, get data)

### Screens
Each screen is designed to be simple and easy to understand:
- Clear variable names
- Detailed comments
- Simple UI components
- Error handling

## Firebase Collections

The app uses these Firestore collections:
- `users` - User profiles
- `chats` - Individual chat messages
- `groups` - Group information
- `anonymous_chats` - Anonymous chat rooms

## Security Rules

Make sure to set up proper Firestore security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read and write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Users can read other users' data for search
    match /users/{userId} {
      allow read: if request.auth != null;
    }
    
    // Chat messages
    match /chats/{chatId} {
      allow read, write: if request.auth != null;
    }
    
    // Group messages
    match /groups/{groupId} {
      allow read, write: if request.auth != null;
    }
    
    // Anonymous chat messages
    match /anonymous_chats/{chatId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Next Steps

Once you understand this app, you can add:
- Push notifications
- File sharing
- Voice messages
- Video calls
- Message reactions
- User blocking
- Profile pictures
- Dark mode

This app is perfect for Flutter beginners who want to learn Firebase integration and real-time chat functionality!
