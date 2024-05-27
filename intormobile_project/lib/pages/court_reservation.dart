import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CourtReservationPage extends StatelessWidget {
  final DocumentSnapshot court;

  CourtReservationPage({required this.court});

  @override
  Widget build(BuildContext context) {
    var courtData = court.data() as Map<String, dynamic>;
    var availableSlots = _getAvailableSlots(courtData['availability']);
    return Scaffold(
      appBar: AppBar(
        title: Text(courtData['name']),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            courtData['img_url'],
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                Center(child: Text('Failed to load image')),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              courtData['name'],
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              courtData['location'],
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8.0,
              children: availableSlots.map<Widget>((slot) {
                return Chip(
                  label: Text(slot['start']),
                  onDeleted: () {
                    // Handle reservation logic here
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getAvailableSlots(
      Map<String, dynamic> availability) {
    List<Map<String, dynamic>> availableSlots = [];
    DateTime now = DateTime.now();
    String todayString = DateFormat('yyyy-MM-dd').format(now);
    if (availability.containsKey(todayString)) {
      for (var slot in availability[todayString]) {
        DateTime slotTime = DateFormat('HH:mm').parse(slot['start']);
        if (now.isBefore(DateTime(
            now.year, now.month, now.day, slotTime.hour, slotTime.minute))) {
          availableSlots.add(slot);
        }
      }
    }
    return availableSlots;
  }
}
