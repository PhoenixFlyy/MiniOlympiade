import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:olympiade/utils/Soundboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ChessClock.dart';
import 'DartCalculator.dart';
import 'ResultScreen.dart';
import 'Rules.dart';
import 'SchedulePage.dart';
import 'TeamSelection.dart';
import 'UploadPointsScreen.dart';
import 'utils/DateTimePicker.dart';
import 'utils/DateTimeUtils.dart';
import 'utils/MatchData.dart';
import 'utils/MatchDetailQueries.dart';
import 'utils/PlaySounds.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  final player = AudioPlayer();
  late Timer _timer;
  String currentMatchUpText = '';
  String nextMatchUpText = '';

  Duration maxChessTime = const Duration(minutes: 4);
  Duration roundTimeDuration = const Duration(minutes: 12);
  Duration playTimeDuration = const Duration(minutes: 10);

  final _roundTimeController = TextEditingController();
  final _playTimeController = TextEditingController();
  final _maxTimeController = TextEditingController();
  final _eventStartTimeController = TextEditingController();

  int currentRound = 0;
  bool isPaused = false;
  int pauseTimeInSeconds = 0;
  DateTime pauseStartTime = DateTime.now();

  int selectedTeam = 0;
  String selectedTeamName = "";

  DateTime _eventStartTime = DateTime.now();
  DateTime _eventEndTime = DateTime.now();

  final DatabaseReference _databaseTime =
      FirebaseDatabase.instance.ref('/time');

  bool isFirstRenderingWhistle = true;

  void _activateDatabaseTimeListener() {
    _databaseTime.child("isPaused").onValue.listen((event) {
      final bool streamIsPaused =
          event.snapshot.value.toString().toLowerCase() == 'true';
      if (!isFirstRenderingWhistle && streamIsPaused) {
        playWhistleSound();
      }
      if (!isFirstRenderingWhistle && !streamIsPaused) {
        playStartSound();
      }
      setState(() {
        isPaused = streamIsPaused;
      });
      if (isFirstRenderingWhistle) {
        isFirstRenderingWhistle = false;
      }
    });
    _databaseTime.child("pauseTime").onValue.listen((event) {
      final int streamPauseTime =
          int.tryParse(event.snapshot.value.toString()) ?? 0;
      setState(() {
        pauseTimeInSeconds = streamPauseTime;
      });
    });
    _databaseTime.child("startTime").onValue.listen((event) {
      final DateTime streamEventStartTime =
          stringToDateTime(event.snapshot.value.toString());
      setState(() {
        _eventStartTime = streamEventStartTime;
        currentRound = calculateCurrentRoundWithDateTime();
      });
    });
    _databaseTime.child("pauseStartTime").onValue.listen((event) {
      final DateTime streamPauseStartTime =
          stringToDateTime(event.snapshot.value.toString());
      setState(() {
        pauseStartTime = streamPauseStartTime;
      });
    });
    _databaseTime.child("chessTime").onValue.listen((event) {
      final Duration streamChessTime = Duration(
          seconds: int.tryParse(event.snapshot.value.toString()) ?? 240);
      setState(() {
        maxChessTime = streamChessTime;
      });
    });

    _databaseTime.child("roundTime").onValue.listen((event) {
      final Duration streamRoundTime = Duration(
          minutes: int.tryParse(event.snapshot.value.toString()) ?? 12);
      setState(() {
        roundTimeDuration = streamRoundTime;
      });
    });
    _databaseTime.child("playTime").onValue.listen((event) {
      final Duration streamPlayTime = Duration(
          minutes: int.tryParse(event.snapshot.value.toString()) ?? 10);
      setState(() {
        playTimeDuration = streamPlayTime;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSelectedTeam();
    _setUpTimer();
    _activateDatabaseTimeListener();
  }

  void _setUpTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), _updateTimerCallback);
    _updateCurrentRound();
    _updateMatchAndDiscipline();
  }

  void _updateTimerCallback(Timer timer) {
    if (!isPaused) {
      _updateCurrentRound();
      _updateMatchAndDiscipline();
    }
    calculateEventEndTime();
  }

  void calculateEventEndTime() {
    Duration calculatedDuration =
        Duration(minutes: pairings.length * roundTimeDuration.inMinutes) +
            Duration(seconds: pauseTimeInSeconds);
    if (isPaused) {
      calculatedDuration += DateTime.now().difference(pauseStartTime);
    }
    setState(() {
      _eventEndTime = _eventStartTime.add(calculatedDuration);
    });
  }

  void _updateCurrentRound() {
    int newCurrentRound = calculateCurrentRoundWithDateTime();
    if (newCurrentRound != currentRound) playStartSound();

    setState(() {
      currentRound = newCurrentRound;
    });
  }

  void _updateMatchAndDiscipline() {
    if (currentRound > 0 && currentRound <= pairings.length) {
      var opponentTeamNumber =
          getOpponentTeamNumberByRound(currentRound, selectedTeam);
      var nextOpponentTeamNumber =
          getOpponentTeamNumberByRound(currentRound + 1, selectedTeam);
      var disciplineName = getDisciplineName(currentRound, selectedTeam);
      var nextDisciplineName =
          getDisciplineName(currentRound + 1, selectedTeam);
      var startTeam = isStartingTeam(currentRound, selectedTeam)
          ? "Beginner: Team $selectedTeam"
          : "Beginner: Team $opponentTeamNumber";
      var nextStartTeam = isStartingTeam(currentRound + 1, selectedTeam)
          ? "Beginner: Team $selectedTeam"
          : "Beginner: Team $nextOpponentTeamNumber";
      setState(() {

        if (calculateRemainingTimeInRound().inSeconds <=
            (roundTimeDuration.inSeconds - playTimeDuration.inSeconds)) {
          currentMatchUpText = 'Wechseln. Bitte alles so aufbauen wie es vorher war!';
        } else {
          currentMatchUpText =
          'Aktuell: $disciplineName gegen Team $opponentTeamNumber. $startTeam';
        }

        nextMatchUpText =
            'Coming up: $nextDisciplineName gegen Team $nextOpponentTeamNumber. $nextStartTeam';
      });
    }
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

  int calculateCurrentRoundWithDateTime() {
    DateTime currentTime = DateTime.now();

    Duration timeDifference = currentTime.difference(_eventStartTime) -
        Duration(seconds: pauseTimeInSeconds);
    int currentRound = timeDifference.inMinutes ~/ roundTimeDuration.inMinutes;
    if (timeDifference.isNegative) return 0;
    return currentRound + 1;
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    String days = duration.inDays != 0 ? '${duration.inDays} d ' : '';
    String hours = '${twoDigits(duration.inHours.remainder(24))} h ';
    String minutes = '${twoDigits(duration.inMinutes.remainder(60))} Min';

    return days + hours + minutes;
  }

  Duration calculateRemainingTimeInRound() {
    DateTime currentTime = DateTime.now();

    if (currentTime.isBefore(_eventStartTime)) {
      return _eventStartTime.difference(currentTime);
    }

    int elapsedSeconds =
        currentTime.difference(_eventStartTime).inSeconds - pauseTimeInSeconds;
    int elapsedSecondsInCurrentRound =
        elapsedSeconds % roundTimeDuration.inSeconds;
    int remainingSecondsInCurrentRound =
        roundTimeDuration.inSeconds - elapsedSecondsInCurrentRound;

    if (remainingSecondsInCurrentRound ==
        (roundTimeDuration.inSeconds -
            playTimeDuration.inSeconds +
            const Duration(seconds: 60).inSeconds)) playWhooshSound();
    if (remainingSecondsInCurrentRound ==
        (roundTimeDuration.inSeconds - playTimeDuration.inSeconds)) {
      playschlagbolzenSound();
    }
    return Duration(seconds: remainingSecondsInCurrentRound);
  }

  void updateIsPausedInDatabase() {
    if (!mounted) return;
    if (isPaused) {
      getPauseStartTime().then((value) {
        int elapsedSeconds = DateTime.now().difference(value).inSeconds;
        getPauseTime().then((value2) {
          final DatabaseReference databaseReference =
              FirebaseDatabase.instance.ref('/time');
          databaseReference.update({
            "pauseTime": elapsedSeconds + value2,
          });
        });
      });
    } else {
      String dateTimeString = dateTimeToString(DateTime.now());
      final DatabaseReference databaseReference =
          FirebaseDatabase.instance.ref('/time');
      databaseReference.update({
        "pauseStartTime": dateTimeString,
      });
    }
    final DatabaseReference databaseReference =
        FirebaseDatabase.instance.ref('/time');
    databaseReference.update({
      "isPaused": !isPaused,
    });
  }

  void updateChessTimeInDatabase() {
    if (!mounted) return;
    final DatabaseReference databaseReference =
        FirebaseDatabase.instance.ref('/time');
    databaseReference.update({
      "chessTime": maxChessTime.inSeconds,
    });
  }

  void updateRoundTimeInDatabase() {
    if (!mounted) return;
    if (!mounted) return;
    final DatabaseReference databaseReference =
        FirebaseDatabase.instance.ref('/time');
    databaseReference.update({
      "roundTime": roundTimeDuration.inMinutes,
      "playTime": playTimeDuration.inMinutes,
    });
  }

  Color getRoundCircleColor() {
    if (currentRound > 0 && currentRound <= pairings.length) {
      if (calculateRemainingTimeInRound().inSeconds <
          (roundTimeDuration.inSeconds - playTimeDuration.inSeconds)) {
        return Colors.red;
      } else if (calculateRemainingTimeInRound().inSeconds <
          (roundTimeDuration.inSeconds -
              playTimeDuration.inSeconds +
              const Duration(seconds: 60).inSeconds)) {
        return Colors.orange;
      } else {
        return Colors.green;
      }
    } else {
      return Colors.red;
    }
  }

  @override
  void dispose() {
    _maxTimeController.dispose();
    _roundTimeController.dispose();
    _playTimeController.dispose();
    _eventStartTimeController.dispose();
    _timer.cancel();
    super.dispose();
  }

  Widget getDisciplineImage() {
    switch (getDisciplineName(currentRound, selectedTeam)) {
      case "Kicker":
        return Image.asset(
          "assets/kicker.png",
        );
      case "Darts":
        return Image.asset(
          "assets/darts.png",
        );
      case "Billard":
        return Image.asset(
          "assets/billard.png",
        );
      case "Bierpong":
        return Image.asset(
          "assets/beerpong.png",
        );
      case "Kubb":
        return Image.asset(
          "assets/kubb.png",
        );
      case "Jenga":
        return Image.asset(
          "assets/jenga.png",
        );
      default:
        return Image.asset(
          "assets/pokalganz.png",
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    String appBarTitle = 'Olympiade';

    Duration remainingTime = calculateRemainingTimeInRound();
    String formattedRemainingTime;
    if (isPaused) {
      formattedRemainingTime = "Pause";
    } else if (remainingTime.inMinutes > 59) {
      formattedRemainingTime = formatDuration(remainingTime);
    } else {
      formattedRemainingTime =
          '${remainingTime.inMinutes}:${(remainingTime.inSeconds % 60).toString().padLeft(2, '0')}';
    }

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
            onPressed: () => _openSettings(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.circle, color: getRoundCircleColor()),
                        Text(' Runde $currentRound',
                            style: const TextStyle(fontSize: 18)),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.timer),
                        Text(' Zeit: $formattedRemainingTime',
                            style: const TextStyle(fontSize: 18)),
                      ],
                    ),
                  ],
                ),
                if (isPaused)
                  const Icon(
                    Icons.pause,
                    size: 300,
                  )
                else if (currentRound <= pairings.length && currentRound > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(currentMatchUpText,
                              style: const TextStyle(fontSize: 18),
                              textAlign: TextAlign.center),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: SizedBox(
                              height: 150, child: getDisciplineImage()),
                        ),
                      ]),
                    ),
                  )
                else
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text(
                            currentRound > pairings.length
                                ? "Die Olympiade ist zu Ende"
                                : "Die Olympiade beginnt bald..",
                            style: const TextStyle(fontSize: 24)),
                      ),
                      SizedBox(height: 200, child: getDisciplineImage()),
                    ],
                  ),
                if (currentRound < pairings.length &&
                    !isPaused &&
                    currentRound >= 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(nextMatchUpText,
                            style: const TextStyle(fontSize: 15),
                            textAlign: TextAlign.center),
                      ),
                    ),
                  ),
              ],
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height / 14,
                    width: double.infinity,
                    child: FilledButton.tonal(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SoundBoard()));
                      },
                      child: const Text(
                        'Soundboard',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height / 14,
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
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height / 14,
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
                                      maxtime: maxChessTime.inSeconds,
                                    )));
                      },
                      child: const Text(
                        'Schachuhr',
                        style: TextStyle(fontSize: 20, color: Colors.white),
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
                            backgroundColor: Colors.grey[850],
                            padding: const EdgeInsets.all(16.0),
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RulesScreen()));
                          },
                          child: const Text('Regeln',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ),
                    Expanded(
                      child: FilledButton.tonal(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[850],
                          padding: const EdgeInsets.all(16.0),
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UploadResults(
                                      currentRound: currentRound,
                                      teamNumber: selectedTeam)));
                        },
                        child: const Text('Ergebnisse eintragen',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[850],
                            padding: const EdgeInsets.all(16.0),
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SchedulePage(
                                          pairings: pairings,
                                          disciplines: disciplines,
                                          currentRowForColor: currentRound,
                                        )));
                          },
                          child: const Text('Laufplan',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openSettings() {
    _maxTimeController.text = maxChessTime.inSeconds.toString();
    _roundTimeController.text = roundTimeDuration.inMinutes.toString();
    _playTimeController.text = playTimeDuration.inMinutes.toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(31.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
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
                  Row(
                    mainAxisAlignment: selectedTeamName == "Felix99" ||
                            selectedTeamName == "Simon00"
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.center,
                    children: [
                      const Text("Beginn:", style: TextStyle(fontSize: 18)),
                      Text(
                          DateFormat(' dd.MM.yyyy, HH:mm')
                              .format(_eventStartTime),
                          style: const TextStyle(fontSize: 18)),
                      const Text(" Uhr", style: TextStyle(fontSize: 18)),
                      if (selectedTeamName == "Felix99" ||
                          selectedTeamName == "Simon00")
                        TimePickerWidget(
                            currentEventStartTime: _eventStartTime,
                            onDateTimeSelected: (newTime) {
                              final DatabaseReference databaseReference =
                                  FirebaseDatabase.instance.ref('/time');
                              databaseReference.update({
                                "pauseTime": 0,
                                "startTime": dateTimeToString(newTime),
                              });
                            }),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: selectedTeamName == "Felix99" ||
                            selectedTeamName == "Simon00"
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Ende:",
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        DateFormat(' dd.MM.yyyy, HH:mm').format(_eventEndTime),
                        style: const TextStyle(fontSize: 18),
                      ),
                      const Text(
                        " Uhr",
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: (selectedTeamName == "Felix99" ||
                            selectedTeamName == "Simon00")
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.center,
                    children: const [
                      Text(
                        "(zzgl. zukünftige Pausen)",
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  if (selectedTeamName == "Felix99" ||
                      selectedTeamName == "Simon00")
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 75,
                          width: 200,
                          child: TextField(
                            controller: _maxTimeController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: "Schachuhr Zeit in Sekunden"),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            onChanged: (value) {
                              setState(() {
                                maxChessTime = Duration(
                                    seconds: int.tryParse(value) ??
                                        maxChessTime.inSeconds);
                              });
                            },
                          ),
                        ),
                        FilledButton.tonal(
                          onPressed: () => updateChessTimeInDatabase(),
                          child: const Text("Update"),
                        ),
                      ],
                    ),
                  if (selectedTeamName == "Felix99" ||
                      selectedTeamName == "Simon00")
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 75,
                          width: 200,
                          child: TextField(
                            controller: _roundTimeController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: "Rundenzeit in Minuten"),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            onChanged: (value) {
                              setState(() {
                                roundTimeDuration = Duration(
                                    minutes: int.tryParse(value) ??
                                        roundTimeDuration.inMinutes);
                              });
                            },
                          ),
                        ),
                        FilledButton.tonal(
                          onPressed: () => updateRoundTimeInDatabase(),
                          child: const Text("Update"),
                        ),
                      ],
                    ),
                  if (selectedTeamName == "Felix99" ||
                      selectedTeamName == "Simon00")
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 75,
                          width: 200,
                          child: TextField(
                            controller: _playTimeController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: "Spielzeit einer Runde"),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            onChanged: (value) {
                              setState(() {
                                playTimeDuration = Duration(
                                    minutes: int.tryParse(value) ??
                                        playTimeDuration.inMinutes);
                              });
                            },
                          ),
                        ),
                        FilledButton.tonal(
                          onPressed: () => updateRoundTimeInDatabase(),
                          child: const Text("Update"),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  if (selectedTeamName == "Felix99" ||
                      selectedTeamName == "Simon00")
                    FilledButton.tonal(
                      onPressed: () => updateIsPausedInDatabase(),
                      child: const Text("Update Pause in Database"),
                    ),
                  if (selectedTeamName == "Felix99" ||
                      selectedTeamName == "Simon00")
                    FilledButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ResultScreen(),
                          ),
                        );
                      },
                      child: const Text('Ergebnisse anschauen'),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
