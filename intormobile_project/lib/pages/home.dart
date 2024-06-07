import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intormobile_project/pages/community.dart';
import 'package:intormobile_project/pages/profile.dart';
import 'court_detail.dart';

class HomePage extends StatefulWidget {
  final User currentUser;

  HomePage({required this.currentUser});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentUser.uid)
        .get();
    setState(() {
      userData = userDoc.data() as Map<String, dynamic>?;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (userData == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    List<Widget> _widgetOptions = <Widget>[
      HomeScreen(),
      CommunityPage(),
      ProfilePage(userData: userData!),
    ];

    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final CollectionReference courts =
      FirebaseFirestore.instance.collection('courts');

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
                'Find your perfect match',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: <Widget>[
                  _buildFeatureCard(
                      'Book a court',
                      'If you already know who you are playing with',
                      Icons.search,
                      context,
                      navUrl: "/court_search"),
                  _buildFeatureCard(
                      'Play an open match',
                      'If you are looking for players at your level',
                      Icons.sports_tennis,
                      context,
                      navUrl: "/games"),
                  _buildFeatureCard(
                      'Classes',
                      'Find classes to improve your game',
                      Icons.school,
                      context),
                  _buildFeatureCard('Competitions', 'Join a competition',
                      Icons.shield, context),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Your clubs',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              SizedBox(
                height: 150,
                child: StreamBuilder<QuerySnapshot>(
                  stream: courts.snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Something went wrong');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    return ListView(
                      scrollDirection: Axis.horizontal,
                      children:
                          snapshot.data!.docs.map((DocumentSnapshot document) {
                        Map<String, dynamic> data =
                            document.data()! as Map<String, dynamic>;
                        String name = data['name'] ?? 'Unknown';
                        String location = data['location'] ?? 'Unknown';
                        String imgUrl = data['img_url'] ?? '';
                        return _buildClubCard(
                            name, location, imgUrl, context, document);
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

  Widget _buildFeatureCard(
      String title, String subtitle, IconData icon, BuildContext context,
      {String navUrl = ""}) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, navUrl, arguments: {
          'currentUser': FirebaseAuth.instance.currentUser,
        });
        print('$title tapped');
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 48),
              SizedBox(height: 10),
              Text(title,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              SizedBox(height: 10),
              Text(subtitle,
                  style: TextStyle(fontSize: 11), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClubCard(String name, String location, String imageUrl,
      BuildContext context, DocumentSnapshot document) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourtDetailPage(
              name: name,
              location: location,
              imageUrl: imageUrl,
              description: _getDescription(name),
              court: document,
              currentUser: FirebaseAuth.instance.currentUser!,
            ),
          ),
        );
      },
      child: Card(
        child: Container(
          width: 150, // Verhoogde breedte
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: ClipRect(
                  child: Image.network(
                    imageUrl,
                    width: 200,
                    height: 200, // Verhoogde hoogte
                    fit: BoxFit.fill,
                    errorBuilder: (BuildContext context, Object exception,
                        StackTrace? stackTrace) {
                      return Center(
                          child: Text('Exception: Invalid image data'));
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(9.0),
                child: Text(
                  name,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  location,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDescription(String name) {
    switch (name) {
      case 'Padel De Velden':
        return 'Sfeervolle clubbeleving\n'
            '6 Kwalitatieve panoramische outdoor padel terreinen, open 7/7, 7-23u\n'
            'Rustige groene omgeving in hartje Kempen\n'
            'Lessen, stages en events in samenwerking met Belgium Padel Academy\n'
            'Drankgelegenheid in cafetaria "Den Tennis"\n'
            'Gratis private parking';
      case 'Padel 4U2 Gent':
        return 'Padel 4U2 Gent opende op 1 juli 2012 als eerste padel club in België z\'n deuren. Gedurende de voorbije jaren was het dé plaats bij uitstek waar velen gebeten werden door de padel microbe. Met een mix van initiaties, lessen, leden en ad-hoc spelers, teambuildings en een actieve jeugdwerking is het uitgegroeid tot een bloeiende club waar dagelijks iedereen terecht kan voor een leuke partij padel!';
      case 'Padelland':
        return 'Our Service Is Ace, onze slogan duidt waar Padelland voor staat.\n'
            'In Padelland staat de klant centraal, dit door het hanteren van lagere prijzen, kwaliteitsvolle indoor courts, topcoaches en sfeervolle, goed georganiseerde tornooien.\n'
            'Kom zeker eens langs.\n'
            'Tot snel!';
      case 'Ter Eiken':
        return 'Ter Eiken staat garant voor topklasse op sportief vlak met een ruim assortiment sport- en ontspanningsmogelijkheden voor recreanten en topsporters. Iedereen kan bij ons terecht om in de beste omstandigheden te sporten of te genieten in ons gezellig clubhuis of onze zomerchalet met zonneterras. Wij hebben ook een ruime parking ter beschikking. Kijk gerust eens naar onze foto\'s.';
      default:
        return 'No description available.';
    }
  }
}
