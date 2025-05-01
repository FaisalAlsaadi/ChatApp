import 'package:chatapp/auth/login_or_register.dart';
import 'package:chatapp/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If user is logged in
        if (snapshot.hasData) {
          return const HomePage();
        }
        // If user is NOT logged in
        else {
          return const LoginOrRegister();
        }
      },
    );
  }
}