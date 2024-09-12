import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../infos/achievements/achievement_provider.dart';
import '../utils/match_detail_queries.dart';

class MainMenuPointsDialog extends StatefulWidget {
  final int currentRound;
  final int teamNumber;

  const MainMenuPointsDialog({super.key, required this.currentRound, required this.teamNumber});

  @override
  State<MainMenuPointsDialog> createState() => _MainMenuPointsDialogState();
}

class _MainMenuPointsDialogState extends State<MainMenuPointsDialog> {
  double currentRoundTeamScore = 0.0;

  String getLabelForScore(double value) {
    if (value == 0.0) {
      return "Verlierer";
    } else if (value == 0.5) {
      return "Unentsch.";
    } else if (value == 1.0) {
      return "Gewinner";
    }
    return "";
  }

  void updateScores(int roundNumber, double teamScore) {
    if (!mounted) return;

    final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

    int matchNumber = getDisciplineNumber(roundNumber, widget.teamNumber);
    String teamKey = isStartingTeam(roundNumber, widget.teamNumber) ? "team1" : "team2";
    String opponentTeamKey = isStartingTeam(roundNumber, widget.teamNumber) ? "team2" : "team1";

    double otherTeamScore = 0.0;
    if (teamScore == 0.0) {
      otherTeamScore = 1.0;
    } else if (teamScore == 1.0) {
      otherTeamScore = 0.0;
    } else if (teamScore == 0.5) {
      otherTeamScore = 0.5;
    }

    databaseReference
        .child("results")
        .child("rounds")
        .child((roundNumber - 1).toString())
        .child("matches")
        .child((matchNumber - 1).toString())
        .update({
      teamKey: teamScore,
      opponentTeamKey: otherTeamScore,
    });

    context.read<AchievementProvider>().completeAchievementByTitle('Schreiberling'); //Achievements

    setState(() {});
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 275,
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                  GestureDetector(
                    onDoubleTap: () {
                      Navigator.of(context).pop(true);
                    },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('Aktuelle Runde: ${widget.currentRound}', style: const TextStyle(fontSize: 22)),
                          Text("Gegen Team: ${getOpponentTeamNumberByRound(widget.currentRound, widget.teamNumber)}", style: const TextStyle(fontSize: 22))
                        ],
                      )),
                ]),
                Text(getDisciplineName(widget.currentRound, widget.teamNumber), style: const TextStyle(fontSize: 23)),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Wrap(
                      spacing: 8,
                      children: [0, 0.5, 1].map((value) {
                        return Expanded(
                          child: RawChip(
                            label: Column(
                              children: [
                                Text(
                                  value.toString(),
                                  style: TextStyle(
                                    color: currentRoundTeamScore == value.toDouble() ? Colors.white : Colors.grey,
                                  ),
                                ),
                                Text(
                                  getLabelForScore(value.toDouble()),
                                  style: TextStyle(
                                    color: currentRoundTeamScore == value.toDouble() ? Colors.white : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            selected: currentRoundTeamScore == value.toDouble(),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              setState(() {
                                currentRoundTeamScore = value.toDouble();
                              });
                            },
                            showCheckmark: false,
                            backgroundColor: const Color(0xFF000000),
                            selectedColor: const Color(0xB3FF9800),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              width: 200,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.heavyImpact();
                  updateScores(widget.currentRound, currentRoundTeamScore);
                },
                child: Stack(
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey[800]!,
                      highlightColor: Colors.white.withOpacity(0.3),
                      period: const Duration(seconds: 2),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                        decoration: BoxDecoration(
                          color: Colors.grey[800]!,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const Center(
                      child: Text(
                        "Upload",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
