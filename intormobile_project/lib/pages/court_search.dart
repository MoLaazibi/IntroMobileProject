import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intormobile_project/pages/court_reservation.dart';

class CourtSearchPage extends StatefulWidget {
  final User currentUser;

  CourtSearchPage({required this.currentUser});

  @override
  _CourtSearchPageState createState() => _CourtSearchPageState();
}

class _CourtSearchPageState extends State<CourtSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final CollectionReference courts =
      FirebaseFirestore.instance.collection('courts');
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _initializeAvailability();
  }

  void _initializeAvailability() async {
    List<Map<String, dynamic>> slots = [];
    for (int i = 10; i < 22; i++) {
      slots.add({
        "start": "${i.toString().padLeft(2, '0')}:00",
        "end": "${i.toString().padLeft(2, '0')}:30",
        "booked": false
      });
      slots.add({
        "start": "${i.toString().padLeft(2, '0')}:30",
        "end": "${(i + 1).toString().padLeft(2, '0')}:00",
        "booked": false
      });
    }

    Map<String, dynamic> availability = {};
    DateTime today = DateTime.now();
    String todayString = DateFormat('yyyy-MM-dd').format(today);

    for (int i = 0; i < 14; i++) {
      DateTime date = today.add(Duration(days: i));
      String dateString = DateFormat('yyyy-MM-dd').format(date);
      availability[dateString] = List.from(slots);
    }

    QuerySnapshot snapshot = await courts.get();
    for (QueryDocumentSnapshot doc in snapshot.docs) {
      var courtData = doc.data() as Map<String, dynamic>;
      if (courtData['availability'] == null ||
          courtData['availability'].isEmpty) {
        await courts.doc(doc.id).update({"availability": availability});
        print("Created new availability for court ${doc.id}");
      } else {
        // Remove past dates except today
        List<String> datesToRemove = [];
        courtData['availability'].forEach((dateString, _) {
          DateTime date = DateTime.parse(dateString);
          if (date.isBefore(today) && dateString != todayString) {
            datesToRemove.add(dateString);
          }
        });

        for (String dateString in datesToRemove) {
          courtData['availability'].remove(dateString);
          print("Removed past date $dateString for court ${doc.id}");
        }

        // Add new future dates up to two weeks
        for (int i = 0; i < 14; i++) {
          DateTime date = today.add(Duration(days: i));
          String dateString = DateFormat('yyyy-MM-dd').format(date);
          if (!courtData['availability'].containsKey(dateString)) {
            courtData['availability'][dateString] = List.from(slots);
            print("Added new date $dateString for court ${doc.id}");
          }
        }

        await courts
            .doc(doc.id)
            .update({"availability": courtData['availability']});
      }
    }
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

  void _navigateToReservationPage(DocumentSnapshot court) {
    Navigator.pushNamed(context, '/court_reservation', arguments: {
      'court': court,
      'currentUser': widget.currentUser,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 30,
            ),
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Around me',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: courts.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          var courtsList = snapshot.data!.docs.where((doc) {
            var courtData = doc.data() as Map<String, dynamic>;
            return courtData['name']
                .toString()
                .toLowerCase()
                .contains(searchQuery);
          }).toList();

          if (courtsList.isEmpty) {
            return Center(child: Text('No courts found'));
          }

          return ListView.builder(
            itemCount: courtsList.length,
            itemBuilder: (context, index) {
              var court = courtsList[index];
              var courtData = court.data() as Map<String, dynamic>;
              var availableSlots =
                  _getAvailableSlots(courtData['availability']);
              return GestureDetector(
                onTap: () => _navigateToReservationPage(court),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Image.network(
                              courtData['img_url'],
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Center(child: Text('Failed to load image')),
                            ),
                            Container(
                              height: 200,
                              width: double.infinity,
                              color: Colors.black.withOpacity(0.3),
                            ),
                            Positioned(
                              bottom: 10,
                              left: 10,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    courtData['name'],
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '€${courtData['price'].toString()} per hour',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            courtData['location'],
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Wrap(
                            spacing: 4.0,
                            runSpacing: 4.0,
                            children:
                                availableSlots.take(5).map<Widget>((slot) {
                              return Chip(
                                label: Text(
                                  slot['start'],
                                  style: TextStyle(fontSize: 12),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 4.0),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
