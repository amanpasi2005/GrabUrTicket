import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminChartsScreen extends StatelessWidget {
  const AdminChartsScreen({super.key});

  Future<Map<String, int>> _loadShowtimeData() async {
    final snap =
    await FirebaseFirestore.instance.collection('bookings').get();

    Map<String, int> data = {};

    for (var doc in snap.docs) {
      final booking = doc.data();
      final String time = booking['showTime'] ?? 'Unknown';

      data[time] = (data[time] ?? 0) + 1;
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text("Analytics Charts"),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<Map<String, int>>(
        future: _loadShowtimeData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          if (data.isEmpty) {
            return const Center(child: Text("No booking data"));
          }

          final keys = data.keys.toList();
          final values = data.values.toList();

          return Padding(
            padding: const EdgeInsets.all(16),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (values.reduce((a, b) => a > b ? a : b)).toDouble() + 2,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < keys.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              keys[index],
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(
                  keys.length,
                      (index) => BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: values[index].toDouble(),
                        color: Colors.deepOrange,
                        width: 18,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
