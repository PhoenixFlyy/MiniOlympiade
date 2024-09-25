import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/match_data.dart';
import '../utils/match_detail_queries.dart';
import 'package:olympiade/infos/achievements/achievement_provider.dart';
import 'package:provider/provider.dart';

import '../utils/text_formatting.dart';

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
  int selectedRound = 1;
  double selectedChipScore = -1;
  List<double>? teamScoresInDiscipline;

  @override
  void initState() {
    super.initState();
    if (widget.currentRound > 0 && widget.currentRound <= pairings.length) {
      selectedRound = widget.currentRound;
      selectedDiscipline = getDisciplineNumber(widget.currentRound, widget.teamNumber);
    }
    fetchTeamScores();
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

    context.read<AchievementProvider>().completeAchievementByTitle('Schreiberling');

    setState(() {});
  }

  void fetchTeamScores() async {
    getAllTeamPointsInDisciplineSortedByMatch(selectedDiscipline, widget.teamNumber)
        .then((data) => {
      setState(() => teamScoresInDiscipline = data)
    });
  }

  Widget _roundDisciplineSelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Text('Runde: ',
                  style: TextStyle(fontSize: 22)),
              DropdownButton<int>(
                value: selectedRound,
                onChanged: (newValue) {
                  HapticFeedback.lightImpact();
                  setState(() {
                    selectedRound = newValue!;
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
        Text(getDisciplineName(selectedRound, widget.teamNumber),
            style: const TextStyle(fontSize: 23)),
      ],
    );
  }

  Widget _chipSelectionRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [0, 0.5, 1].map((value) {
        return Expanded(
          child: RawChip(
            label: Column(
              children: [
                Text(
                  value.toString(),
                  style: TextStyle(
                    color: selectedChipScore == value.toDouble() ? Colors.white : Colors.grey,
                  ),
                ),
                Text(
                  getLabelForScore(value.toDouble()),
                  style: TextStyle(
                    color: selectedChipScore == value.toDouble() ? Colors.white : Colors.grey,
                  ),
                ),
              ],
            ),
            selected: selectedChipScore == value.toDouble(),
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() {
                selectedChipScore = value.toDouble();
              });
            },
            showCheckmark: false,
            backgroundColor: const Color(0xFF000000),
            selectedColor: const Color(0xB3FF9800),
          ),
        );
      }).toList(),
    );
  }

  Widget _uploadButton() {
    return SizedBox(
      width: 200,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: selectedChipScore == -1 ? Colors.grey : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () {
          if (selectedChipScore != -1) {
            HapticFeedback.heavyImpact();
            updateScores(selectedRound, selectedChipScore);
            fetchTeamScores();
            setState(() => selectedChipScore = -1);
          }
        },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.upload, color: Colors.black),
            SizedBox(width: 10),
            Text("Upload",
                style: TextStyle(fontSize: 16, color: Colors.black)),
          ],
        ),
      ),
    );
  }

  Widget _getTeamScoreForAllRounds() {
    if (teamScoresInDiscipline == null) {
      return const Text("Noch keine Daten verfügbar");
    }

    final dataRows = List<DataRow>.generate(
      teamScoresInDiscipline!.length,
          (int index) => DataRow(
        cells: <DataCell>[
          DataCell(Text("Match ${index + 1}")),
          DataCell(Text(
              "Team ${getOpponentListByDisciplines(selectedDiscipline, widget.teamNumber)[index]}")),
          DataCell(getScoreText(teamScoresInDiscipline![index])),
        ],
      ),
    );
    return DataTable(
      columns: const <DataColumn>[
        DataColumn(label: Text('')),
        DataColumn(label: Text('Gegner')),
        DataColumn(label: Text('Ausgang')),
      ],
      rows: dataRows,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: const Text(
          "Ergebnisse nachtragen",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),),
      ),
      body: Center(
        child: Column(
          children: [
            _roundDisciplineSelection(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: _chipSelectionRow(),
            ),
            _uploadButton(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Divider(color: Colors.white),
            ),
            Column(
              children: [
                DropdownButton<int>(
                  value: selectedDiscipline,
                  onChanged: (newValue) {
                    HapticFeedback.lightImpact();
                    setState(() => selectedDiscipline = newValue!);
                    fetchTeamScores();
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
                  child: _getTeamScoreForAllRounds(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}