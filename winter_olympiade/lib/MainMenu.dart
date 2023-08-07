import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:winter_olympiade/Dartsrechner.dart';
import 'package:winter_olympiade/Laufplan.dart';
import 'package:winter_olympiade/Regeln.dart';
import 'package:winter_olympiade/Schachuhr.dart';
import 'package:winter_olympiade/TeamSelection.dart';
import 'dart:async';
import 'package:winter_olympiade/main.dart'; //brauchen wir das?
import 'package:winter_olympiade/SchedulePage.dart';

class TeamDetails {
  final String selectedTeam;
  final String opponent;
  final int round;
  final int discipline;

  TeamDetails({
    required this.selectedTeam,
    required this.opponent,
    required this.round,
    required this.discipline,
  });
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkIfTeamSelected(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Center(child: Text('Error'));
        } else {
          final bool teamSelected = snapshot.data ?? false;

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Mini Olympiade',
            theme: ThemeData.dark(
              useMaterial3: true,
            ),
            home: teamSelected ? mainMenu() : TeamSelection(),
          );
        }
      },
    );
  }

  Future<bool> _checkIfTeamSelected() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('selectedTeam');
  }
}

class MatchDetails {
  final String opponent;
  final int discipline;

  MatchDetails({required this.opponent, required this.discipline});
}

class mainMenu extends StatefulWidget {
  const mainMenu({super.key});

  @override
  State<mainMenu> createState() => _mainMenuState();
}

class _mainMenuState extends State<mainMenu> {
  Map<String, String> disciplines = {
    '1': 'Kicker',
    '2': 'Darts',
    '3': 'Billard',
    '4': 'Bierpong',
    '5': 'Kubb',
    '6': 'Jenga',
  };

  late Timer _timer;
  String match = ''; // Hier definiere ich 'match' als Instanzvariable.
  String discipline = '';

  int maxtime = 240;
  DateTime? eventStartTime;

  int roundTime = 10; // Round time in minutes
  final _roundTimeController = TextEditingController();

  bool eventStarted = false;
  String selectedTeam = '';

  TimeOfDay _eventStartTime = TimeOfDay(hour: 0, minute: 0);

  late Future<TeamDetails> futureTeamDetails;

  final _maxTimeController = TextEditingController();
  final _eventStartTimeController = TextEditingController();

  List<List<String>> pairings = [
    // ... Your existing pairings list ...
    ['1-6', '3-4', '2-5', '', '', ''],
    ['', '', '', '4-2', '1-5', '6-3'],
    ['3-2', '6-5', '1-4', '', '', ''],
    ['', '', '', '3-5', '4-6', '2-1'],
    ['5-4', '3-1', '6-2', '', '', ''],
    ['', '', '', '6-1', '3-4', '5-2'],
    ['6-3', '2-4', '5-1', '', '', ''],
    ['', '', '', '2-3', '5-6', '4-1'],
    ['2-1', '5-3', '4-6', '', '', ''],
    ['', '', '', '4-5', '1-3', '2-6'],
    ['5-2', '1-6', '3-4', '', '', ''],
    ['', '', '', '6-3', '2-4', '1-5'],
    ['4-1', '3-2', '5-6', '', '', ''],
    ['', '', '', '1-2', '3-5', '4-6'],
    ['2-6', '5-4', '1-3', '', '', ''],
    ['', '', '', '2-5', '1-6', '3-4'],
    ['1-5', '6-3', '4-2', '', '', ''],
    ['', '', '', '1-4', '2-3', '6-5'],
    ['4-6', '2-1', '3-5', '', '', ''],
    ['', '', '', '6-2', '4-5', '1-3'],
    ['3-4', '5-2', '6-1', '', '', ''],
    ['', '', '', '5-1', '3-6', '2-4'],
    ['6-5', '4-1', '2-3', '', '', ''],
    ['', '', '', '4-6', '1-2', '5-3'],
    ['3-1', '2-6', '4-5', '', '', ''],
    ['', '', '', '3-4', '2-5', '1-6'],
    ['2-4', '1-5', '6-3', '', '', ''],
    ['', '', '', '5-6', '1-4', '3-2'],
    ['5-3', '4-6', '1-2', '', '', ''],
    ['', '', '', '1-3', '2-6', '5-4']
  ];

