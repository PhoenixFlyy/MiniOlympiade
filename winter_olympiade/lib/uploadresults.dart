import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:winter_olympiade/utils/MatchDetails.dart';

class UploadResults extends StatefulWidget {
  final int currentRound;
  final String currentGame;
  final int teamNumber;

  const UploadResults({
    Key? key,
    required this.currentRound,
    required this.currentGame,
    required this.teamNumber,
  }) : super(key: key);

  @override
  State<UploadResults> createState() => _UploadResultsState();
}

class _UploadResultsState extends State<UploadResults> {
  int selectedRound = 1;
  int selectedMatchGame = 1;
  double team1Score = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.currentRound > 0 && widget.currentRound <= 60) {
      selectedRound = widget.currentRound;
    }
    if (disciplines.containsKey(widget.currentGame)) {
      selectedMatchGame = int.parse(widget.currentGame);
    }
  }

  void updateScores() {
    if (!mounted) return;

    final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

    databaseReference
        .child("results")
        .child("rounds")
        .child((selectedRound - 1).toString())
        .child("matches")
        .child((selectedMatchGame - 1).toString())
        .update({
      "team1": team1Score,
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
            DropdownButton<int>(
              // Use DropdownButton<int> for disciplines
              value: selectedMatchGame,
              onChanged: (newValue) {
                setState(() {
                  selectedMatchGame = newValue!;
                });
              },
              items: disciplines.keys.map((key) {
                return DropdownMenuItem<int>(
                  value: int.parse(key),
                  child: Text(disciplines[key]!),
                );
              }).toList(),
            ),
            Wrap(
              spacing: 8,
              children: [0.0, 0.5, 1.0].map((value) {
                return ChoiceChip(
                  label: Text(value.toString()),
                  selected: team1Score == value,
                  onSelected: (selected) {
                    setState(() {
                      team1Score = value;
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
