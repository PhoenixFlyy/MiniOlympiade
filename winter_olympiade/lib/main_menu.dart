import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:olympiade/games/Dart/darts_start_screen.dart';
import 'package:olympiade/infos/achievements/achievement_screen.dart';
import 'package:olympiade/infos/achievements/achievement_provider.dart';
import 'package:olympiade/utils/main_menu_navigation_drawer.dart';
import 'package:olympiade/wuecade/screens/main_menu_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:starsview/starsview.dart';

import 'games/chess_timer.dart';
import 'infos/rules.dart';
import 'infos/schedule_page.dart';
import 'setup/result_screen.dart';
import 'setup/upload_points_screen.dart';
import 'utils/date_time_picker.dart';
import 'utils/date_time_utils.dart';
import 'utils/match_data.dart';
import 'utils/match_detail_queries.dart';
import 'utils/play_sounds.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  late Timer _timer;
  String currentMatchUpText = '';
  String nextMatchUpText = '';

  final audioService = AudioService();

  Duration maxChessTime = const Duration(minutes: 4);
  Duration roundTimeDuration = const Duration(minutes: 12);
  Duration playTimeDuration = const Duration(minutes: 10);

  final _roundTimeController = TextEditingController();
  final _playTimeController = TextEditingController();
  final _maxChessTimeController = TextEditingController();

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
        audioService.playWhistleSound();
      }
      if (!isFirstRenderingWhistle && !streamIsPaused) {
        audioService.playStartSound();
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

  void _showWinnersDialog() {
    List<String> winners = ['2022: Wenzel & Daniel', '2023: Felix & Simon'];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          contentPadding: EdgeInsets.zero,
          content: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: -50,
                left: 0,
                right: 0,
                child: Image.asset(
                  'assets/background1.png',
                  fit: BoxFit.cover,
                  height: 100,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 60.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Center(
                      child: Text(
                        'Gewinner',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...winners.map((winner) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          winner,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.amberAccent,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
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
    if (newCurrentRound != currentRound) audioService.playStartSound();

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
          currentMatchUpText =
              'Wechseln. Bitte alles so aufbauen wie es vorher war!';
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
    if (currentTime.isAfter(_eventEndTime)) {
      return currentTime.difference(_eventEndTime);
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
            const Duration(seconds: 60).inSeconds)) audioService.playWhooshSound();
    if (remainingSecondsInCurrentRound ==
        (roundTimeDuration.inSeconds - playTimeDuration.inSeconds)) {
      audioService.playGongAkkuratSound();
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
    _maxChessTimeController.dispose();
    _roundTimeController.dispose();
    _playTimeController.dispose();
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
        return GestureDetector(
          onTap: () {
            _showWinnersDialog();
          },
          child: Image.asset("assets/pokalganz.png"),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    String appBarTitle = '';

    Duration remainingTime = calculateRemainingTimeInRound();
    String formattedRemainingTime;
    if (isPaused) {
      context.read<AchievementProvider>().completeAchievementByTitle('Halbzeit!');
      formattedRemainingTime = "Pause";
    } else if (remainingTime.inMinutes > 59) {
      formattedRemainingTime = formatDuration(remainingTime);
    } else {
      formattedRemainingTime =
          '${remainingTime.inMinutes}:${(remainingTime.inSeconds % 60).toString().padLeft(2, '0')}';
    }

    appBarTitle += 'Team $selectedTeam';
    if (selectedTeamName.isNotEmpty) {
      appBarTitle += ' - $selectedTeamName';
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(appBarTitle, style: const TextStyle(fontSize: 20)),
        actions: [
          if (selectedTeamName == "Felix99" || selectedTeamName == "Simon00")
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => _openSettings(),
            ),
        ],
      ),
      drawer: MainMenuNavigationDrawer(
          currentRound: currentRound,
          selectedRound: currentRound,
          teamNumber: selectedTeam,
          eventStartTime: _eventStartTime,
          eventEndTime: _eventEndTime,
          maxChessTime: maxChessTime.inSeconds),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: <Color>[Colors.black, Colors.black26]),
              ),
            ),
            const StarsView(
              fps: 60,
            ),
            Padding(
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
                              Text(
                                  currentRound > 30
                                      ? "Ende"
                                      : ' Runde $currentRound',
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
                      else if (currentRound <= pairings.length &&
                          currentRound > 0)
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
                            AspectRatio(
                              aspectRatio: 5 / 4,
                              child: getDisciplineImage(),
                            )
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
                  if (currentRound > pairings.length) previousWinners(),
                  mainButtonColumn(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget previousWinners() {
    return const Column(
      children: [
        Text("Bisherige Gewinner:",
            style: TextStyle(fontSize: 20, color: Colors.white)),
        Text("Wenzel & Daniel",
            style: TextStyle(fontSize: 22, color: Colors.amber)),
        Text("Simon B. & Felix",
            style: TextStyle(fontSize: 22, color: Colors.amber)),
      ],
    );
  }

  Widget mainMenuButton(
      String text, IconData icon, Widget Function() destinationWidget,
      {bool bottomPadding = true, bool rightPadding = false, double fontSize = 20, String? heroTag, bool withShimmer = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding ? 10 : 0, right: rightPadding ? 10 : 0),
      child: withShimmer
          ? Stack(
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[800]!,
            highlightColor: Colors.white.withOpacity(0.3),
            direction: ShimmerDirection.ltr,
            period: const Duration(seconds: 5),
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          FilledButton.tonal(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.all(16.0),
            ),
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => destinationWidget(),
                  ));
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 10),
                if (heroTag != null)
                  Hero(
                    tag: heroTag,
                    child: Text(
                      text,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSize,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  )
                else
                  Text(
                    text,
                    style: TextStyle(fontSize: fontSize, color: Colors.white),
                  ),
              ],
            ),
          ),
        ],
      )
          : FilledButton.tonal(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[800],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.all(16.0),
        ),
        onPressed: () {
          HapticFeedback.mediumImpact();
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => destinationWidget(),
              ));
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            if (heroTag != null)
              Hero(
                tag: heroTag,
                child: Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSize,
                    fontWeight: FontWeight.normal,
                    fontStyle: FontStyle.normal,
                    letterSpacing: 0.0,
                    wordSpacing: 0.0,
                    decoration: TextDecoration.none,
                    decorationColor: Colors.transparent,
                    decorationStyle: TextDecorationStyle.solid,
                    fontFamily: null,
                    height: 1.0,
                  ),
                ),
              )
            else
              Text(
                text,
                style: TextStyle(fontSize: fontSize, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }

  Widget mainButtonColumn() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        children: [
          mainMenuButton(
            "Ergebnisse eintragen",
            Icons.edit,
            () => UploadResults(
                currentRound: currentRound, teamNumber: selectedTeam),
            withShimmer: true,
            heroTag: "uploadHero"
          ),
          mainMenuButton(
            "Dartsrechner",
            Icons.sports_esports,
            () => const DartStartScreen(),
            heroTag: "dartsHero"
          ),
          mainMenuButton(
            "Schachuhr",
            Icons.timer,
            () => ChessTimer(maxTime: maxChessTime.inSeconds),
            heroTag: "ChessClockHero"
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                mainMenuButton(
                  "Regeln",
                  Icons.rule,
                      () {
                    context
                        .read<AchievementProvider>()
                        .completeAchievementByTitle('Nimm es ganz genau!');
                    return const RulesScreen();
                  },
                  bottomPadding: false,
                  rightPadding: true,
                  fontSize: 14,
                  heroTag: "rulesHero"
                ),
                mainMenuButton(
                  "Laufplan",
                  Icons.directions_run,
                      () => SchedulePage(
                    pairings: pairings,
                    disciplines: disciplines,
                    currentRowForColor: currentRound,
                  ),
                  bottomPadding: false,
                  rightPadding: true,
                  fontSize: 14,
                  heroTag: "scheduleHero"
                ),
                mainMenuButton(
                  "Achievements",
                  Icons.emoji_events,
                      () => const AchievementScreen(),
                  bottomPadding: false,
                  rightPadding: true,
                  fontSize: 14,
                  heroTag: "achievementHero",
                ),
                mainMenuButton(
                  "Wuecade Games",
                  Icons.gamepad,
                      () => const FlappyMain(),
                  bottomPadding: false,
                  rightPadding: false,
                  fontSize: 14,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _openSettings() {
    _maxChessTimeController.text = maxChessTime.inSeconds.toString();
    _roundTimeController.text = roundTimeDuration.inMinutes.toString();
    _playTimeController.text = playTimeDuration.inMinutes.toString();

    showModalBottomSheet(
      backgroundColor: Colors.black,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text("Beginn:", style: TextStyle(fontSize: 18)),
                      Text(
                          DateFormat(' dd.MM.yyyy, HH:mm')
                              .format(_eventStartTime),
                          style: const TextStyle(fontSize: 18)),
                      const Text(" Uhr", style: TextStyle(fontSize: 18)),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 75,
                        width: 200,
                        child: TextField(
                          controller: _maxChessTimeController,
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
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => updateChessTimeInDatabase(),
                        child: const Text("Update"),
                      ),
                    ],
                  ),
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
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => updateRoundTimeInDatabase(),
                        child: const Text("Update"),
                      ),
                    ],
                  ),
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
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => updateRoundTimeInDatabase(),
                        child: const Text("Update"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FilledButton.tonal(
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => updateIsPausedInDatabase(),
                    child: const Text("Update Pause in Database"),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
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
