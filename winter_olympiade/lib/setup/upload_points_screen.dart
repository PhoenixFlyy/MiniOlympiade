import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/match_data.dart';
import '../utils/match_detail_queries.dart';
import 'package:olympiade/infos/achievements/achievement_provider.dart';
import 'package:provider/provider.dart';

class UploadResults extends StatefulWidget {
  final int currentRound;
  final int teamNumber;

  const UploadResults({
    super.key,
    required this.currentRound,
    required this.teamNumber,
  });

  @override
  State<UploadResults> createState() => _UploadResultsState();
}

class _UploadResultsState extends State<UploadResults> {
  int selectedDiscipline = 1;
  int currentSelectedRound = 1;
  double currentRoundTeamScore = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.currentRound > 0 && widget.currentRound <= pairings.length) {
      currentSelectedRound = widget.currentRound;
      selectedDiscipline = getDisciplineNumber(widget.currentRound, widget.teamNumber);
    }
  }

  void updateScores(int roundNumber, double teamScore) {
    if (!mounted) return;

    final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

    bool isStarting = isStartingTeam(roundNumber, widget.teamNumber);
    int matchNumber = getDisciplineNumber(roundNumber, widget.teamNumber);
    String teamKey = isStarting ? "team1" : "team2";
    String opponentTeamKey = isStarting ? "team2" : "team1";

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
      opponentTeamKey: otherTeamScore
    });

    context.read<AchievementProvider>().completeAchievementByTitle('Schreiberling'); //Achievements

    setState(() {});
  }

  Widget getTeamScoreForAllRoundsText() {
    return FutureBuilder<List<double>>(
      future: getAllTeamPointsInDisciplineSortedByMatch(
          selectedDiscipline, widget.teamNumber),
      builder: (BuildContext context, AsyncSnapshot<List<double>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Text("An error occurred.");
        } else {
          final dataRows = List<DataRow>.generate(
            snapshot.data!.length,
            (int index) => DataRow(
              cells: <DataCell>[
                DataCell(Text("Match ${index + 1}")),
                DataCell(Text(
                    "Team ${getOpponentListByDisciplines(selectedDiscipline, widget.teamNumber)[index]}")),
                DataCell(Text(snapshot.data![index].toString())),
              ],
            ),
          );
          dataRows.add(DataRow(
            cells: <DataCell>[
              const DataCell(Text("Summe:")),
              const DataCell(Text("")),
              DataCell(Text(getPointsInList(snapshot.data!).toString())),
            ],
          ));

          return DataTable(
            columns: const <DataColumn>[
              DataColumn(label: Text('')),
              DataColumn(label: Text('Gegner')),
              DataColumn(label: Text('Punkte')),
            ],
            rows: dataRows,
          );
        }
      },
    );
  }

  String getLabelForScore(double value) {
    if (value == 0.0) {
      return "Nied.";
    } else if (value == 0.5) {
      return "Unent.";
    } else if (value == 1.0) {
      return "Sieg";
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Hero(
            tag: "uploadHero",
            child: Text(
              "Ergebnisse nachtragen",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.normal,
                fontStyle: FontStyle.normal,
                letterSpacing: 0.0,
                wordSpacing: 0.0,
                decoration: TextDecoration.none,
                decorationColor: Colors.transparent,
                decorationStyle: TextDecorationStyle.solid,
                fontFamily: null,
                height: 1.0,
              ),)),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text('Runde: ',
                          style: TextStyle(fontSize: 22)),
                      DropdownButton<int>(
                        value: currentSelectedRound,
                        onChanged: (newValue) {
                          HapticFeedback.lightImpact();
                          setState(() {
                            currentSelectedRound = newValue!;
                          });
                        },
                        items: List<DropdownMenuItem<int>>.generate(
                          pairings.length,
                          (index) => DropdownMenuItem<int>(
                            value: index + 1,
                            child: Text('${index + 1}',
                                style: const TextStyle(fontSize: 22)),
                          ),
                        ),
                      ),
                    ]),
                Text(getDisciplineName(currentSelectedRound, widget.teamNumber),
                    style: const TextStyle(fontSize: 23)),
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
                            currentSelectedRound, currentRoundTeamScore);
                      },
                      child: const Text("Upload",
                          style: TextStyle(fontSize: 16, color: Colors.black)),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5.0),
              child: Divider(color: Colors.white),
            ),
            Column(
              children: [
                DropdownButton<int>(
                  value: selectedDiscipline,
                  onChanged: (newValue) {
                    HapticFeedback.lightImpact();
                    setState(() {
                      selectedDiscipline = newValue!;
                    });
                  },
                  items: disciplines.keys
                      .map<DropdownMenuItem<int>>((String value) {
                    return DropdownMenuItem<int>(
                      value: int.parse(value),
                      child: Text(disciplines[value]!),
                    );
                  }).toList(),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: getTeamScoreForAllRoundsText(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
