import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:intormobile_project/pages/game_start.dart';

class GamesPage extends StatefulWidget {
  @override
  _GamesPageState createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  User? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
  }

  void joinMatch(DocumentSnapshot match, int slotIndex) async {
    var matchData = match.data() as Map<String, dynamic>;
    List<dynamic> players = matchData['Players'];

    // Retrieve the current user's data from the users collection
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser?.uid)
        .get();
    var userData = userDoc.data() as Map<String, dynamic>;

    players[slotIndex]['name'] = userData['name'] ?? 'Unknown';
    players[slotIndex]['imageUrl'] = userData['img_url'] ?? '';

    await FirebaseFirestore.instance
        .collection('matches')
        .doc(match.id)
        .update({'Players': players});

    setState(() {}); // Refresh the UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('               Matches'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('matches').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              var matches = snapshot.data!.docs;

              return SingleChildScrollView(
                child: Column(
                  children: matches.map((match) {
                    var matchData = match.data() as Map<String, dynamic>;
                    List<dynamic> players = matchData['Players'];

                    List<DateTime> selectedDays = [];
                    if (matchData['selectedDays'] != null) {
                      selectedDays = (matchData['selectedDays'] as List)
                          .map((day) => DateFormat('yyyy-MM-dd').parse(day))
                          .toList();
                    }

                    String selectedTime =
                        matchData['selectedTime'] ?? 'No time selected';

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('courts')
                          .doc(matchData['courtId'])
                          .get(),
                      builder: (context, courtSnapshot) {
                        if (!courtSnapshot.hasData) {
                          return CircularProgressIndicator();
                        }

                        var courtData =
                            courtSnapshot.data!.data() as Map<String, dynamic>;
                        String courtImgUrl = courtData['img_url'] ?? '';

                        return Card(
                          margin: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          child: Column(
                            children: [
                              if (courtImgUrl.isNotEmpty)
                                Image.network(
                                  courtImgUrl,
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Center(child: Icon(Icons.image)),
                                ),
                              ListTile(
                                title: Text(matchData['keuzeSport'] ?? 'Sport'),
                                subtitle: Text(matchData['level'] ?? 'Level'),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children:
                                      players.asMap().entries.map((entry) {
                                    int idx = entry.key;
                                    var player = entry.value;

                                    return Expanded(
                                      child: Column(
                                        children: [
                                          GestureDetector(
                                            onTap: player['name'].isEmpty
                                                ? () {
                                                    joinMatch(match, idx);
                                                  }
                                                : null,
                                            child: CircleAvatar(
                                              radius: 30,
                                              backgroundColor: Colors.white,
                                              backgroundImage:
                                                  player['imageUrl'].isNotEmpty
                                                      ? NetworkImage(
                                                          player['imageUrl'])
                                                      : null,
                                              child: player['imageUrl'].isEmpty
                                                  ? Icon(
                                                      Icons.add,
                                                      size: 30,
                                                      color: Colors.black,
                                                    )
                                                  : null,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            player['name'].isEmpty
                                                ? 'Available'
                                                : player['name'],
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today, size: 16),
                                        SizedBox(width: 5),
                                        Text(
                                          selectedDays.isNotEmpty
                                              ? DateFormat('dd MMM yyyy')
                                                  .format(selectedDays[0])
                                              : 'No date selected',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Icon(Icons.access_time, size: 16),
                                        SizedBox(width: 5),
                                        Text(
                                          selectedTime,
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10),
                            ],
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              );
            },
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => GameStartPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: Text(
                'Start a match',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
