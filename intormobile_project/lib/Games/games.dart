import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wedstrijden App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GamesPage(),
    );
  }
}

class GamesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Two tabs: 'Beschikbaar' and 'Jouw Wedstrijd'
      child: Scaffold(
        appBar: AppBar(
          title: Text('Open wedstrijden'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Beschikbaar'),
              Tab(text: 'Jouw Wedstrijd'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            AvailableMatches(),
            YourMatches(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            // TODO: Add functionality to start a match
          },
          label: Text('Een wedstrijd beginnen'),
          icon: Icon(Icons.add),
          backgroundColor: Colors.blue,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}

class AvailableMatches extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return SportFilterDialog();
                    },
                  );
                },
                child: Row(
                  children: [
                    Icon(Icons.filter_list),
                    SizedBox(width: 8),
                    Text('Sport | Plaatsen | Data en...'),
                  ],
                ),
              ),
            ],
          ),
        ),
        Divider(),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Pas filters toe om beschikbare open wedstrijden te kunnen zien',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Icon(Icons.touch_app, size: 48),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class SportFilterDialog extends StatefulWidget {
  @override
  _SportFilterDialogState createState() => _SportFilterDialogState();
}

class _SportFilterDialogState extends State<SportFilterDialog> {
  String? selectedSport = 'Padel';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Welke sport wil je spelen?',
                  style: TextStyle(fontSize: 18),
                ),
                ListTile(
                  title: Text('Padel'),
                  leading: Radio<String>(
                    value: 'Padel',
                    groupValue: selectedSport,
                    onChanged: (String? value) {
                      setState(() {
                        selectedSport = value;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: Text('Tennis'),
                  leading: Radio<String>(
                    value: 'Tennis',
                    groupValue: selectedSport,
                    onChanged: (String? value) {
                      setState(() {
                        selectedSport = value;
                      });
                    },
                  ),
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return SkillLevelDialog();
                      },
                    );
                  },
                  child: Text('Volgende'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 36),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SkillLevelDialog extends StatefulWidget {
  @override
  _SkillLevelDialogState createState() => _SkillLevelDialogState();
}

class _SkillLevelDialogState extends State<SkillLevelDialog> {
  String? selectedLevel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Welk niveau heb je?',
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  'Om je betere resultaten te kunnen bieden, moeten we je niveau kennen',
                  style: TextStyle(color: Colors.grey),
                ),
                ListTile(
                  title: Text('Beginner'),
                  leading: Radio<String>(
                    value: 'Beginner',
                    groupValue: selectedLevel,
                    onChanged: (String? value) {
                      setState(() {
                        selectedLevel = value;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: Text('Medium'),
                  leading: Radio<String>(
                    value: 'Medium',
                    groupValue: selectedLevel,
                    onChanged: (String? value) {
                      setState(() {
                        selectedLevel = value;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: Text('Medium hoog'),
                  leading: Radio<String>(
                    value: 'Medium hoog',
                    groupValue: selectedLevel,
                    onChanged: (String? value) {
                      setState(() {
                        selectedLevel = value;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: Text('Hoog'),
                  leading: Radio<String>(
                    value: 'Hoog',
                    groupValue: selectedLevel,
                    onChanged: (String? value) {
                      setState(() {
                        selectedLevel = value;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: Text('Competitie'),
                  leading: Radio<String>(
                    value: 'Competitie',
                    groupValue: selectedLevel,
                    onChanged: (String? value) {
                      setState(() {
                        selectedLevel = value;
                      });
                    },
                  ),
                ),
                SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    // TODO: Handle "Wil je de volledige test doen?" click
                  },
                  child: Text(
                    'Wil je de volledige test doen?',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return DateSelectionDialog();
                      },
                    );
                  },
                  child: Text('Volgende'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 36),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DateSelectionDialog extends StatefulWidget {
  @override
  _DateSelectionDialogState createState() => _DateSelectionDialogState();
}

class _DateSelectionDialogState extends State<DateSelectionDialog> {
  final List<bool> selectedDays = List<bool>.generate(7, (index) => false);

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('dd MMM');
    final DateFormat dayFormat = DateFormat('E', 'nl_NL');
    final DateTime now = DateTime.now();
    final List<DateTime> dates =
        List<DateTime>.generate(7, (index) => now.add(Duration(days: index)));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.of(context).pop();
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return SkillLevelDialog();
                          },
                        );
                      },
                    ),
                    Text(
                      'Wanneer wil je spelen?',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Selecteer je dagen (max. 7)',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true,
                  itemCount: dates.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                  ),
                  itemBuilder: (context, index) {
                    final date = dates[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDays[index] = !selectedDays[index];
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              selectedDays[index] ? Colors.blue : Colors.white,
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              dayFormat.format(date),
                              style: TextStyle(
                                color: selectedDays[index]
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            Text(
                              dateFormat.format(date),
                              style: TextStyle(
                                color: selectedDays[index]
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Handle the next action after date selection
                  },
                  child: Text('Volgende'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 36),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class YourMatches extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Add your logic here to display user's matches
    return Center(
      child: Text('Jouw Wedstrijden', style: TextStyle(fontSize: 20)),
    );
  }
}
