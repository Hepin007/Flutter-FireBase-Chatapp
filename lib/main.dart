import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'providers/auth_provider.dart';
import 'providers/notification_provider.dart';
import 'screens/auth_wrapper.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ChatApp());
}

class ChatApp extends StatefulWidget {
  const ChatApp({super.key});

  @override
  State<ChatApp> createState() => _ChatAppState();
}

class _ChatAppState extends State<ChatApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    
    switch (state) {
      case AppLifecycleState.resumed:
        // App is in foreground
        authProvider.setUserOnline();
        // Refresh notification counts when app comes to foreground
        notificationProvider.refreshUnreadCounts();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        // App is in background or terminated
        authProvider.setUserOffline();
        break;
      case AppLifecycleState.inactive:
        // App is inactive (e.g., phone call)
        break;
      case AppLifecycleState.hidden:
        // App is hidden
        authProvider.setUserOffline();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        title: 'Chat App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6750A4),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}
