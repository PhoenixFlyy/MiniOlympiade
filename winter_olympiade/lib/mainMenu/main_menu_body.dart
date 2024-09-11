import 'package:flutter/material.dart';
import 'package:olympiade/infos/achievements/achievement_provider.dart';
import 'package:olympiade/mainMenu/main_menu_button_column.dart';
import 'package:provider/provider.dart';
import 'package:starsview/starsview.dart';

import '../utils/match_data.dart';
import '../utils/match_detail_queries.dart';

class MainMenuBody extends StatelessWidget {
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

  const MainMenuBody({
    super.key,
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
    required this.calculateRemainingTimeInRound
  });

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    String days = duration.inDays != 0 ? '${duration.inDays} d ' : '';
    String hours = '${twoDigits(duration.inHours.remainder(24))} h ';
    String minutes = '${twoDigits(duration.inMinutes.remainder(60))} Min';

    return days + hours + minutes;
  }

  Color getRoundCircleColor() {
    if (currentRound > 0 && currentRound <= pairings.length) {
      if (calculateRemainingTimeInRound.inSeconds < (roundTimeDuration.inSeconds - playTimeDuration.inSeconds)) {
        return Colors.red;
      } else if (calculateRemainingTimeInRound.inSeconds <
          (roundTimeDuration.inSeconds - playTimeDuration.inSeconds + const Duration(seconds: 60).inSeconds)) {
        return Colors.orange;
      } else {
        return Colors.green;
      }
    } else {
      return Colors.red;
    }
  }

  Widget getDisciplineImage(BuildContext context) {
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

  @override
  Widget build(BuildContext context) {
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

    return SafeArea(
      child: Stack(
        children: <Widget>[
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

                    // Current row and time row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.circle, color: getRoundCircleColor()),
                            Text(currentRound > 30 ? "Ende" : ' Runde $currentRound',
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
                    if (isPaused)
                      const Icon(
                        Icons.pause,
                        size: 300,
                      )

                    // "Currently playing" component or trophy image
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
                                  style: const TextStyle(fontSize: 18), textAlign: TextAlign.center),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: SizedBox(height: 150, child: getDisciplineImage(context)),
                            ),
                          ]),
                        ),
                      )

                    // Info text (only before and after olympiade
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
                            child: getDisciplineImage(context),
                          )
                        ],
                      ),

                    // "Coming up" component (Only during olympiade)
                    if (currentRound < pairings.length && !isPaused && currentRound >= 1)
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
                                style: const TextStyle(fontSize: 15), textAlign: TextAlign.center),
                          ),
                        ),
                      ),

                  ],
                ),

                // Navigation button components
                MainButtonColumn(currentRound: currentRound, selectedTeam: selectedTeam, maxChessTime: maxChessTime),

              ],
            ),
          ),
        ],
      ),
    );
  }
}
