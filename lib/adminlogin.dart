import 'package:carpriceprediction/sign_in_controller.dart';
import 'package:carpriceprediction/snakbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'AdminDashboard.dart';



class Adminlogin extends StatefulWidget {
  const Adminlogin({super.key});

  @override
  State<Adminlogin> createState() => _AdminloginState();
}

class _AdminloginState extends State<Adminlogin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final SignInController _signInController = SignInController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  void _signIn() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    if (!_validateInputs(email, password)) return;

    setState(() {
      _isLoading = true;
    });

    bool success = await _signInController.signIn(email, password);
    setState(() {
      _isLoading = false;
    });

    if (success) {
      // Get the current user ID
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

      // Check if the user ID exists in the Admin collection
      DocumentSnapshot adminDoc = await FirebaseFirestore.instance.collection('Admin').doc(userId).get();

      if (adminDoc.exists) {
        // If the user is an admin, navigate to the AdminDashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Admindashboard()),
        );
      } else {
        // If the user is not an admin, sign out and show a message
        await FirebaseAuth.instance.signOut();
        SnackbarHelper.show(context, 'You are not an admin');
      }
    } else {
      SnackbarHelper.show(context, 'Sign In Failed');
    }
  }


  bool _validateInputs(String email, String password) {
    if (email.isEmpty || password.isEmpty) {
      SnackbarHelper.show(context, 'All fields are required');
      return false;
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      SnackbarHelper.show(context, 'Invalid email address');
      return false;
    }
    if (password.length < 8) {
      SnackbarHelper.show(context, 'Password must be at least 8 characters');
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          width: 600,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 10),
                  Container(
                    height: 200,
                    width:200,
                    child: Lottie.asset("assets/logomain.json"),
                  ),
                  SizedBox(height: 10),
                  Text(
                      "Car Price Prediction",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text("Admin Login", style: TextStyle(color: Colors.lightBlue),),
                  Container(
                    width: screenWidth * 0.8,
                    child: TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email,color: Colors.green,),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: screenWidth * 0.8,
                    child: TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock,color: Colors.green,),
                        suffixIcon: IconButton(
                          icon: Icon(_isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      obscureText: !_isPasswordVisible,
                    ),
                  ),
                  SizedBox(height: 20),
                  _isLoading
                      ? CircularProgressIndicator()
                      : Container(
                    width: screenWidth * 0.8,
                    child: ElevatedButton(
                      onPressed: _signIn,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Text('Sign In'),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                    ],
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

