import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:graburticket/services/user_service.dart';   // <-- ADD THIS
import 'package:graburticket/model/constants.dart';
import 'login_page.dart';
import 'HomePageScreen.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;

  signup() async {
    try {
      setState(() => loading = true);

      // 1️ Create user in Firebase Auth
      UserCredential userCred =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      // 2️ STEP 7 — Save user details using UserService
      await UserService().saveUser(
        userCred.user!.uid,
        name.text.trim(),
        email.text.trim(),
      );

      // 3️ Navigate to Home Page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePageScreen()),
      );
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            const SizedBox(height: 60),
            Text(
              "Create Account",
              style: TextStyle(
                fontFamily: primaryFont,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: darkColor,
              ),
            ),
            const SizedBox(height: 40),

            // Name
            TextField(
              controller: name,
              decoration: InputDecoration(
                labelText: "Full Name",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),

            const SizedBox(height: 20),

            // Email
            TextField(
              controller: email,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),

            const SizedBox(height: 20),

            // Password
            TextField(
              controller: password,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),

            const SizedBox(height: 35),

            // Signup Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : signup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                child: loading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                  "Sign Up",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: primaryFont,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
                child: Text(
                  "Already have an account? Login",
                  style: TextStyle(
                    color: kPrimary,
                    fontFamily: primaryFont,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
