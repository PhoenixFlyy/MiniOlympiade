import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:winter_olympiade/uploadresults.dart';
import 'package:winter_olympiade/utils/MatchDetails.dart';
import 'package:winter_olympiade/utils/TeamDetails.dart';
import 'package:winter_olympiade/utils/TimerPickerWidget.dart';

import 'Dartsrechner.dart';
import 'Regeln.dart';
import 'Schachuhr.dart';
import 'SchedulePage.dart';
import 'TeamSelection.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  late Timer _timer;
  String match = '';
  String discipline = '';

  int maxtime = 240;
  DateTime? eventStartTime;

  int roundTime = 10;
  final _roundTimeController = TextEditingController();

  int currentRound = 0;

  bool eventStarted = false;
  int selectedTeam = 0;
  String selectedTeamName = "";

  TimeOfDay _eventStartTime = const TimeOfDay(hour: 0, minute: 0);

  late Future<TeamDetails> futureTeamDetails;

  final _maxTimeController = TextEditingController();
  final _eventStartTimeController = TextEditingController();

  List<Break> eventBreaks = [];

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

  Widget getDisciplineImage() {
    switch (discipline) {
      case "1":
        return Image.asset(
          "assets/kicker.png",
          scale: 8,
        );
      case "2":
        return Image.asset(
          "assets/darts.png",
          scale: 2.5,
        );
      case "3":
        return Image.asset(
          "assets/billard.png",
          scale: 8,
        );
      case "4":
        return Image.asset(
          "assets/beerpong.png",
          scale: 2.5,
        );
      case "5":
        return Image.asset(
          "assets/kubb.png",
          scale: 2.5,
        );
      case "6":
        return Image.asset(
          "assets/jenga.png",
          scale: 1,
        );
      default:
        return Image.asset(
          "assets/pokalganz.png",
          scale: 7,
        );
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await _loadSelectedTeam();
      futureTeamDetails = getTeamDetails();

      if (currentRound > 0 && currentRound <= pairings.length) {
        var details = getOpponentAndDiscipline(currentRound, selectedTeam);

        setState(() {
          match =
              'Team $selectedTeam spielt gegen Team ${details.opponent} in Disziplin ${details.discipline}.';
        });
      }
    });

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (mounted) {
          setState(() {
            if (eventStarted) {
              int elapsedSeconds = DateTime.now()
                  .difference(eventStartTime ?? DateTime.now())
                  .inSeconds;
              int newCurrentRound = calculateCurrentRound(elapsedSeconds);

              if (newCurrentRound != currentRound) {
                currentRound = newCurrentRound;
              }

              if (currentRound > 0 && currentRound <= pairings.length) {
                var details =
                    getOpponentAndDiscipline(currentRound, selectedTeam);
                setState(() {
                  match = details.opponent;
                  discipline = '${details.discipline}';
                });
              }
            }
          });
        }
      },
    );
  }

  Future<void> _loadSelectedTeam() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int storedSelectedTeam = prefs.getInt('selectedTeam') ?? 0;
    String storedTeamName = prefs.getString('teamName') ?? "";
    if (mounted) {
      setState(() {
        selectedTeam = storedSelectedTeam;
        selectedTeamName = storedTeamName;
      });
    }
  }

  int calculateCurrentRound(int elapsedSeconds) {
    int pauseTime = 0;
    for (Break eventBreak in eventBreaks) {
      if (elapsedSeconds > eventBreak.roundNumber * roundTime * 60) {
        pauseTime += eventBreak.duration;
      }
    }
    int adjustedElapsed = elapsedSeconds - pauseTime * 60;
    return (adjustedElapsed / (roundTime * 60)).ceil();
  }

  Future<TeamDetails> getTeamDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int storedSelectedTeam = prefs.getInt('selectedTeam') ?? 0;
    String opponent = prefs.getString('opponent') ?? '';
    int round = prefs.getInt('round') ?? 0;
    int discipline = prefs.getInt('discipline') ?? 0;

    return TeamDetails(
      selectedTeam: storedSelectedTeam,
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
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int elapsedSeconds =
        DateTime.now().difference(eventStartTime ?? DateTime.now()).inSeconds;
    int currentRound = calculateCurrentRound(elapsedSeconds);

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
    if (currentRound > 0 && currentRound <= pairings.length) {
      List<String> roundPairings = pairings[currentRound - 1];
      for (String pairing in roundPairings) {
        List<String> teams = pairing.split('-');
        match = pairing;
      }
    }

    String appBarTitle = 'Olympiade';
    appBarTitle += ' - Team $selectedTeam';
    if (selectedTeamName.isNotEmpty) {
      appBarTitle += ' - $selectedTeamName';
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black12,
        title: Text(appBarTitle, style: const TextStyle(fontSize: 20)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: ConstrainedBox(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.circle),
                          Text(' Runde $currentRound',
                              style: const TextStyle(fontSize: 18)),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.timer),
                          Text(' Zeit: $remainingTimeInCurrentRound',
                              style: const TextStyle(fontSize: 18)),
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.people),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              ' Matchup: Teams $match in Disziplin $discipline: ${disciplines[discipline]}, Team ${match.split("-")[0]} beginnt',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Column(
                        children: [
                          SizedBox(
                              width: MediaQuery.of(context).size.width / 2,
                              child: Text("test")),
                          Text("test"),
                        ],
                      ),
                      getDisciplineImage()
                    ],
                  )
                ],
              ),
              Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.tonal(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => UploadResults(
                                    currentRound: currentRound,
                                    teamNumber: selectedTeam)));
                      },
                      child: Text('Ergebnisse eintragen'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height / 12,
                      width: double.infinity,
                      child: FilledButton.tonal(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const DartsRechner()));
                        },
                        child: const Text(
                          'Dartsrechner',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height / 12,
                      width: double.infinity,
                      child: FilledButton.tonal(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16.0),
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SchachUhr(
                                        maxtime: maxtime,
                                      )));
                        },
                        child: const Text(
                          'Schachuhr',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(16.0),
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => RulesScreen()));
                            },
                            child: const Text(
                              'Regeln',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(16.0),
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
                            child: const Text(
                              'Laufplan',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  OutlinedButton(
                    onPressed: () {
                      _startEvent();
                    },
                    child: Text(eventStarted
                        ? 'Das Event ist im Gange...'
                        : 'Event Starten'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openSettings() {
    _maxTimeController.text = maxtime.toString();
    _roundTimeController.text = roundTime.toString();
    final _breakRoundController = TextEditingController();
    final _breakDurationController = TextEditingController();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _maxTimeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: "Schachuhr Zeit in Sekunden"),
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
                      const InputDecoration(labelText: "Rundenzeit in Minuten"),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) {
                    setState(() {
                      roundTime = int.tryParse(value) ?? roundTime;
                    });
                  },
                ),
                TextField(
                  controller: _breakRoundController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Pausenrunde"),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                TextField(
                  controller: _breakDurationController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: "Pausendauer in Minuten"),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                ElevatedButton(
                  onPressed: () {
                    int? round = int.tryParse(_breakRoundController.text);
                    int? duration = int.tryParse(_breakDurationController.text);
                    if (round != null && duration != null) {
                      eventBreaks
                          .add(Break(roundNumber: round, duration: duration));
                      _breakRoundController.clear();
                      _breakDurationController.clear();
                    }
                  },
                  child: const Text("Pause hinzufügen"),
                ),
                const SizedBox(height: 16.0),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const TeamSelection(),
                      ),
                      (route) => false,
                    );
                  },
                  child: const Text('Teamauswahl'),
                ),
                const SizedBox(height: 16.0),
                TimePickerWidget(
                  initialTime: _eventStartTime,
                  onTimeSelected: (selectedTime) {
                    setState(() {
                      _eventStartTime = selectedTime;
                    });
                  },
                ),
                const SizedBox(height: 16.0),
                Text('Pausenkonfiguration',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: eventBreaks.length,
                  itemBuilder: (context, index) {
                    return Row(
                      children: [
                        Expanded(
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                eventBreaks[index].roundNumber =
                                    int.tryParse(value) ??
                                        eventBreaks[index].roundNumber;
                              });
                            },
                            decoration: const InputDecoration(
                                labelText: "Nach welcher Runde"),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                eventBreaks[index].duration =
                                    int.tryParse(value) ??
                                        eventBreaks[index].duration;
                              });
                            },
                            decoration: const InputDecoration(
                                labelText: "Dauer in Minuten"),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
