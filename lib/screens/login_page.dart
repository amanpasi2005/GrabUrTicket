import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

import 'signup_page.dart';
import 'HomePageScreen.dart';
import '../admin/admin_home_screen.dart';
import 'package:graburticket/model/constants.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();

  bool loading = false;
  bool isAdminLogin = false;

  final LocalAuthentication _auth = LocalAuthentication();


  Future<void> forgotPassword() async {
    if (email.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your email")),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email.text.trim(),
      );

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Password Reset"),
          content: const Text(
            "We have sent a password reset link to your email.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }


  // -----------------------------
  // EMAIL & PASSWORD LOGIN
  // -----------------------------
  Future<void> loginWithEmail() async {
    try {
      setState(() => loading = true);

      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      final uid = cred.user!.uid;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      final role = userDoc.data()?['role'] ?? 'user';

      if (isAdminLogin && role != 'admin') {
        throw Exception("Not an admin account");
      }

      // 🔐 Save for biometrics
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('bio_uid', uid);
      prefs.setString('bio_role', role);
      prefs.setString('bio_email', email.text.trim());
      prefs.setString('bio_password', password.text.trim());

      if (!mounted) return;

      await setupFcm();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
          role == 'admin'
              ? const AdminHomeScreen()
              : const HomePageScreen(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => loading = false);
    }
  }


  // -----------------------------
  // BIOMETRIC LOGIN
  // -----------------------------
  Future<void> loginWithBiometrics() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final supported = await _auth.isDeviceSupported();

      if (!canCheck && !supported) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Biometrics not supported")),
        );
        return;
      }

      final authenticated = await _auth.authenticate(
        localizedReason: 'Authenticate to continue',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      if (!authenticated) return;

      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('bio_email');
      final pass = prefs.getString('bio_password');
      final role = prefs.getString('bio_role');

      if (email == null || pass == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login with email once to enable biometrics")),
        );
        return;
      }

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => role == 'admin'
              ? const AdminHomeScreen()
              : const HomePageScreen(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }



  // -----------------------------
  // UI (FIXED — NO OVERFLOW)
  // -----------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  Text(
                    "Grab Ur Ticket",
                    style: TextStyle(
                      fontFamily: primaryFont,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: darkColor,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Welcome Back!",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade700,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // EMAIL
                  TextField(
                    controller: email,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // PASSWORD
                  TextField(
                    controller: password,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: forgotPassword,
                      child: Text(
                        "Forgot password?",
                        style: TextStyle(
                          color: kPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),


                  const SizedBox(height: 10),

                  // ADMIN TOGGLE
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Login as Admin"),
                    value: isAdminLogin,
                    onChanged: (v) {
                      setState(() => isAdminLogin = v);
                    },
                  ),

                  const SizedBox(height: 20),

                  // LOGIN BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: loading ? null : loginWithEmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        "Login",
                        style: TextStyle(
                            color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // BIOMETRIC
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: loginWithBiometrics,
                      icon: const Icon(Icons.fingerprint),
                      label: const Text("Login with Biometrics"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),


                  // SIGNUP
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignupPage(),
                          ),
                        );
                      },
                      child: Text(
                        "Create new account",
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
          ),
        ),
      ),
    );
  }
}