import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

class GamesPage extends StatefulWidget {
  @override
  _GamesPageState createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  String? selectedSport;
  String? selectedLevel;
  List<DateTime>? selectedDays;
  DocumentSnapshot? selectedCourt;
  String? selectedTime;
  bool noMatchesFound = false;
  List<DocumentSnapshot> matches = [];

  void updateFilters(String? sport, String? level, List<DateTime>? days,
      DocumentSnapshot? court, String? time) {
    setState(() {
      selectedSport = sport;
      selectedLevel = level;
      selectedDays = days;
      selectedCourt = court;
      selectedTime = time;
      noMatchesFound = false; // reset the flag when new filters are applied
    });
    searchMatches();
  }

  void searchMatches() async {
    if (selectedSport != null &&
        selectedLevel != null &&
        selectedCourt != null) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('matches')
          .where('level', isEqualTo: selectedLevel)
          .where('court', isEqualTo: selectedCourt!.reference)
          .get();

      setState(() {
        matches = querySnapshot.docs;
        noMatchesFound = matches.isEmpty;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
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
            AvailableMatches(
              selectedSport: selectedSport,
              selectedLevel: selectedLevel,
              selectedDays: selectedDays,
              selectedCourt: selectedCourt,
              selectedTime: selectedTime,
              noMatchesFound: noMatchesFound,
              matches: matches,
              onFiltersChanged: updateFilters,
            ),
            YourMatches(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return SportFilterDialog(onSelected: updateFilters);
              },
            );
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
  final String? selectedSport;
  final String? selectedLevel;
  final List<DateTime>? selectedDays;
  final DocumentSnapshot? selectedCourt;
  final String? selectedTime;
  final bool noMatchesFound;
  final List<DocumentSnapshot> matches;
  final void Function(
          String?, String?, List<DateTime>?, DocumentSnapshot?, String?)
      onFiltersChanged;

  AvailableMatches({
    required this.selectedSport,
    required this.selectedLevel,
    required this.selectedDays,
    required this.selectedCourt,
    required this.selectedTime,
    required this.noMatchesFound,
    required this.matches,
    required this.onFiltersChanged,
  });

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
                      return SportFilterDialog(onSelected: onFiltersChanged);
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
        if (noMatchesFound)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '❗ Sorry, we hebben geen overeenkomsten gevonden met deze filters, waarom probeer je andere niet?',
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        Expanded(
          child: matches.isEmpty
              ? Center(
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
                )
              : ListView.builder(
                  itemCount: matches.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot match = matches[index];
                    return ListTile(
                      title: Text(match['name']),
                      subtitle: Text('Level: ${match['level']}'),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class SportFilterDialog extends StatefulWidget {
  final void Function(
      String?, String?, List<DateTime>?, DocumentSnapshot?, String?) onSelected;

  SportFilterDialog({required this.onSelected});

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
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    Text(
                      'Welke sport wil je spelen?',
                      style: TextStyle(fontSize: 18),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
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
                  onPressed: selectedSport != null
                      ? () {
                          Navigator.of(context).pop();
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return SkillLevelDialog(
                                selectedSport: selectedSport!,
                                onSelected: widget.onSelected,
                              );
                            },
                          );
                        }
                      : null,
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
  final String selectedSport;
  final void Function(
      String?, String?, List<DateTime>?, DocumentSnapshot?, String?) onSelected;

  SkillLevelDialog({required this.selectedSport, required this.onSelected});

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
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.of(context).pop();
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return SportFilterDialog(
                                onSelected: widget.onSelected);
                          },
                        );
                      },
                    ),
                    Text(
                      'Welk niveau heb je?',
                      style: TextStyle(fontSize: 18),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
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
                  onPressed: selectedLevel != null
                      ? () {
                          Navigator.of(context).pop();
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return DateSelectionDialog(
                                initialSport: widget.selectedSport,
                                initialLevel: selectedLevel!,
                                onSelected: widget.onSelected,
                              );
                            },
                          );
                        }
                      : null,
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
  final String initialSport;
  final String initialLevel;
  final void Function(
      String?, String?, List<DateTime>?, DocumentSnapshot?, String?) onSelected;

