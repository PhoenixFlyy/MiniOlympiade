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
  int selectedDiscipline = 1;

  int currentSelectedRound = 1;
  int lastSelectedRound = 1;

  double currentRoundTeamScore = 0.0;
  double lastRoundTeamScore = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.currentRound > 0 && widget.currentRound < pairings.length) {
      currentSelectedRound = widget.currentRound;
      selectedDiscipline =
          getDisciplineNumber(widget.currentRound, widget.teamNumber);
      if (widget.currentRound > 0) {
        lastSelectedRound = widget.currentRound - 1;
      } else {
        lastSelectedRound = widget.currentRound;
      }
    }
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
    setState(() {});
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
          final dataRows = List<DataRow>.generate(
            snapshot.data!.length,
            (int index) => DataRow(
              cells: <DataCell>[
                DataCell(Text("Runde ${index + 1}")),
                DataCell(Text(
                    "Team ${getOpponentTeamNumber(index + 1, widget.teamNumber)}")),
                DataCell(Text(snapshot.data![index].toString())),
              ],
            ),
          );
          dataRows.add(DataRow(
            cells: <DataCell>[
              const DataCell(Text("Summe")),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ergebnisse eintragen")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('Letzte Runde: ',
                          style: const TextStyle(fontSize: 22)),
                      DropdownButton<int>(
                        value: lastSelectedRound,
                        onChanged: (newValue) {
                          setState(() {
                            lastSelectedRound = newValue!;
                          });
                        },
                        items: List<DropdownMenuItem<int>>.generate(
                          pairings.length,
                          (index) => DropdownMenuItem<int>(
                            value: index,
                            child: Text('${index}',
                                style: const TextStyle(fontSize: 22)),
                          ),
                        ),
                      ),
                    ]),
                Text(getDisciplineName(lastSelectedRound, widget.teamNumber),
                    style: const TextStyle(fontSize: 23)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    updateScores(lastSelectedRound, lastRoundTeamScore);
                  },
                  child: const Text("Upload", style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(color: Colors.white),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('Aktuelle Runde: ',
                          style: const TextStyle(fontSize: 22)),
                      DropdownButton<int>(
                        value: currentSelectedRound,
                        onChanged: (newValue) {
                          setState(() {
                            currentSelectedRound = newValue!;
                          });
                        },
                        items: List<DropdownMenuItem<int>>.generate(
                          pairings.length,
                          (index) => DropdownMenuItem<int>(
                            value: index,
                            child: Text('${index}',
                                style: const TextStyle(fontSize: 22)),
                          ),
                        ),
                      ),
                    ]),
                Text(getDisciplineName(currentSelectedRound, widget.teamNumber),
                    style: const TextStyle(fontSize: 23)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    updateScores(currentSelectedRound, currentRoundTeamScore);
                  },
                  child: const Text("Upload", style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
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
