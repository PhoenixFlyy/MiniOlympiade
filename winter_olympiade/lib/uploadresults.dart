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
      appBar: AppBar(title: const Text("Ergebnisse eintragen")),
      body: Center(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text('Letzte Runde: ',
                          style: TextStyle(fontSize: 22)),
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
                            value: index + 1,
                            child: Text('${index + 1}',
                                style: const TextStyle(fontSize: 22)),
                          ),
                        ),
                      ),
                    ]),
                Text(getDisciplineName(lastSelectedRound, widget.teamNumber),
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
                                  color: lastRoundTeamScore == value
                                      ? Colors.white
                                      : Colors.grey,
                                ),
                              ),
                              Text(
                                getLabelForScore(value),
                                style: TextStyle(
                                  color: lastRoundTeamScore == value
                                      ? Colors.white
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          selected: lastRoundTeamScore == value,
                          onPressed: () {
                            setState(() {
                              lastRoundTeamScore = value;
                            });
                          },
                          showCheckmark: false,
                          backgroundColor: Color(0xFF1B191D),
                          selectedColor: Color(0xFF494255),
                        );
                      }).toList(),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        updateScores(lastSelectedRound, lastRoundTeamScore);
                      },
                      child:
                          const Text("Upload", style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5.0),
              child: Divider(color: Colors.white),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text('Aktuelle Runde: ',
                          style: TextStyle(fontSize: 22)),
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
                            setState(() {
                              currentRoundTeamScore = value;
                            });
                          },
                          showCheckmark: false,
                          backgroundColor: Color(0xFF1B191D),
                          selectedColor: Color(0xFF494255),
                        );
                      }).toList(),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        updateScores(
                            currentSelectedRound, currentRoundTeamScore);
                      },
                      child:
                          const Text("Upload", style: TextStyle(fontSize: 16)),
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
