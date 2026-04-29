import 'package:cepu_app/screens/sign_in_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
      (route) => false,
    );
  }

  String generateAvatarUrl(String? fullName) {
    final formattedName = (fullName ?? "User").trim().replaceAll(' ', '+');
    return "https://ui-avatars.com/api/?name=$formattedName&color=7F9CF5&background=000000";
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Screen"),
        actions: [
          IconButton(
            onPressed: () {
              signOut(context); // FIX
            },
            icon: const Icon(Icons.logout),
            tooltip: "Sign out",
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            generateAvatarUrl(user?.displayName),
            width: 100,
            height: 100,
          ),
          const SizedBox(height: 16.0),
          Text(
            user?.displayName ?? "No Name",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16.0),
          const Center(
            child: Text("You Have Been Signed In!"),
          ),
        ],
      ),
    );
  }
}