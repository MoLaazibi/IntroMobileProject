import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final Map<String, dynamic> userData;

  ProfilePage({required this.userData});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
          actions: [
            IconButton(
              icon: Icon(Icons.chat_bubble_outline),
              onPressed: () {
                // Handle chat icon press
              },
            ),
            IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                // Handle menu icon press
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(),
              _buildActivitiesAndPostsTabs(),
              _buildActivitiesSection(),
              _buildPlayerPreferences(),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 3, // Set the current index to the profile tab
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.play_arrow),
              label: 'Play',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Discovery',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Community',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          onTap: (index) {
            // Handle bottom navigation tap
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey.shade300,
            child: Text(
              userData['initials'] ?? 'AE',
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userData['name'] ?? 'Ali El Yousfi',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  userData['location'] ?? 'Location not set',
                  style: TextStyle(color: Colors.grey),
                ),
                TextButton(
                  onPressed: () {
                    // Handle location add
                  },
                  child: Text('Add my location'),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle Go Premium button press
            },
            child: Text('Go Premium'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesAndPostsTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TabBar(
        tabs: [
          Tab(text: 'Activities'),
          Tab(text: 'Posts'),
        ],
        indicatorColor: Colors.black,
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey,
      ),
    );
  }

  Widget _buildActivitiesSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatisticsSection(),
          Divider(),
          Row(
            children: [
              _buildActivityChip('Padel', isSelected: true),
              _buildActivityChip('Tennis'),
            ],
          ),
          SizedBox(height: 16),
          _buildActivityLevelCard('Padel', userData['padelLevel'] ?? 0),
          _buildActivityLevelCard('Tennis', userData['tennisLevel'] ?? 0),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatisticItem('Matches', userData['matches'] ?? 0),
          _buildStatisticItem('Followers', userData['followers'] ?? 0),
          _buildStatisticItem('Following', userData['following'] ?? 0),
        ],
      ),
    );
  }

  Widget _buildStatisticItem(String label, int count) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildActivityChip(String activity, {bool isSelected = false}) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(activity),
        selected: isSelected,
        onSelected: (bool selected) {
          // Handle chip selection
        },
        selectedColor: Colors.black,
        backgroundColor: Colors.grey.shade200,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildActivityLevelCard(String activity, int level) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Image.network(
              'https://via.placeholder.com/80',
              width: 80,
              height: 80,
            ),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$activity Level $level',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Level reliability: 0%',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerPreferences() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Player preferences',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          _buildPreferenceTile(
              'Best hand', userData['bestHand'] ?? 'Right-handed'),
          _buildPreferenceTile(
              'Court position', userData['courtPosition'] ?? 'Both sides'),
          _buildPreferenceTile(
              'Match type', userData['matchType'] ?? 'Competitive, Friendly'),
          _buildPreferenceTile(
              'Preferred time to play', userData['preferredTime'] ?? 'Morning'),
        ],
      ),
    );
  }

  Widget _buildPreferenceTile(String title, String value) {
    return ListTile(
      title: Text(title),
      trailing: TextButton(
        onPressed: () {
          // Handle edit preference
        },
        child: Text('Edit', style: TextStyle(color: Colors.blue)),
      ),
      subtitle: Text(value),
    );
  }
}
