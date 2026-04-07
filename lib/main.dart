import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:graburticket/screens/HomePageScreen.dart';
import 'package:graburticket/model/constants.dart';
import 'package:graburticket/screens/login_page.dart';
import 'package:graburticket/screens/splash_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


Future<void> setupFcm() async {
  final messaging = FirebaseMessaging.instance;

  // Request permissions (important for Android 13+)
  await messaging.requestPermission();

  // Get token
  final token = await messaging.getToken();
  print("FCM TOKEN: $token");

  // Store token in user doc only if logged in
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid != null && token != null) {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set({'fcmToken': token}, SetOptions(merge: true));
  }
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.requestPermission();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grab Ur Ticket',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
      ),

      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },

      home: SplashScreen(),
    );
  }
}

