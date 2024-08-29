import 'package:carpriceprediction/selection_screen.dart';
import 'package:carpriceprediction/userdashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'AdminDashboard.dart';
import 'addcar.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey: "AIzaSyBA4Qqy3c1zggcphmSwKoBdX6qLwG6Jk_Y",
        authDomain: "carpriceprediction-ed6b0.firebaseapp.com",
        projectId: "carpriceprediction-ed6b0",
        storageBucket: "carpriceprediction-ed6b0.appspot.com",
        messagingSenderId: "451634310784",
        appId: "1:451634310784:web:4f57ada2460d11c28b4065",
        measurementId: "G-E65XFNFWTW",
    ),
  );
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Car Price Prediction',
      home: FutureBuilder<Widget>(
        future: _checkUserType(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('Error: ${snapshot.error}')),
            );
          } else {
            return snapshot.data ?? Selection_Screen();
            ;
          }
        },
      ),
    );
  }

  Future<Widget> _checkUserType() async {
    final User? firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      return Selection_Screen();
      ;
    }

    final currentUserId = firebaseUser.uid;

    final adminDoc = await FirebaseFirestore.instance
        .collection('Admin')
        .doc(currentUserId)
        .get();
    if (adminDoc.exists) {
      return Admindashboard();
      ();
    }


    final sellerDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUserId)
        .get();
    if (sellerDoc.exists) {
      return  Userdashboard();
    }

    return Selection_Screen();
    (); // Fallback in case the user is not found in any collection
  }
}
