import 'dart:convert';
import 'dart:math'; // Import the math package
import 'package:carpriceprediction/selection_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'addcar.dart';

class Admindashboard extends StatefulWidget {
  const Admindashboard({super.key});

  @override
  State<Admindashboard> createState() => _AdmindashboardState();
}

class _AdmindashboardState extends State<Admindashboard> {


  String? _editingCarId; // To keep track of which car is being edited
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _priceController = TextEditingController();
  final _yearController = TextEditingController();
  final _ccController = TextEditingController();
  final _cityController = TextEditingController();
  final _transmissionController = TextEditingController();

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _priceController.dispose();
    _yearController.dispose();
    _ccController.dispose();
    _cityController.dispose();
    _transmissionController.dispose();
    super.dispose();
  }

  void _startEditing(Map<String, dynamic> carData, String carId) {
    setState(() {
      _editingCarId = carId;
      _makeController.text = carData['Make'] ?? '';
      _modelController.text = carData['Model'] ?? '';
      _priceController.text = carData['Price'].toString();
      _yearController.text = carData['Make_Year'].toString();
      _ccController.text = carData['CC'].toString();
      _cityController.text = carData['Registered City'] ?? '';
      _transmissionController.text = carData['Transmission'] ?? '';
    });
  }

  Future<void> _updateCar(String carId) async {
    try {
      await FirebaseFirestore.instance.collection('Cars').doc(carId).update({
        'Make': _makeController.text,
        'Model': _modelController.text,
        'Price': double.tryParse(_priceController.text) ?? 0,
        'Make_Year': int.tryParse(_yearController.text) ?? 0,
        'CC': int.tryParse(_ccController.text) ?? 0,
        'Registered City': _cityController.text,
        'Transmission': _transmissionController.text,
      });
      setState(() {
        _editingCarId = null; // Stop editing mode
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Car updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating car: $e')),
      );
    }
  }
  final List<String> _images = [
    'assets/download.jpeg',
    'assets/download1.jpeg',
    'assets/download2.jpeg',
    'assets/download3.jpeg',
    'assets/download4.jpeg',
  ];

  final Random _random = Random();

  Future<Map<String, dynamic>> _getPrediction(String carId, Map<String, dynamic> carData) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/predict'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(carData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get prediction');
    }
  }

  Future<void> _deleteCar(String carId) async {
    try {
      await FirebaseFirestore.instance.collection('Cars').doc(carId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Car deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting car: $e')),
      );
    }
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Selection_Screen()), // Replace with your selection screen
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Dashboard')),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Cars').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final cars = snapshot.data!.docs;

          return LayoutBuilder(
            builder: (context, constraints) {
              // Calculate the number of columns based on screen width
              int crossAxisCount = (constraints.maxWidth / 300).floor(); // 200 is the approximate width of a card

              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 10.0,
                  crossAxisSpacing: 10.0,
                  childAspectRatio: 0.7, // Adjust the aspect ratio as needed
                ),
                itemCount: cars.length,
                itemBuilder: (context, index) {
                  final car = cars[index];
                  final carData = car.data() as Map<String, dynamic>;

                  final randomImage = _images[_random.nextInt(_images.length)];

                  bool isEditing = _editingCarId == car.id;

                  return Card(
                    color: Colors.grey[200],
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            height: 200,
                            child: Image.asset(randomImage),
                          ),
                          if (isEditing)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  _buildTextField(_makeController, 'Make'),
                                  _buildTextField(_modelController, 'Model'),
                                  _buildTextField(_priceController, 'Price', isNumeric: true),
                                  _buildTextField(_yearController, 'Year', isNumeric: true),
                                  _buildTextField(_ccController, 'CC', isNumeric: true),
                                  _buildTextField(_cityController, 'Registered City'),
                                  _buildTextField(_transmissionController, 'Transmission'),
                                  ElevatedButton(
                                    onPressed: () => _updateCar(car.id),
                                    child: Text('Update'),
                                  ),
                                ],
                              ),
                            )
                          else
                            ListTile(
                              title: Text('${carData['Make']} ${carData['Model']}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Price: ${carData['Price']}'),
                                  Text('Make Year: ${carData['Make_Year']}'),
                                  Text('Registered City: ${carData['Registered City']}'),
                                  Text('Transmission: ${carData['Transmission']}'),
                                  Text('CC: ${carData['CC']}'),
                                ],
                              ),
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _startEditing(carData, car.id),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteCar(car.id),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },

              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the AddCars page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CarUploadPage()),
          );
        },
        backgroundColor: Colors.green, // Green color
        child: Icon(Icons.add, color: Colors.white), // White plus icon
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      ),
    );
  }

}
