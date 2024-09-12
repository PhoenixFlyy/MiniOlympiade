import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:olympiade/infos/achievements/achievement_provider.dart';
import 'package:olympiade/mainMenu/main_menu_button_column.dart';
import 'package:olympiade/mainMenu/main_menu_points_dialog.dart';
import 'package:provider/provider.dart';
import 'package:starsview/config/MeteoriteConfig.dart';
import 'package:starsview/config/StarsConfig.dart';
import 'package:starsview/starsview.dart';

import '../utils/match_data.dart';
import '../utils/match_detail_queries.dart';

class MainMenuBody extends StatefulWidget {
  final int currentRound;
  final int selectedTeam;
  final Duration maxChessTime;
  final bool isPaused;
  final String currentMatchUpText;
  final String nextMatchUpText;
  final Duration remainingTime;
  final String selectedTeamName;
  final Duration roundTimeDuration;
  final Duration playTimeDuration;
  final Duration calculateRemainingTimeInRound;

  const MainMenuBody(
      {super.key,
      required this.currentRound,
      required this.selectedTeam,
      required this.maxChessTime,
      required this.isPaused,
      required this.currentMatchUpText,
      required this.nextMatchUpText,
      required this.remainingTime,
      required this.selectedTeamName,
      required this.roundTimeDuration,
      required this.playTimeDuration,
      required this.calculateRemainingTimeInRound});

  @override
  State<MainMenuBody> createState() => _MainMenuBodyState();
}

class _MainMenuBodyState extends State<MainMenuBody> {
  bool isPointsDialogOpen = false;
  bool isDatabaseCorrect = false;

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    String days = duration.inDays != 0 ? '${duration.inDays} d ' : '';
    String hours = '${twoDigits(duration.inHours.remainder(24))} h ';
    String minutes = '${twoDigits(duration.inMinutes.remainder(60))} Min';

