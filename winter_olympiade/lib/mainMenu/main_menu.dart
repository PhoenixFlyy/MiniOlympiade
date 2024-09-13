import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:olympiade/infos/achievements/achievement_screen.dart';
import 'package:olympiade/infos/rules.dart';
import 'package:olympiade/infos/schedule_page.dart';
import 'package:olympiade/mainMenu/main_menu_navigation_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../utils/date_time_utils.dart';
import '../utils/match_data.dart';
import '../utils/match_detail_queries.dart';
import '../utils/play_sounds.dart';
import 'main_menu_body.dart';
import 'main_menu_settings.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  int currentPageIndex = 0;

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

  final DatabaseReference _databaseTime = FirebaseDatabase.instance.ref('/time');

  bool isFirstRenderingWhistle = true;

  void _activateDatabaseTimeListener() {
    _databaseTime.child("isPaused").onValue.listen((event) {
      final bool streamIsPaused = event.snapshot.value.toString().toLowerCase() == 'true';
      if (!isFirstRenderingWhistle && streamIsPaused) {
        audioService.playWhistleSound();
      }
      if (!isFirstRenderingWhistle && !streamIsPaused) {
        audioService.playStartSound();
      }
      if (mounted) {
        setState(() {
          isPaused = streamIsPaused;
        });
      }
      if (isFirstRenderingWhistle) {
        isFirstRenderingWhistle = false;
      }
    });
    _databaseTime.child("pauseTime").onValue.listen((event) {
      if (mounted) {
        setState(() => pauseTimeInSeconds = int.tryParse(event.snapshot.value.toString()) ?? 0);
      }
    });
    _databaseTime.child("startTime").onValue.listen((event) {
      if (mounted) {
        setState(() {
          _eventStartTime = stringToDateTime(event.snapshot.value.toString());
          currentRound = calculateCurrentRoundWithDateTime();
        });
      }
    });
    _databaseTime.child("pauseStartTime").onValue.listen((event) {
      if (mounted) {
        setState(() => pauseStartTime = stringToDateTime(event.snapshot.value.toString()));
      }
    });
    _databaseTime.child("chessTime").onValue.listen((event) {
      if (mounted) {
        setState(() => maxChessTime = Duration(seconds: int.tryParse(event.snapshot.value.toString()) ?? 240));
      }
    });

    _databaseTime.child("roundTime").onValue.listen((event) {
      if (mounted) {
        setState(() => roundTimeDuration = Duration(minutes: int.tryParse(event.snapshot.value.toString()) ?? 12));
      }
    });
    _databaseTime.child("playTime").onValue.listen((event) {
      if (mounted) {
        setState(() => playTimeDuration = Duration(minutes: int.tryParse(event.snapshot.value.toString()) ?? 10));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSelectedTeam();
    _setUpTimer();
    _activateDatabaseTimeListener();
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    _maxChessTimeController.dispose();
    _roundTimeController.dispose();
    _playTimeController.dispose();
    _timer.cancel();
    WakelockPlus.disable();
    super.dispose();
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
        Duration(minutes: pairings.length * roundTimeDuration.inMinutes) + Duration(seconds: pauseTimeInSeconds);
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
      var opponentTeamNumber = getOpponentTeamNumberByRound(currentRound, selectedTeam);
      var nextOpponentTeamNumber = getOpponentTeamNumberByRound(currentRound + 1, selectedTeam);
      var disciplineName = getDisciplineName(currentRound, selectedTeam);
      var nextDisciplineName = getDisciplineName(currentRound + 1, selectedTeam);
      var startTeam =
          isStartingTeam(currentRound, selectedTeam) ? "Beginner: Team $selectedTeam" : "Beginner: Team $opponentTeamNumber";
      var nextStartTeam = isStartingTeam(currentRound + 1, selectedTeam)
          ? "Beginner: Team $selectedTeam"
          : "Beginner: Team $nextOpponentTeamNumber";
      setState(() {
        if (calculateRemainingTimeInRound().inSeconds <= (roundTimeDuration.inSeconds - playTimeDuration.inSeconds)) {
          currentMatchUpText = 'Wechseln: Bitte so aufbauen wie vorher!';
        } else {
          currentMatchUpText = '$disciplineName gegen Team $opponentTeamNumber \n$startTeam';
        }

        nextMatchUpText = '$nextDisciplineName gegen Team $nextOpponentTeamNumber\n$nextStartTeam';
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

    Duration timeDifference = currentTime.difference(_eventStartTime) - Duration(seconds: pauseTimeInSeconds);
    int currentRound = timeDifference.inMinutes ~/ roundTimeDuration.inMinutes;
    if (timeDifference.isNegative) return 0;
    return currentRound + 1;
  }

  Duration calculateRemainingTimeInRound() {
    DateTime currentTime = DateTime.now();

    if (currentTime.isBefore(_eventStartTime)) {
      return _eventStartTime.difference(currentTime);
    }
    if (currentTime.isAfter(_eventEndTime)) {
      return currentTime.difference(_eventEndTime);
    }

    int elapsedSeconds = currentTime.difference(_eventStartTime).inSeconds - pauseTimeInSeconds;
    int elapsedSecondsInCurrentRound = elapsedSeconds % roundTimeDuration.inSeconds;
    int remainingSecondsInCurrentRound = roundTimeDuration.inSeconds - elapsedSecondsInCurrentRound;

    if (remainingSecondsInCurrentRound ==
        (roundTimeDuration.inSeconds - playTimeDuration.inSeconds + const Duration(seconds: 60).inSeconds)) {
      audioService.playWhooshSound();
    }
    if (remainingSecondsInCurrentRound == (roundTimeDuration.inSeconds - playTimeDuration.inSeconds)) {
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
          final DatabaseReference databaseReference = FirebaseDatabase.instance.ref('/time');
          databaseReference.update({
            "pauseTime": elapsedSeconds + value2,
          });
        });
      });
    } else {
      String dateTimeString = dateTimeToString(DateTime.now());
      final DatabaseReference databaseReference = FirebaseDatabase.instance.ref('/time');
      databaseReference.update({
        "pauseStartTime": dateTimeString,
      });
    }
    final DatabaseReference databaseReference = FirebaseDatabase.instance.ref('/time');
    databaseReference.update({
      "isPaused": !isPaused,
    });
  }

  void updateChessTimeInDatabase() {
    if (!mounted) return;
    final DatabaseReference databaseReference = FirebaseDatabase.instance.ref('/time');
    databaseReference.update({
      "chessTime": maxChessTime.inSeconds,
    });
  }

  List<Widget> _screenList() {
    return [
      MainMenuBody(
        currentRound: currentRound,
        selectedTeam: selectedTeam,
        maxChessTime: maxChessTime,
        isPaused: isPaused,
        currentMatchUpText: currentMatchUpText,
        nextMatchUpText: nextMatchUpText,
        remainingTime: calculateRemainingTimeInRound(),
        selectedTeamName: selectedTeamName,
        roundTimeDuration: roundTimeDuration,
        playTimeDuration: playTimeDuration,
        calculateRemainingTimeInRound: calculateRemainingTimeInRound(),
      ),
      const RulesScreen(),
      SchedulePage(currentRound: currentRound, isCurrentPage: currentPageIndex == 2),
      const AchievementScreen()
    ];
  }

  @override
  Widget build(BuildContext context) {
    String appBarTitle = 'Team $selectedTeam';
    if (selectedTeamName.isNotEmpty) {
      appBarTitle += '         $selectedTeamName';
    }

    return Scaffold(
      key: _key,
      appBar: AppBar(
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
      body: IndexedStack(
        index: currentPageIndex,
        children: _screenList(),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.black,
        selectedIndex: currentPageIndex,
        indicatorColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (int index) {
          setState(() => currentPageIndex = index);
        },
        destinations: const <Widget>[
          NavigationDestination(icon: Icon(Icons.home, color: Colors.white), label: "Home", selectedIcon: Icon(Icons.home, color: Colors.amber)),
          NavigationDestination(icon: Icon(Icons.rule, color: Colors.white), label: "Regeln", selectedIcon: Icon(Icons.rule, color: Colors.amber)),
          NavigationDestination(icon: Icon(Icons.directions_run, color: Colors.white), label: "Laufplan", selectedIcon: Icon(Icons.directions_run, color: Colors.amber)),
          NavigationDestination(icon: Icon(Icons.emoji_events, color: Colors.white), label: "Achievements", selectedIcon: Icon(Icons.emoji_events, color: Colors.amber)),
        ],
      ),
    );
  }

  void _openSettings() {
    _maxChessTimeController.text = maxChessTime.inSeconds.toString();
    _roundTimeController.text = roundTimeDuration.inMinutes.toString();
    _playTimeController.text = playTimeDuration.inMinutes.toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SettingsModal(
          maxChessTimeController: _maxChessTimeController,
          roundTimeController: _roundTimeController,
          playTimeController: _playTimeController,
          eventStartTime: _eventStartTime,
          updateChessTimeInDatabase: updateChessTimeInDatabase,
          updateIsPausedInDatabase: updateIsPausedInDatabase,
        );
      },
    );
  }
}