  MatchDetails getOpponentAndDiscipline(int roundNumber, int teamNumber) {
    for (var discipline = 0;
        discipline < pairings[roundNumber - 1].length;
        discipline++) {
      var teams = pairings[roundNumber - 1][discipline].split('-');
      if (teams.contains(teamNumber.toString())) {
        var opponent =
            (teams[0] == teamNumber.toString()) ? teams[1] : teams[0];
        return MatchDetails(opponent: opponent, discipline: discipline + 1);
      }
    }
    return MatchDetails(opponent: 'None', discipline: 0);
  }

  void main() {
    getOpponentAndDiscipline(3, 4); // Runde und Teamnummer
  }

  void _startEvent() {
    eventStartTime = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      _eventStartTime.hour,
      _eventStartTime.minute,
    );
    setState(() {
      eventStarted = true;
    });
  }

  int currentRound = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      await _loadSelectedTeam();

      if (selectedTeam.isNotEmpty &&
          currentRound > 0 &&
          currentRound <= pairings.length) {
        var details = getOpponentAndDiscipline(
            currentRound, int.parse(selectedTeam.split(' ')[1]));

        if (details.opponent != null) {
          setState(() {
            match =
                'Team ${selectedTeam.split(' ')[1]} spielt gegen Team ${details.opponent} in Disziplin ${details.discipline}.';
          });
        } else {
          setState(() {
            match = 'Das ausgewählte Team spielt in dieser Runde nicht.';
          });
        }
      }
    });

    _timer = Timer.periodic(
      Duration(seconds: 1),
      (timer) {
        if (this.mounted) {
          setState(() {
            if (eventStarted) {
              int elapsedSeconds = DateTime.now()
                  .difference(eventStartTime ?? DateTime.now())
                  .inSeconds;
              int newCurrentRound = (elapsedSeconds / (roundTime * 60)).ceil();

              if (newCurrentRound != currentRound) {
                currentRound = newCurrentRound;
              }

              if (selectedTeam.isNotEmpty &&
                  currentRound > 0 &&
                  currentRound <= pairings.length) {
                var details = getOpponentAndDiscipline(
                    currentRound, int.parse(selectedTeam.split(' ')[1]));
                setState(() {
                  match = '${details.opponent}';
                  discipline = '${details.discipline}';
                });
              }
            }
          });
        }
      },
    );

    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      await _loadSelectedTeam();
      futureTeamDetails = getTeamDetails();
    });
  }

  Future<void> _loadSelectedTeam() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storedSelectedTeam = prefs.getString('selectedTeam') ?? '';
    if (this.mounted) {
      setState(() {
        selectedTeam = storedSelectedTeam;
      });
    }
  }

  Future<TeamDetails> getTeamDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String selectedTeam = prefs.getString('selectedTeam') ?? '';
    String opponent = prefs.getString('opponent') ?? '';
    int round = prefs.getInt('round') ?? 0;
    int discipline = prefs.getInt('discipline') ?? 0;

    return TeamDetails(
      selectedTeam: selectedTeam,
      opponent: opponent,
      round: round,
      discipline: discipline,
    );
  }

  @override
  void dispose() {
    _maxTimeController.dispose();
    _roundTimeController.dispose();
    _eventStartTimeController.dispose();
    _timer.cancel(); // Cancel the timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate current round
    int elapsedSeconds =
        DateTime.now().difference(eventStartTime ?? DateTime.now()).inSeconds;
    int currentRound = (elapsedSeconds / (roundTime * 60)).ceil();

    // Calculate remaining time in the current round
    int elapsedSecondsInCurrentRound = elapsedSeconds % (roundTime * 60);
    int remainingSecondsInCurrentRound =
        roundTime * 60 - elapsedSecondsInCurrentRound;

    String remainingTimeInCurrentRound =
        Duration(seconds: remainingSecondsInCurrentRound)
            .toString()
            .split('.')
            .first
            .padLeft(8, "0");

    // Determine team's match
    String match = '';
    if (selectedTeam.isNotEmpty &&
        currentRound > 0 &&
        currentRound <= pairings.length) {
      List<String> roundPairings = pairings[currentRound - 1];
      for (String pairing in roundPairings) {
        List<String> teams = pairing.split('-');
        if (teams.contains(selectedTeam.split(' ')[1])) {
          match = pairing;
          break;
        }
      }
    }

    String appBarTitle = 'Olympiade';
    if (selectedTeam.isNotEmpty) {
      appBarTitle += ' - $selectedTeam';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              _openSettings();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.circle),
                  SizedBox(width: 8.0),
                  Text('Runde $currentRound'),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.timer),
                  SizedBox(width: 8.0),
                  Text('Zeit: $remainingTimeInCurrentRound'),
                ],
              ),
            ],
          ),
          SizedBox(height: 8.0), // This adds a space between the rows
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.people),
              SizedBox(width: 8.0),
              Flexible(
                // Using a Flexible widget to avoid overflow
                child: Text(
                  'Matchup: Teams $match in Disziplin $discipline: ${disciplines[discipline]}, Team ${match.split("-")[0]} beginnt',
                ),
              ),
            ],
          ),
          Spacer(),
          Container(
            height: MediaQuery.of(context).size.height / 12,
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(16.0),
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => DartsRechner()));
              },
              child: Text(
                'Dartsrechner',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
          SizedBox(height: 16.0),
          Container(
            height: MediaQuery.of(context).size.height / 12,
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(16.0),
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SchachUhr(
                              maxtime: maxtime,
                            )));
              },
              child: Text(
                'Schachuhr',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(16.0),
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RulesScreen()));
                    },
                    child: Text(
                      'Regeln',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(16.0),
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SchedulePage(
                                    pairings: pairings,
                                    disciplines: disciplines,
                                  )));
                    },
                    child: Text(
                      'Laufplan',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              _startEvent();
            },
            child: Text(
                eventStarted ? 'Das Event ist im Gange...' : 'Event Starten'),
          ),
          SizedBox(height: 16.0),
        ],
      ),
    );
  }

  void _openSettings() {
    _maxTimeController.text = maxtime.toString();
    _roundTimeController.text = roundTime.toString();

    // _roundTimeController.text = roundTime.toString(); // ChatGPt ist sich uneins, ob man das hier braucht

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _maxTimeController,
                  keyboardType: TextInputType.number,
                  decoration:
                      InputDecoration(labelText: "Schachuhr Zeit in Sekunden"),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) {
                    setState(() {
                      maxtime = int.tryParse(value) ?? maxtime;
                    });
                  },
                ),
                TextField(
                  // New TextField for round time
                  controller: _roundTimeController,
                  keyboardType: TextInputType.number,
                  decoration:
                      InputDecoration(labelText: "Rundenzeit in Minuten"),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) {
                    setState(() {
                      roundTime = int.tryParse(value) ?? roundTime;
                    });
                  },
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => TeamSelection(),
                    ));
                  },
                  child: Text('Teamauswahl'),
                ),
                SizedBox(height: 16.0),
                TimePickerWidget(
                  initialTime: _eventStartTime,
                  onTimeSelected: (selectedTime) {
                    setState(() {
                      _eventStartTime = selectedTime;
                    });
                  },
                ),
                SizedBox(height: 16.0),
              ],
            ),
          ),
        );
      },
    );
  }
}

class TimePickerWidget extends StatefulWidget {
  final TimeOfDay initialTime;
  final Function(TimeOfDay) onTimeSelected;

  const TimePickerWidget({
    Key? key,
    required this.initialTime,
    required this.onTimeSelected,
  }) : super(key: key);

  @override
  _TimePickerWidgetState createState() => _TimePickerWidgetState();
}

class _TimePickerWidgetState extends State<TimePickerWidget> {
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('Event Startzeit: ${_selectedTime.format(context)}'),
        IconButton(
          icon: Icon(Icons.access_time),
          onPressed: () async {
            final TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: _selectedTime,
            );

            if (pickedTime != null) {
              setState(() {
                _selectedTime = pickedTime;
              });
              widget.onTimeSelected(pickedTime);
            }
          },
        ),
      ],
    );
  }
}
