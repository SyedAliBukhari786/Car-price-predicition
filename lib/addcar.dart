import 'dart:typed_data'; // For handling image data
import 'dart:html' as html; // Import dart:html for web file picker

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'listcars.dart';

class CarUploadPage extends StatefulWidget {
  @override
  _CarUploadPageState createState() => _CarUploadPageState();
}

class _CarUploadPageState extends State<CarUploadPage> {
  final _formKey = GlobalKey<FormState>();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _versionController = TextEditingController();
  final _priceController = TextEditingController();
  final _yearController = TextEditingController();
  final _ccController = TextEditingController();
  final _assemblyController = TextEditingController();
  final _mileageController = TextEditingController();
  final _cityController = TextEditingController();
  final _transmissionController = TextEditingController();

  Uint8List? _selectedImageBytes; // Holds the selected image data
  String? _selectedImageName; // Holds the selected image name

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _versionController.dispose();
    _priceController.dispose();
    _yearController.dispose();
    _ccController.dispose();
    _mileageController.dispose();
    _cityController.dispose();
    _transmissionController.dispose();
    super.dispose();
  }

  void _pickImage() async {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((event) {
      final file = uploadInput.files?.first;
      if (file != null) {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(file);
        reader.onLoadEnd.listen((event) {
          setState(() {
            _selectedImageBytes = reader.result as Uint8List;
            _selectedImageName = file.name;
          });
        });
      }
    });
  }

  Future<String?> uploadImage(Uint8List imageBytes) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = FirebaseStorage.instance.ref().child('cars/$fileName');
      UploadTask uploadTask = ref.putData(imageBytes);
      TaskSnapshot taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  Future<void> _uploadCar() async {
    if (_formKey.currentState!.validate()) {


      try {


        // Add car data to Firestore
        await FirebaseFirestore.instance.collection('Cars').add({
          'Make': _makeController.text,
          'Model': _modelController.text,
          'Version': _versionController.text,
          'Price': double.parse(_priceController.text),
          'Make_Year': int.parse(_yearController.text),
          'CC': int.parse(_ccController.text),
          'Assembly': _assemblyController.text,
          'Mileage': int.parse(_mileageController.text),
          'Registered City': _cityController.text,
          'Transmission': _transmissionController.text,

        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Car uploaded successfully!')),
        );
      } catch (e) {
        print('Error uploading car: $e'); // Log the error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading car: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Car')),
      body: Center(
        child: Container(
          width: 700,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [


                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(_makeController, 'Make', 'Enter make of the car'),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(_modelController, 'Model', 'Enter model of the car'),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(_versionController, 'Version', 'Enter version of the car'),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(_priceController, 'Price', 'Enter price of the car', isNumeric: true),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(_yearController, 'Year', 'Enter make year', isNumeric: true),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(_ccController, 'CC', 'Enter engine capacity (CC)', isNumeric: true),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(_assemblyController, 'Assembly', 'Enter assembly type (Local/Imported)'),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(_mileageController, 'Mileage', 'Enter mileage', isNumeric: true),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(_cityController, 'Registered City', 'Enter registered city'),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(_transmissionController, 'Transmission', 'Enter transmission type (Automatic/Manual)'),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        onPressed: _uploadCar,
                        child: Text('Upload Car', style: TextStyle(color: Colors.white),),

                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          )
                      ),
                    ),
                    SizedBox(height: 20),

                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, {bool isNumeric = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: Colors.blue,
            width: 2.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: Colors.blue,
            width: 2.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: Colors.blue,
            width: 2.0,
          ),
        ),
      ),
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }
}