    return days + hours + minutes;
  }

  void showPointsDialog() async {
    bool pointsConfirmed = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return PopScope(
            canPop: false,
            child: Dialog(
              backgroundColor: Colors.green,
              alignment: Alignment.center,
              insetPadding: const EdgeInsets.all(20),
              child: MainMenuPointsDialog(
                currentRound: widget.currentRound,
                teamNumber: widget.selectedTeam,
              ),
            ),
          );
        });
    if (pointsConfirmed) isPointsDialogOpen = false;
  }

  Color getRoundCircleColor() {
    if (widget.currentRound > 0 && widget.currentRound <= pairings.length) {
      if (widget.calculateRemainingTimeInRound.inSeconds < (widget.roundTimeDuration.inSeconds - widget.playTimeDuration.inSeconds)) {
        return Colors.red;
      } else if (widget.calculateRemainingTimeInRound.inSeconds <
          (widget.roundTimeDuration.inSeconds - widget.playTimeDuration.inSeconds + const Duration(seconds: 60).inSeconds)) {
        return Colors.orange;
      } else {
        return Colors.green;
      }
    } else {
      return Colors.red;
    }
  }

  Widget getDisciplineImage(BuildContext context) {
    switch (getDisciplineName(widget.currentRound, widget.selectedTeam)) {
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
            _showWinnersDialog(context);
          },
          child: Image.asset("assets/pokalganz.png"),
        );
    }
  }

  void _showWinnersDialog(BuildContext context) {
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

  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref('/results/rounds');

  @override
  void didUpdateWidget(MainMenuBody oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedTeam != widget.selectedTeam || oldWidget.currentRound != widget.currentRound) {
      databaseListener();
    }
  }

  void databaseListener() {
    databaseReference
        .child((widget.currentRound - 1).toString())
        .child("matches")
        .child((getDisciplineNumber(widget.currentRound, widget.selectedTeam) - 1).toString())
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        final team1Score = data['team1'];
        final team2Score = data['team2'];
        if ((team1Score == 1 && team2Score == 0) ||
            (team1Score == 0 && team2Score == 1) ||
            (team1Score == 0.5 && team2Score == 0.5)) {
          setState(() => isDatabaseCorrect = true);
        } else {
          setState(() => isDatabaseCorrect = false);
        }
      }
    });
  }

  Widget _currentRoundContainer() {
    return Opacity(
      opacity: isPointsDialogOpen ? 0.4 : 1.0,
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              colors: [
                Colors.grey.shade700,
                Colors.grey.shade800,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Aktuelle Runde",
                          style: TextStyle(fontSize: 22, color: Colors.grey[350]!),
                          textAlign: TextAlign.start,
                        ),
                        Text(widget.currentMatchUpText,
                            style: const TextStyle(fontSize: 20), textAlign: TextAlign.start),
                      ]),
                ),
                Expanded(
                  flex: 1,
                  child: SizedBox(
                      height: double.infinity,
                      child: getDisciplineImage(context)
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _comingUpContainer() {
    return Opacity(
      opacity: isPointsDialogOpen ? 0.4 : 1.0,
      child: Container(
        height: 125,
        width: 190,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            colors: [
              Colors.grey.shade700,
              Colors.grey.shade800,
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Coming Up",
                style: TextStyle(fontSize: 20, color: Colors.grey[350]!),
                textAlign: TextAlign.start,
              ),
              Text(widget.nextMatchUpText,
                  style: const TextStyle(fontSize: 18), textAlign: TextAlign.start),
            ],
          ),
        ),
      ),
    );
  }

  Widget _highlightTimeContainer() {
    Duration remainingStateTime;
    if (widget.calculateRemainingTimeInRound.inSeconds < (widget.roundTimeDuration.inSeconds - widget.playTimeDuration.inSeconds)) {
      remainingStateTime = widget.calculateRemainingTimeInRound;
    } else {
      remainingStateTime = Duration(seconds: widget.calculateRemainingTimeInRound.inSeconds - (widget.roundTimeDuration.inSeconds - widget.playTimeDuration.inSeconds));
    }

    return Container(
      height: 125,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: [
            (getRoundCircleColor() as MaterialColor).shade500,
            (getRoundCircleColor() as MaterialColor).shade600
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Center(
          child: Text(
              '${remainingStateTime.inMinutes}:${(remainingStateTime.inSeconds % 60).toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String formattedRemainingTime;
    if (widget.isPaused) {
      context.read<AchievementProvider>().completeAchievementByTitle('Halbzeit!');
      formattedRemainingTime = "Pause";
    } else if (widget.remainingTime.inMinutes > 59) {
      formattedRemainingTime = formatDuration(widget.remainingTime);
    } else {
      formattedRemainingTime =
          '${widget.remainingTime.inMinutes}:${(widget.remainingTime.inSeconds % 60).toString().padLeft(2, '0')}';
    }

    if (!isPointsDialogOpen &&
        !isDatabaseCorrect &&
        (widget.remainingTime.inSeconds <= (widget.roundTimeDuration.inSeconds - widget.playTimeDuration.inSeconds) &&
            widget.remainingTime.inSeconds > 0) &&
        widget.currentRound > 0 &&
        widget.currentRound <= pairings.length) {
      isPointsDialogOpen = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showPointsDialog();
      });
    }

    return SafeArea(
      child: Stack(
        children: <Widget>[
          const StarsView(
            fps: 60,
            meteoriteConfig: MeteoriteConfig(
              colors: [
                Colors.amber,
                Colors.white,
                Colors.amberAccent,
              ],
              minMeteoriteSpeed: 20,
            ),
            starsConfig: StarsConfig(
              colors: [
                Colors.amberAccent,
                Colors.white,
              ],
              starCount: 100,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Column(
                  children: [
                    // Current round and time row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.circle, color: getRoundCircleColor()),
                            Text(widget.currentRound > 30 ? "Ende" : ' Runde ${widget.currentRound}',
                                style: const TextStyle(fontSize: 18)),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.timer),
                            Text(' Zeit: $formattedRemainingTime', style: const TextStyle(fontSize: 18)),
                          ],
                        ),
                      ],
                    ),

                    // pause component (only during pause)
                    if (widget.isPaused)
                      const Icon(
                        Icons.pause,
                        size: 300,
                      ),

                    Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // "Currently playing" component or trophy image
                            if (widget.currentRound <= pairings.length && widget.currentRound > 0 && !widget.isPaused)
                              _currentRoundContainer(),
                            // "Coming up" component (Only during olympiade)
                            if (widget.currentRound < pairings.length &&
                                !widget.isPaused &&
                                widget.currentRound >= 1 &&
                                !widget.isPaused)
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Flex(
                                  direction: Axis.horizontal,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: _comingUpContainer(),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      flex: 1,
                                      child: _highlightTimeContainer(),
                                    )
                                  ],
                                ),
                              )

                            // Info text (only before and after olympiade
                            else if ((widget.currentRound > pairings.length || widget.currentRound < 1) && !widget.isPaused)
                              Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: Text(
                                        widget.currentRound > pairings.length
                                            ? "Die Olympiade ist zu Ende"
                                            : "Die Olympiade beginnt bald..",
                                        style: const TextStyle(fontSize: 24)),
                                  ),
                                  AspectRatio(
                                    aspectRatio: 5 / 4,
                                    child: getDisciplineImage(context),
                                  )
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                // Navigation button components
                Expanded(
                  child: MainButtonColumn(
                      currentRound: widget.currentRound,
                      selectedTeam: widget.selectedTeam,
                      maxChessTime: widget.maxChessTime
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
