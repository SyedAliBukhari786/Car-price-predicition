import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CarListPage extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Car List')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Cars').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final cars = snapshot.data!.docs;

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            itemCount: cars.length,
            itemBuilder: (context, index) {
              final car = cars[index];
              final carData = car.data() as Map<String, dynamic>;

              return Card(
                child: Column(
                  children: [
                    ListTile(
                      title: Text('${carData['Make']} ${carData['Model']}'),
                      subtitle: Text('Price: ${carData['Price']}'),
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
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
