import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityPage extends StatelessWidget {
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              'assets/icons/BlackLogo.png',
              height: 35,
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.person_add, color: Colors.black),
                  onPressed: () {
                    // Handle add friend button press
                  },
                ),
                IconButton(
                  icon: Icon(Icons.chat_bubble_outline, color: Colors.black),
                  onPressed: () {
                    // Handle chat button press
                  },
                ),
                IconButton(
                  icon: Icon(Icons.notifications_none, color: Colors.black),
                  onPressed: () {
                    // Handle notification button press
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Suggested for you',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Container(
                height: 200, // Verhoog de hoogte van de container
                child: StreamBuilder<QuerySnapshot>(
                  stream: users.snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Something went wrong');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }

                    return ListView(
                      scrollDirection: Axis.horizontal,
                      children:
                          snapshot.data!.docs.map((DocumentSnapshot document) {
                        Map<String, dynamic> data =
                            document.data()! as Map<String, dynamic>;
                        String name = data['name'] ?? 'Unknown';
                        String imgUrl = data['img_url'] ?? '';
                        return _buildSuggestedCard(
                          name,
                          Icons.person,
                          context,
                          imageUrl: imgUrl,
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestedCard(String title, IconData icon, BuildContext context,
      {String? imageUrl}) {
    return Container(
      width: 150,
      margin: EdgeInsets.only(right: 10),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(
              16.0), // Verhoog de padding binnen de kaarten
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (imageUrl != null && imageUrl.isNotEmpty)
                ClipOval(
                  child: Image.network(
                    imageUrl,
                    height: 65, // Verhoog de hoogte van de afbeelding
                    width: 70,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Icon(icon, size: 50),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(fontSize: 12), // Verhoog de lettergrootte
                textAlign: TextAlign.center,
              ),
              ElevatedButton(
                onPressed: () {},
                child: Text('Follow',
                    style: TextStyle(color: Colors.white, fontSize: 12)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, fixedSize: Size(90, 1)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
