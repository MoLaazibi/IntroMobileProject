import 'community.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    CommunityPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                      context),
                  _buildFeatureCard(
                      'Play an open match',
                      'If you are looking for players at your level',
                      Icons.sports_tennis,
                      context),
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
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    _buildClubCard(
                        'Padel 4U2 Gent',
                        'Gent',
                        'https://padel4u2.weebly.com/uploads/1/2/6/8/126890432/105581875-3056729781048183-5951190146469912291-o_orig.jpg',
                        context),
                    _buildClubCard(
                        'Padelland',
                        'Linkeroever',
                        'https://lh3.googleusercontent.com/p/AF1QipMrb6Hv5TM8diZHDHXZJlTcpOxHVtZg27lJuPqw=s1360-w1360-h1020-rw',
                        context),
                    _buildClubCard(
                        'Ter Eiken',
                        'Edegem',
                        'https://static.wixstatic.com/media/f5002f_66a73f90dfb14e448c3a96484f31b98f~mv2.jpg/v1/fill/w_456,h_350,al_c,q_80,usm_0.66_1.00_0.01,enc_auto/DJI_0106.jpg',
                        context), // New club card added here
                    // Add more club cards here
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
      String title, String subtitle, IconData icon, BuildContext context) {
    return InkWell(
      onTap: () {
        // Action when feature card is tapped
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

  Widget _buildClubCard(
      String name, String location, String imageUrl, BuildContext context) {
    return InkWell(
      onTap: () {
        // Action when club card is tapped
        print('$name tapped');
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
}
