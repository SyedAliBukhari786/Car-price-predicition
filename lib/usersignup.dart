import 'package:carpriceprediction/userdashboard.dart';
import 'package:carpriceprediction/userlogin.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class Usersignup extends StatefulWidget {
  const Usersignup({super.key});

  @override
  State<Usersignup> createState() => _UsersignupState();
}

class _UsersignupState extends State<Usersignup> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  // Default city



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center, // Center the column horizontally
              children: [
                Container(
                  height: 200,
                  width: 200,
                  child: Lottie.asset("assets/logomain.json"),
                ),
                Center(
                  child: Text(
                    "Car Price Prediction",
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 25),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 300,
                  child: _buildTextField(_usernameController, 'User Name', Icons.person),
                ),
                Container(
                  width: 300,
                  child: _buildTextField(_contactController, 'Contact', Icons.phone, isNumber: true),
                ),

                Container(
                  width: 300,
                  child: _buildTextField(_emailController, 'Email', Icons.email),
                ),
                Container(
                  width: 300,
                  child: _buildTextField(_passwordController, 'Password', Icons.lock, isPassword: true),
                ),
                Container(
                  width: 300,
                  child: _buildTextField(_confirmPasswordController, 'Confirm Password', Icons.lock, isPassword: true),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 300,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    onPressed: _isLoading ? null : _register,
                    child: _isLoading
                        ? CircularProgressIndicator(
                      color: Colors.white,
                    )
                        : const Text('Register', style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?'),
                    TextButton(
                      onPressed: () {
                    Navigator.push(
                        context,
                         MaterialPageRoute(builder: (context) => const Userlogin()),
                 );
                      },
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {bool isPassword = false, bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
        obscureText: isPassword ? !_isPasswordVisible : false,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.green),
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Colors.blue),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Colors.blue),
          ),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          )
              : null,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label cannot be empty';
          }
          if (label == 'Contact' && value.length != 11) {
            return 'Contact must be 11 digits';
          }
          if (label == 'Email' && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
            return 'Enter a valid email';
          }
          if (label == 'Confirm Password' && value != _passwordController.text) {
            return 'Passwords do not match';
          }
          return null;
        },
      ),
    );
  }



  Future<void> _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });
      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        await FirebaseFirestore.instance.collection('Users').doc(userCredential.user?.uid).set({
          'username': _usernameController.text,
          'contact': _contactController.text,
          'email': _emailController.text,

        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Registration Successful'),
            backgroundColor: Colors.green,
          ),
        );
     Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Userdashboard()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to register user: $e')));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
