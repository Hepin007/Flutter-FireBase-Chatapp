# Firebase Setup Guide for Beginners

This guide will help you set up Firebase for your chat app step by step.

## Step 1: Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter a project name (e.g., "my-chat-app")
4. Choose whether to enable Google Analytics (optional)
5. Click "Create project"

## Step 2: Install Firebase CLI

1. Install Node.js from [nodejs.org](https://nodejs.org/)
2. Open terminal/command prompt
3. Run this command:
   ```bash
   npm install -g firebase-tools
   ```

## Step 3: Login to Firebase

1. In terminal, run:
   ```bash
   firebase login
   ```
2. Follow the instructions to log in with your Google account

## Step 4: Install FlutterFire CLI

1. In terminal, run:
   ```bash
   dart pub global activate flutterfire_cli
   ```

## Step 5: Configure Firebase in Your Project

1. Navigate to your Flutter project directory:
   ```bash
   cd /path/to/your/chat_app
   ```

2. Run the FlutterFire configure command:
   ```bash
   flutterfire configure --project=YOUR_PROJECT_ID
   ```
   (Replace YOUR_PROJECT_ID with your actual Firebase project ID)

3. Select the platforms you want to support (Android, iOS, Web)
4. This will create the `lib/firebase_options.dart` file

## Step 6: Enable Firebase Services

### Authentication
1. In Firebase Console, go to "Authentication"
2. Click "Get started"
3. Go to "Sign-in method" tab
4. Enable "Email/Password"
5. Click "Save"

### Firestore Database
1. In Firebase Console, go to "Firestore Database"
2. Click "Create database"
3. Choose "Start in test mode" (for development)
4. Select a location close to your users
5. Click "Done"

## Step 7: Set Up Security Rules

1. In Firestore Database, go to "Rules" tab
2. Replace the rules with these:

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

3. Click "Publish"

## Step 8: Update Your Code

1. Uncomment the Firebase initialization in `lib/main.dart`:
   ```dart
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp(
       options: DefaultFirebaseOptions.currentPlatform,
     );
     runApp(const ChatApp());
   }
   ```

2. Add the import for firebase_options.dart:
   ```dart
   import 'firebase_options.dart';
   ```

## Step 9: Test Your Setup

1. Run the app:
   ```bash
   flutter run
   ```

2. Try to register a new user
3. Check Firebase Console to see if the user was created

## Troubleshooting

### Common Issues:

1. **"Firebase not initialized" error**
   - Make sure you uncommented the Firebase.initializeApp() call
   - Check that firebase_options.dart exists

2. **"Permission denied" error**
   - Check your Firestore security rules
   - Make sure Authentication is enabled

3. **"Project not found" error**
   - Verify your project ID is correct
   - Make sure you're logged in to Firebase CLI

4. **"Platform not supported" error**
   - Run `flutterfire configure` again
   - Select the correct platforms

## Next Steps

Once Firebase is set up:
1. Test user registration and login
2. Test sending messages
3. Test user search functionality
4. Test group creation and group chat
5. Test anonymous chat

## Security Notes

- The security rules above are for development
- For production, you should add more specific rules
- Never expose your Firebase API keys in public repositories
- Use environment variables for sensitive data

## Need Help?

- Check [Firebase Documentation](https://firebase.google.com/docs)
- Check [FlutterFire Documentation](https://firebase.flutter.dev/)
- Ask questions on Stack Overflow or Flutter community forums
