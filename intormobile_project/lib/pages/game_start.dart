import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class GameStartPage extends StatefulWidget {
  @override
  _GameStartPageState createState() => _GameStartPageState();
}

class _GameStartPageState extends State<GameStartPage> {
  String? selectedSport;
  String? selectedLevel;
  List<DateTime> selectedDays = [];
  String? selectedTime;
  String? selectedCourtId;
  DocumentSnapshot? selectedCourt;
  User? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
  }

  void addGame() async {
    if (selectedCourt != null &&
        selectedSport != null &&
        selectedLevel != null &&
        selectedDays.isNotEmpty &&
        selectedTime != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser?.uid)
          .get();
      var userData = userDoc.data() as Map<String, dynamic>;

      // Add the new match to the matches collection
      await FirebaseFirestore.instance.collection('matches').add({
        'courtId': selectedCourtId,
        'keuzeSport': selectedSport,
        'level': selectedLevel,
        'selectedDays': selectedDays
            .map((day) => DateFormat('yyyy-MM-dd').format(day))
            .toList(),
        'selectedTime': selectedTime,
        'Players': [
          {
            'name': userData['name'] ?? 'Unknown',
            'imageUrl': userData['img_url'] ?? ''
          },
          {'name': '', 'imageUrl': ''},
          {'name': '', 'imageUrl': ''},
          {'name': '', 'imageUrl': ''},
        ],
      });

      // Update the court's availability
      DateTime selectedDate = selectedDays[0];
      String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
      DateTime selectedDateTime = DateFormat.jm()
          .parse(selectedTime!); // Assuming the selectedTime is in AM/PM format

      // Calculate the three time slots to book
      List<String> timeSlots = [
        DateFormat('HH:mm').format(selectedDateTime),
        DateFormat('HH:mm').format(selectedDateTime.add(Duration(minutes: 30))),
        DateFormat('HH:mm').format(selectedDateTime.add(Duration(minutes: 60))),
      ];

      // Fetch the court document and update availability
      DocumentSnapshot courtDoc = await FirebaseFirestore.instance
          .collection('courts')
          .doc(selectedCourtId)
          .get();
      var courtData = courtDoc.data() as Map<String, dynamic>;
      var availability =
          courtData['availability'][formattedDate] as List<dynamic>;

      bool updated = false;
      for (var slot in availability) {
        if (timeSlots.contains(slot['start'])) {
          slot['booked'] = true;
          updated = true;
        }
      }

      if (!updated) {
        print('No matching time slots found to update.');
      } else {
        courtData['availability'][formattedDate] = availability;

        await FirebaseFirestore.instance
            .collection('courts')
            .doc(selectedCourtId)
            .update({'availability': courtData['availability']});
      }

      // Show a Snackbar message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Match successfully added!')),
      );

      // Return to the previous screen after a delay to allow the user to see the Snackbar
      Future.delayed(Duration(seconds: 2), () {
        Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Start a New Match'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Select Court
            FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance.collection('courts').get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }
                var courts = snapshot.data!.docs;
                return DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Select Court'),
                  items: courts.map((court) {
                    return DropdownMenuItem<String>(
                      value: court.id,
                      child: Text(court['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCourtId = value;
                      selectedCourt =
                          courts.firstWhere((court) => court.id == value);
                    });
                  },
                );
              },
            ),
            SizedBox(height: 16),
            // Select Sport
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Select Sport'),
              items: ['Tennis', 'Padel'].map((sport) {
                return DropdownMenuItem(
                  value: sport,
                  child: Text(sport),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedSport = value;
                });
              },
            ),
            SizedBox(height: 16),
            // Select Level
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Select Level'),
              items: ['Hoog', 'Medium hoog', 'Medium', 'Beginner'].map((level) {
                return DropdownMenuItem(
                  value: level,
                  child: Text(level),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedLevel = value;
                });
              },
            ),
            SizedBox(height: 16),
            // Select Date
            ElevatedButton(
              onPressed: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (selectedDate != null) {
                  setState(() {
                    selectedDays = [selectedDate];
                  });
                }
              },
              child: Text('Select Date'),
            ),
            if (selectedDays.isNotEmpty)
              Text(
                'Selected Date: ${DateFormat('dd MMM yyyy').format(selectedDays[0])}',
              ),
            SizedBox(height: 16),
            // Select Time
            ElevatedButton(
              onPressed: () async {
                final timeOfDay = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (timeOfDay != null) {
                  setState(() {
                    selectedTime = timeOfDay.format(context);
                  });
                }
              },
              child: Text('Select Time'),
            ),
            if (selectedTime != null) Text('Selected Time: $selectedTime'),
            Spacer(),
            ElevatedButton(
              onPressed: addGame,
              child: Text('Start Match'),
            ),
          ],
        ),
      ),
    );
  }
}
