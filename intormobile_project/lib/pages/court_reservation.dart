import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CourtReservationPage extends StatefulWidget {
  final DocumentSnapshot court;
  final User currentUser;

  CourtReservationPage({required this.court, required this.currentUser});

  @override
  _CourtReservationPageState createState() => _CourtReservationPageState();
}

class _CourtReservationPageState extends State<CourtReservationPage> {
  bool showAvailableOnly = false;
  String selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  Map<String, dynamic>? selectedSlot;
  User? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = widget.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    var courtData = widget.court.data() as Map<String, dynamic>;
    var allSlots = _getAllAvailableSlots(courtData['availability']);
    var availableSlots = showAvailableOnly
        ? allSlots.where((slot) => slot['booked'] == false).toList()
        : allSlots;

    return Scaffold(
      appBar: AppBar(
        title: Text(courtData['name']),
      ),
      body: SingleChildScrollView(
        child: Column(
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
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Price: €${courtData['price'].toString()} per 30 min',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            _buildDateSelector(courtData['availability']),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Show available slots only'),
                  FlutterSwitch(
                    width: 55.0,
                    height: 25.0,
                    valueFontSize: 12.0,
                    toggleSize: 18.0,
                    value: showAvailableOnly,
                    onToggle: (val) {
                      setState(() {
                        showAvailableOnly = val;
                      });
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(1.0, 0.0),
                      end: Offset(0.0, 0.0),
                    ).animate(animation),
                    child: child,
                  );
                },
                child: Wrap(
                  key: ValueKey<String>(selectedDate),
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: availableSlots.map<Widget>((slot) {
                    bool isSelected = selectedSlot == slot;
                    return Container(
                      width: 80,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () {
                          if (slot['booked']) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Slot already booked!'),
                            ));
                            setState(() {
                              selectedSlot = null;
                            });
                          } else {
                            setState(() {
                              selectedSlot = slot;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: slot['booked']
                              ? Colors.grey
                              : isSelected
                                  ? Colors.blue
                                  : Colors.white,
                          foregroundColor:
                              isSelected ? Colors.white : Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: BorderSide(
                            color: isSelected ? Colors.blue : Colors.grey,
                          ),
                        ),
                        child: Text(
                          slot['start'],
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            if (selectedSlot != null && !selectedSlot!['booked'])
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _bookSlot(selectedSlot!);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: Text(
                      'Book for €${courtData['price']}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector(Map<String, dynamic> availability) {
    List<String> dates = availability.keys.toList();
    dates.sort();

    DateTime today = DateTime.now();
    dates = dates.where((date) {
      DateTime dateTime = DateTime.parse(date);
      return dateTime.isAtSameMomentAs(today) ||
          dateTime.isAfter(today) ||
          dateTime.difference(today).inDays == 0;
    }).toList();

    return Container(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        itemBuilder: (context, index) {
          String date = dates[index];
          DateTime dateTime = DateTime.parse(date);
          bool isSelected = date == selectedDate;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDate = date;
                selectedSlot = null; // Reset selected slot when changing date
              });
            },
            child: Container(
              width: 70,
              margin: EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(dateTime).toUpperCase(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    dateTime.day.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    DateFormat('MMM').format(dateTime),
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> _getAllAvailableSlots(
      Map<String, dynamic> availability) {
    List<Map<String, dynamic>> availableSlots = [];
    if (availability.containsKey(selectedDate)) {
      DateTime now = DateTime.now();
      DateTime selectedDateTime = DateTime.parse(selectedDate);
      for (var slot in availability[selectedDate]) {
        DateTime slotTime = DateFormat('HH:mm').parse(slot['start']);
        DateTime slotDateTime = DateTime(
          selectedDateTime.year,
          selectedDateTime.month,
          selectedDateTime.day,
          slotTime.hour,
          slotTime.minute,
        );
        if (selectedDateTime.isAfter(now) || slotDateTime.isAfter(now)) {
          availableSlots.add(slot);
        }
      }
    }
    return availableSlots;
  }

  void _bookSlot(Map<String, dynamic> slot) async {
    var courtData = widget.court.data() as Map<String, dynamic>;
    String courtId = widget.court.id;
    String userId = currentUser!.uid;
    String userName = currentUser!.displayName ?? 'Unknown';

    await FirebaseFirestore.instance.collection('reservations').add({
      'courtId': courtId,
      'courtName': courtData['name'],
      'userId': userId,
      'userName': userName,
      'date': selectedDate,
      'startTime': slot['start'],
      'endTime': slot['end'],
      'price': courtData['price'],
      'status': 'booked',
    });

    // Update the slot to booked
    var availability = courtData['availability'];
    availability[selectedDate] = (availability[selectedDate] as List)
        .map((s) => s['start'] == slot['start'] ? {...s, 'booked': true} : s)
        .toList();

    await FirebaseFirestore.instance
        .collection('courts')
        .doc(courtId)
        .update({'availability': availability});

    setState(() {
      selectedSlot = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Slot booked successfully!')),
    );
  }
}
