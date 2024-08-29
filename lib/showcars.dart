import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class Showcars extends StatefulWidget {
  const Showcars({super.key});

  @override
  State<Showcars> createState() => _ShowcarsState();
}

class _ShowcarsState extends State<Showcars> {
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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text('Dashboard'))),
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
                                Text('Price: ${carData['Price']}'),
                                Text('Make Year: ${carData['Make_Year']}'),
                                Text('Registered City: ${carData['Registered City']}'),
                                Text('Transmission: ${carData['Transmission']}'),
                                Text('CC: ${carData['CC']}'),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              try {
                                final prediction = await _getPrediction(car.id, carData);
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Predicted Prices'),
                                    content: Text(prediction.toString()),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error getting prediction: $e')),
                                );
                              }
                            },
                            child: Text('Predict Price'),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {


                                },
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

    );
  }
}
