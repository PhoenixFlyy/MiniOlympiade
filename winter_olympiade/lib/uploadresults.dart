import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class UploadResults extends StatefulWidget {
  const UploadResults({Key? key}) : super(key: key);

  @override
  State<UploadResults> createState() => _UploadResultsState();
}

class _UploadResultsState extends State<UploadResults> {
  int selectedRound = 1;
  int selectedMatchGame = 1;
  int team1Score = 0;

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
              value: selectedMatchGame,
              onChanged: (newValue) {
                setState(() {
                  selectedMatchGame = newValue!;
                });
              },
              items: List<DropdownMenuItem<int>>.generate(
                6,
                (index) => DropdownMenuItem<int>(
                  value: index + 1,
                  child: Text('Game ${index + 1}'),
                ),
              ),
            ),
            Text("Your Team 1 Score: $team1Score"),
            Wrap(
              spacing: 8,
              children: [0, 1, 3].map((value) {
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
