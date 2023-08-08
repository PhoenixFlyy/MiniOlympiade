import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:winter_olympiade/utils/GetMatchDetails.dart';
import 'package:winter_olympiade/utils/MatchDetails.dart';

class UploadResults extends StatefulWidget {
  final int currentRound;
  final int teamNumber;

  const UploadResults({
    Key? key,
    required this.currentRound,
    required this.teamNumber,
  }) : super(key: key);

  @override
  State<UploadResults> createState() => _UploadResultsState();
}

class _UploadResultsState extends State<UploadResults> {
  int selectedRound = 1;
  double teamScore = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.currentRound > 0 && widget.currentRound <= pairings.length) {
      selectedRound = widget.currentRound;
    }
  }

  void updateScores() {
    if (!mounted) return;

    final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

    bool isStarting = isStartingTeam(selectedRound - 1, widget.teamNumber);
    int matchNumber = getDisciplineNumber(selectedRound, widget.teamNumber);
    String teamKey = isStarting ? "team1" : "team2";

    print(matchNumber);

    databaseReference
        .child("results")
        .child("rounds")
        .child((selectedRound - 1).toString())
        .child("matches")
        .child((matchNumber - 1).toString())
        .update({
      teamKey: teamScore,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ergebnisse eintragen")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            DropdownButton<int>(
              value: selectedRound,
              onChanged: (newValue) {
                setState(() {
                  selectedRound = newValue!;
                });
              },
              items: List<DropdownMenuItem<int>>.generate(
                60,
                (index) => DropdownMenuItem<int>(
                  value: index + 1,
                  child: Text('Round ${index + 1}'),
                ),
              ),
            ),
            Text(getDisciplineName(selectedRound, widget.teamNumber)),
            Wrap(
              spacing: 8,
              children: [0.0, 0.5, 1.0].map((value) {
                return ChoiceChip(
                  label: Text(value.toString()),
                  selected: teamScore == value,
                  onSelected: (selected) {
                    setState(() {
                      teamScore = value;
                    });
                  },
                );
              }).toList(),
            ),
            ElevatedButton(
              onPressed: () {
                updateScores();
              },
              child: Text("Upload Scores"),
            ),
          ],
        ),
      ),
    );
  }
}
