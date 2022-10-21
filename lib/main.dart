import 'package:chat_app/screens/add_group_screen.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:chat_app/screens/home_screen.dart';
import 'package:chat_app/screens/login_screen.dart';
import 'package:chat_app/screens/profile_screen.dart';
import 'package:chat_app/values/app_routes.dart';
import 'package:chat_app/values/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: appColorPrimarySwatch,
      ),
      home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, authSnapshot) {
            if (authSnapshot.connectionState == ConnectionState.waiting) {
              return const Text('LOading...');
            } else if (authSnapshot.hasData) {
              return const HomeScreen();
            }
            return const LoginScreen();
          }),
      routes: {
        appRouteHomeScreen: (context) => const HomeScreen(),
        appRouteChatScreen: (context) => const ChatScreen(),
        appRouteProfileScreen: (context) => const ProfileScreen(),
        appRouteAddGroupScreen: (context) => const AddGroupScreen(),
      },
    );
  }
}
