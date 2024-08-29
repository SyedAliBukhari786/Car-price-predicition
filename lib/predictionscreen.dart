import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PredictionResultScreen extends StatelessWidget {
  final Map<String, dynamic> predictionData;

  const PredictionResultScreen({Key? key, required this.predictionData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prediction Result'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Predicted Prices:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: BarChartWidget(predictionData: predictionData),
            ),
          ],
        ),
      ),
    );
  }
}

class BarChartWidget extends StatelessWidget {
  final Map<String, dynamic> predictionData;

  const BarChartWidget({Key? key, required this.predictionData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<BarChartGroupData> barChartGroups = [];

    // Prepare bar chart data
    predictionData.forEach((key, value) {
      double roundedValue = value.roundToDouble();
      barChartGroups.add(
        BarChartGroupData(
          x: predictionData.keys.toList().indexOf(key),
          barRods: [
            BarChartRodData(
              toY: roundedValue,
              color: Colors.blue,
              width: 20,
              // Show values on top of the bar
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: 0,
                color: Colors.transparent,
              ),
            ),
          ],
          // Add titles (values) on top of the bar
          showingTooltipIndicators: [0],
        ),
      );
    });

    return BarChart(
      BarChartData(
        barGroups: barChartGroups,
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  predictionData.keys.elementAt(value.toInt()),
                  style: TextStyle(fontSize: 12),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(show: false),
        // To show values on top by default
        barTouchData: BarTouchData(
          enabled: false,  // Disable touch to avoid manual interaction
          touchTooltipData: BarTouchTooltipData(
           // tooltipBgColor: Colors.transparent,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                rod.toY.toString(),
                TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
