import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

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
      return "Niederlage";
    } else if (value == 0.5) {
      return "Unentschieden";
    } else if (value == 1.0) {
      return "Sieg";
    }
    return "";
  }

  void updateScores(int roundNumber, double teamScore) {
    if (!mounted) return;

    final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

    bool isStarting = isStartingTeam(roundNumber, widget.teamNumber);
    int matchNumber = getDisciplineNumber(roundNumber, widget.teamNumber);
    String teamKey = isStarting ? "team1" : "team2";

    databaseReference
        .child("results")
        .child("rounds")
        .child((roundNumber - 1).toString())
        .child("matches")
        .child((matchNumber - 1).toString())
        .update({
      teamKey: teamScore,
    });

    context.read<AchievementProvider>().completeAchievementByTitle('Schreiberling'); //Achievements

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              Text('Aktuelle Runde: ${widget.currentRound}', style: const TextStyle(fontSize: 22)),
            ]),
            Text(getDisciplineName(widget.currentRound, widget.teamNumber), style: const TextStyle(fontSize: 23)),
          ],
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Wrap(
                  spacing: 8,
                  children: [0.0, 0.5, 1.0].map((value) {
                    return RawChip(
                      label: Column(
                        children: [
                          Text(
                            value.toString(),
                            style: TextStyle(
                              color: currentRoundTeamScore == value
                                  ? Colors.white
                                  : Colors.grey,
                            ),
                          ),
                          Text(
                            getLabelForScore(value),
                            style: TextStyle(
                              color: currentRoundTeamScore == value
                                  ? Colors.white
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      selected: currentRoundTeamScore == value,
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          currentRoundTeamScore = value;
                        });
                      },
                      showCheckmark: false,
                      backgroundColor: const Color(0xFF1B191D),
                      selectedColor: const Color(0xFF494255),
                    );
                  }).toList(),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    updateScores(
                        widget.currentRound, currentRoundTeamScore);
                  },
                  child: const Text("Upload",
                      style: TextStyle(fontSize: 16, color: Colors.black)),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}