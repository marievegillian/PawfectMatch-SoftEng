import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pawfectmatch/screens/home_screen.dart';
import 'package:pawfectmatch/screens/login_screen.dart';
// import 'package:pawfectmatch/screens/matching_screen.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) { // bold
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          //User is logged in
          if (snapshot.hasData) {
            return const HomeScreen(); // bold
          }
          //User is NOT logged in
          else {
            return const LoginScreen(); // bold
          }
        },
      ),
    );
  }
}
