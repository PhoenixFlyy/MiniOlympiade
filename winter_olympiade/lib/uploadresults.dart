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
  bool showTeamScore = false;
  int selectedDiscipline = 1;
  double lastRoundTeamScore = 0.0;
  double currentRoundTeamScore = 0.0;


  @override
  void initState() {
    super.initState();
    if (widget.currentRound > 0 && widget.currentRound <= pairings.length) {
      selectedRound = widget.currentRound;
      selectedDiscipline =
          getDisciplineNumber(widget.currentRound, widget.teamNumber);
    }
  }

  void updateScores(int roundNumber) {
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
  }


  Widget getTeamScoreForAllRoundsText() {
    return FutureBuilder<List<double>>(
      future:
      getAllTeamPointsInDiscipline(selectedDiscipline, widget.teamNumber),
      builder: (BuildContext context, AsyncSnapshot<List<double>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Text("An error occurred.");
        } else {
          return DataTable(
            columns: const <DataColumn>[
              DataColumn(label: Text('Duell')),
              DataColumn(label: Text('Punkte')),
            ],
            rows: List<DataRow>.generate(
              snapshot.data!.length,
                  (int index) =>
                  DataRow(
                    cells: <DataCell>[
                      DataCell(Text((index + 1).toString())),
                      DataCell(Text(snapshot.data![index].toString())),
                    ],
                  ),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ergebnisse eintragen")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [

            // Dropdown und Text für die Last Round
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DropdownButton<int>(
                  value: selectedRound,
                  onChanged: (newValue) {
                    setState(() {
                      showTeamScore = false;
                      selectedRound = newValue!;
                    });
                  },
                  items: List<DropdownMenuItem<int>>.generate(
                    pairings.length,
                        (index) => DropdownMenuItem<int>(
                      value: index + 1,
                      child: Text('Last round ${index}',
                          style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                ),
                // Hier habe ich `selectedRound - 1` verwendet, um die Disziplin für die vorherige Runde zu erhalten.
                Text(getDisciplineName(selectedRound - 1, widget.teamNumber),
                    style: const TextStyle(fontSize: 23)),
              ],
            ),


            // ChoiceChip und Button für die Last Round
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // Mittig ausrichten
              children: [
                Wrap(
                  spacing: 8,
                  children: [0.0, 0.5, 1.0].map((value) {
                    return ChoiceChip(
                      label: Text(value.toString()),
                      selected: lastRoundTeamScore == value,
                      onSelected: (selected) {
                        setState(() {
                          lastRoundTeamScore = value;
                        });
                      },
                    );
                  }).toList(),
                ),

                SizedBox(width: 20), // Ein wenig Abstand hinzufügen
                ElevatedButton(
                  onPressed: () {
                    updateScores(selectedRound);
                  },
                  child: const Text("upload", style: TextStyle(fontSize: 16)),
                ),

              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(color: Colors.white),
            ),
            // Dropdown und Text für die Current Round
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DropdownButton<int>(
                  value: selectedRound,
                  onChanged: (newValue) {
                    setState(() {
                      showTeamScore = false;
                      selectedRound = newValue!;
                    });
                  },
                  items: List<DropdownMenuItem<int>>.generate(
                    pairings.length,
                        (index) =>
                        DropdownMenuItem<int>(
                          value: index + 1,
                          child: Text('Current round ${index + 1}',
                              style: const TextStyle(fontSize: 22)),
                        ),
                  ),
                ),
                Text(getDisciplineName(selectedRound, widget.teamNumber),
                    style: const TextStyle(fontSize: 23)),
              ],
            ),

            // ChoiceChip und Button für die Current Round
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // Mittig ausrichten
              children: [
                Wrap(
                  spacing: 8,
                  children: [0.0, 0.5, 1.0].map((value) {
                    return ChoiceChip(
                      label: Text(value.toString()),
                      selected: currentRoundTeamScore == value,
                      onSelected: (selected) {
                        setState(() {
                          currentRoundTeamScore = value;
                        });
                      },
                    );
                  }).toList(),
                ),

                SizedBox(width: 20), // Ein wenig Abstand hinzufügen
                ElevatedButton(
                  onPressed: () {
                    updateScores(selectedRound + 1); // Oder verwenden Sie eine andere Variable, die die nächste Runde repräsentiert.
                  },
                  child: const Text("upload", style: TextStyle(fontSize: 16)),
                ),

              ],
            ),

            // Der restliche Code bleibt unverändert.
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(color: Colors.white),
            ),
            Column(
              children: [
                DropdownButton<int>(
                  value: selectedDiscipline,
                  onChanged: (newValue) {
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