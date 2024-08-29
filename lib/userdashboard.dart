import 'dart:math';
import 'package:carpriceprediction/predictionscreen.dart';
import 'package:carpriceprediction/selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Userdashboard extends StatefulWidget {
  const Userdashboard({super.key});

  @override
  State<Userdashboard> createState() => _UserdashboardState();
}

class _UserdashboardState extends State<Userdashboard> {
  final List<String> _images = [
    'assets/download.jpeg',
    'assets/download1.jpeg',
    'assets/download2.jpeg',
    'assets/download3.jpeg',
    'assets/download4.jpeg',
  ];

  final Random _random = Random();
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";

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
        title: Center(
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchText = value;
              });
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'Search',
              prefixIcon: Icon(Icons.search, color: Colors.blue),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: BorderSide(color: Colors.blue, width: 1.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: BorderSide(color: Colors.blue, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: BorderSide(color: Colors.blue, width: 2.0),
              ),
            ),
          ),
        ),
        backgroundColor: Colors.blue,
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

          final cars = snapshot.data!.docs.where((car) {
            final carData = car.data() as Map<String, dynamic>;
            return carData['Model']
                .toString()
                .toLowerCase()
                .contains(_searchText.toLowerCase());
          }).toList();

          return LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = (constraints.maxWidth / 300).floor(); // Calculate the number of columns

              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 10.0,
                  crossAxisSpacing: 10.0,
                  childAspectRatio: 0.7,
                ),
                itemCount: cars.length,
                itemBuilder: (context, index) {
                  final car = cars[index];
                  final carData = car.data() as Map<String, dynamic>;

                  // Select a random image
                  final randomImage = _images[_random.nextInt(_images.length)];

                  return Card(
                    color: Colors.grey[200],
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            height: 200,
                            child: Image.asset(randomImage), // Display the random image
                          ),
                          ListTile(
                            title: Text('${carData['Make']} ${carData['Model']}'),
                            subtitle: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.lightBlue),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Text(
                                      'Price: ${carData['Price']}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                                Text('Make Year: ${carData['Make_Year']}'),
                                Text('Registered City: ${carData['Registered City']}'),
                                Text('Transmission: ${carData['Transmission']}'),
                                Text('CC: ${carData['CC']}'),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                            onPressed: () async {
                              try {
                                final prediction = await _getPrediction(car.id, carData);
                                print(prediction);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PredictionResultScreen(predictionData: prediction),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error getting prediction: $e')),
                                );
                              }
                            },
                            child: Text(
                              'Predict Price',
                              style: TextStyle(color: Colors.white),
                            ),
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
    );
  }
}
