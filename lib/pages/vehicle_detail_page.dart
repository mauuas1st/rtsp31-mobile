import 'package:flutter/material.dart';

class VehicleDetailPage extends StatelessWidget {
  final Map<String, dynamic> vehicle;

  const VehicleDetailPage({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Detail Kendaraan")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:
              vehicle.entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    "${e.key.toUpperCase()}: ${e.value}",
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }
}