  DateSelectionDialog({
    required this.initialSport,
    required this.initialLevel,
    required this.onSelected,
  });

  @override
  _DateSelectionDialogState createState() => _DateSelectionDialogState();
}

class _DateSelectionDialogState extends State<DateSelectionDialog> {
  final List<bool> selectedDays = List<bool>.generate(14, (index) => false);

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('dd MMM');
    final DateFormat dayFormat = DateFormat('E', 'nl_NL');
    final DateTime now = DateTime.now();
    final List<DateTime> dates =
        List<DateTime>.generate(14, (index) => now.add(Duration(days: index)));

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
                            return SkillLevelDialog(
                              selectedSport: widget.initialSport,
                              onSelected: widget.onSelected,
                            );
                          },
                        );
                      },
                    ),
                    Text(
                      'Wanneer wil je spelen?',
                      style: TextStyle(fontSize: 18),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Selecteer je dagen (max. 7)',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 8),
                Container(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: dates.length,
                    itemBuilder: (context, index) {
                      final date = dates[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              if (selectedDays.where((day) => day).length < 7 ||
                                  selectedDays[index]) {
                                selectedDays[index] = !selectedDays[index];
                              }
                            });
                          },
                          child: Container(
                            width: 80,
                            decoration: BoxDecoration(
                              color: selectedDays[index]
                                  ? Colors.blue
                                  : Colors.white,
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
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: selectedDays.contains(true)
                      ? () {
                          Navigator.of(context).pop();
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return LocationSelectionDialog(
                                initialSport: widget.initialSport,
                                initialLevel: widget.initialLevel,
                                selectedDays: selectedDays
                                    .asMap()
                                    .entries
                                    .where((entry) => entry.value)
                                    .map((entry) => dates[entry.key])
                                    .toList(),
                                onSelected: widget.onSelected,
                              );
                            },
                          );
                        }
                      : null,
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

class LocationSelectionDialog extends StatefulWidget {
  final String initialSport;
  final String initialLevel;
  final List<DateTime> selectedDays;
  final void Function(
      String?, String?, List<DateTime>?, DocumentSnapshot?, String?) onSelected;

  LocationSelectionDialog({
    required this.initialSport,
    required this.initialLevel,
    required this.selectedDays,
    required this.onSelected,
  });

  @override
  _LocationSelectionDialogState createState() =>
      _LocationSelectionDialogState();
}

class _LocationSelectionDialogState extends State<LocationSelectionDialog> {
  List<DocumentSnapshot> courts = [];
  List<DocumentSnapshot> filteredCourts = [];
  DocumentSnapshot? selectedCourt;
  double selectedDistance = 15.0;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCourts();
    searchController.addListener(() {
      filterCourts();
    });
  }

  Future<void> fetchCourts() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('courts').get();
    setState(() {
      courts = querySnapshot.docs;
      filteredCourts = courts;
    });
  }

  void filterCourts() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredCourts = courts.where((court) {
        final name = court['name'].toString().toLowerCase();
        final location = court['location'].toString().toLowerCase();
        return name.contains(query) || location.contains(query);
      }).toList();
    });
  }

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
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.of(context).pop();
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return DateSelectionDialog(
                              initialSport: widget.initialSport,
                              initialLevel: widget.initialLevel,
                              onSelected: widget.onSelected,
                            );
                          },
                        );
                      },
                    ),
                    Text(
                      'Waar wil je spelen?',
                      style: TextStyle(fontSize: 18),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                SizedBox(height: 8),
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Zoek op naam of locatie',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: filteredCourts.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot court = filteredCourts[index];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCourt = court;
                          });
                        },
                        child: Container(
                          width: 120,
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: selectedCourt == court
                                  ? Colors.blue
                                  : Colors.grey,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Image.network(
                                  court['img_url'],
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(court['name']),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                CheckboxListTile(
                  title: Text('Recente clubs'),
                  value: false,
                  onChanged: (bool? value) {},
                ),
                CheckboxListTile(
                  title: Text('Favoriete clubs'),
                  value: false,
                  onChanged: (bool? value) {},
                ),
                SizedBox(height: 8),
                Text('Selecteer een afstand'),
                Slider(
                  value: selectedDistance,
                  min: 1,
                  max: 25,
                  divisions: 5,
                  label: '${selectedDistance.round()} km',
                  onChanged: (double value) {
                    setState(() {
                      selectedDistance = value;
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(5, (index) {
                    int value = (index + 1) * 5;
                    return Text('$value');
                  }),
                ),
                ElevatedButton(
                  onPressed: selectedCourt != null
                      ? () {
                          Navigator.of(context).pop();
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return TimeSelectionDialog(
                                initialSport: widget.initialSport,
                                initialLevel: widget.initialLevel,
                                selectedDays: widget.selectedDays,
                                selectedCourt: selectedCourt!,
                                onSelected: widget.onSelected,
                              );
                            },
                          );
                        }
                      : null,
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

class TimeSelectionDialog extends StatefulWidget {
  final String initialSport;
  final String initialLevel;
  final List<DateTime> selectedDays;
  final DocumentSnapshot selectedCourt;
  final void Function(
      String?, String?, List<DateTime>?, DocumentSnapshot?, String?) onSelected;

  TimeSelectionDialog({
    required this.initialSport,
    required this.initialLevel,
    required this.selectedDays,
    required this.selectedCourt,
    required this.onSelected,
  });

  @override
  _TimeSelectionDialogState createState() => _TimeSelectionDialogState();
}

class _TimeSelectionDialogState extends State<TimeSelectionDialog> {
  String? selectedTime;

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
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.of(context).pop();
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return LocationSelectionDialog(
                              initialSport: widget.initialSport,
                              initialLevel: widget.initialLevel,
                              selectedDays: widget.selectedDays,
                              onSelected: widget.onSelected,
                            );
                          },
                        );
                      },
                    ),
                    Text(
                      'Wanneer wil je spelen?',
                      style: TextStyle(fontSize: 18),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Selecteer je tijd',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 8),
                RadioListTile(
                  title: Text('De hele dag'),
                  value: 'De hele dag',
                  groupValue: selectedTime,
                  onChanged: (value) {
                    setState(() {
                      selectedTime = value as String?;
                    });
                  },
                ),
                RadioListTile(
                  title: Text('Ochtend 06:00 - 12:00'),
                  value: 'Ochtend',
                  groupValue: selectedTime,
                  onChanged: (value) {
                    setState(() {
                      selectedTime = value as String?;
                    });
                  },
                ),
                RadioListTile(
                  title: Text('Middag 12:00 - 18:00'),
                  value: 'Middag',
                  groupValue: selectedTime,
                  onChanged: (value) {
                    setState(() {
                      selectedTime = value as String?;
                    });
                  },
                ),
                RadioListTile(
                  title: Text('Avond 18:00 - 24:00'),
                  value: 'Avond',
                  groupValue: selectedTime,
                  onChanged: (value) {
                    setState(() {
                      selectedTime = value as String?;
                    });
                  },
                ),
                RadioListTile(
                  title: Text('Specifieke uren Maximaal 6 uur'),
                  value: 'Specifieke uren',
                  groupValue: selectedTime,
                  onChanged: (value) {
                    setState(() {
                      selectedTime = value as String?;
                    });
                  },
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: selectedTime != null
                      ? () {
                          Navigator.of(context).pop();
                          widget.onSelected(
                            widget.initialSport,
                            widget.initialLevel,
                            widget.selectedDays,
                            widget.selectedCourt,
                            selectedTime,
                          );
                        }
                      : null,
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
