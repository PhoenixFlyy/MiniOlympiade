import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:olympiade/utils/text_formatting.dart';
import '../utils/match_data.dart';
import '../utils/match_detail_queries.dart';
import '../utils/result_calculations.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool showResultsPermission = false;
  bool showSumGrid = false;
  bool showNormGrid = false;
  bool showWinnerGrid = false;

  late Future<List<double>> winnerGridData;
  late Future<List<List<double>>> sumGridData;
  late Future<List<List<double>>> normGridData;
  late List<List<Future<List<double>>>> disciplineGridData;

  @override
  void initState() {
    super.initState();

    disciplineGridData = List.generate(pairings[0].length, (disciplineIndex) {
      return List.generate(teamAmount, (teamIndex) {
        return getAllTeamPointsInDisciplineSortedByMatch(disciplineIndex + 1, teamIndex + 1);
      });
    });

    addPermissionListener();
  }

  void addPermissionListener() {
    final DatabaseReference databaseTime = FirebaseDatabase.instance.ref('/time');
    databaseTime.child("showResults").onValue.listen((event) {
      final bool streamShowResults = event.snapshot.value.toString().toLowerCase() == 'true';
      if (mounted) {
        setState(() => showResultsPermission = streamShowResults);
      }
    });
  }

  Widget _toggleGridButton(int buttonNumber) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: SizedBox(
        width: 300,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            HapticFeedback.heavyImpact();
            if (showResultsPermission) {
              setState(() {
                if (buttonNumber == 0) {
                  sumGridData = Future.wait(
                    List.generate(teamAmount, (rowNumber) {
                      return Future.wait(
                        List.generate(teamAmount, (colNumber) {
                          return getAllTeamPointsInDisciplineSortedByMatch(colNumber + 1, rowNumber + 1)
                              .then((pointsList) => getPointsInList(pointsList));
                        }),
                      );
                    }),
                  );
                  showSumGrid = true;
                }
                if (buttonNumber == 1) {
                  normGridData = Future.wait(
                    List.generate(teamAmount, (teamNumber) {
                      return getListOfPointsForDiscipline(teamNumber + 1);
                    }),
                  );
                  showNormGrid = true;
                }
                if (buttonNumber == 2) {
                  winnerGridData = getWinner();
                  showWinnerGrid = true;
                }
              });
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if(showResultsPermission) const Icon(Icons.download, color: Colors.black),
              const SizedBox(width: 10),
              Text(showResultsPermission ? "Lade..." : "Noch nicht verfügbar",
                  style: const TextStyle(fontSize: 16, color: Colors.black)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _disciplineGrid(int disciplineNumber) {
    return FutureBuilder<List<List<double>>>(
      future: Future.wait(
        disciplineGridData[disciplineNumber].map((futureList) => futureList).toList(),
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          List<List<double>> data = snapshot.data!;
          return SizedBox(
            width: double.infinity,
            child: DataTable(
              columnSpacing: 2,
              dataRowMinHeight: 40,
              dividerThickness: 0,
              columns: [
                const DataColumn(label: Text("")),
                ...List.generate(
                  teamAmount,
                      (gridColumnLegend) => DataColumn(
                    label: Text("T ${gridColumnLegend + 1}"),
                  ),
                )
              ],
              rows: List.generate(
                teamAmount,
                    (gridRowIndex) => DataRow(
                  cells: [
                    DataCell(Text("T ${gridRowIndex + 1}")),
                    ...List.generate(
                      teamAmount,
                          (teamRowIndex) {
                        if (gridRowIndex == teamRowIndex) {
                          return const DataCell(
                            Text("\\", textAlign: TextAlign.center),
                          );
                        }
                        int shiftedIndex = teamRowIndex;
                        if (teamRowIndex >= gridRowIndex) {
                          shiftedIndex--;
                        }
                        List<double> teamData = data[gridRowIndex];
                        double value = sortValuesByOrder(
                          teamData,
                          getOpponentListByDisciplines(disciplineNumber + 1, gridRowIndex + 1),
                        )[shiftedIndex];
                        return DataCell(getShortScoreText(value));
                      },
                    )
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _disciplineSumGrid() {
    return FutureBuilder<List<List<double>>>(
      future: sumGridData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          List<List<double>> data = snapshot.data!;
          return _buildGridFromData(data);
        }
      },
    );
  }

  Widget _disciplineNormGrid() {
    return FutureBuilder<List<List<double>>>(
      future: normGridData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          List<List<double>> data = snapshot.data!;
          return _buildGridFromNormalizedData(data);
        }
      },
    );
  }

  Widget _winnerGrid() {
    return FutureBuilder<List<double>>(
      future: winnerGridData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          List<double> winnerList = snapshot.data!;
          return DataTable(
            columnSpacing: 10,
            dataRowMinHeight: 40,
            dividerThickness: 0,
            columns: [
              const DataColumn(label: Text("")),
              ...List.generate(
                teamAmount,
                    (teamNum) => DataColumn(label: Text("T ${teamNum + 1}")),
              )
            ],
            rows: [
              DataRow(cells: [
                const DataCell(Text("Punkte:")),
                ...List.generate(
                  teamAmount,
                      (index) => DataCell(Text(winnerList[index].toString())),
                ),
              ]),
            ],
          );
        }
      },
    );
  }

  Widget _buildGridFromData(List<List<double>> data) {
    return DataTable(
      columnSpacing: 2,
      dataRowMinHeight: 40,
      dividerThickness: 0,
      columns: [
        const DataColumn(label: Text("")),
        ...List.generate(
          teamAmount,
              (disciplineNumber) => DataColumn(
            label: Text(
              disciplines[(disciplineNumber + 1).toString()].toString(),
            ),
          ),
        )
      ],
      rows: List.generate(
        teamAmount,
            (columnNumber) => DataRow(
          cells: [
            DataCell(Text("T ${columnNumber + 1}")),
            ...List.generate(
              teamAmount,
                  (rowNumber) {
                if (columnNumber < data.length &&
                    rowNumber < data[columnNumber].length) {
                  return DataCell(
                      Text(data[columnNumber][rowNumber].toString()));
                } else {
                  return const DataCell(Text("N/A"));
                }
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildGridFromNormalizedData(List<List<double>> data) {
    return DataTable(
      columnSpacing: 2,
      dataRowMinHeight: 40,
      dividerThickness: 0,
      columns: [
        const DataColumn(label: Text("")),
        ...List.generate(
          teamAmount,
              (disciplineNumber) => DataColumn(
            label: Text(
              disciplines[(disciplineNumber + 1).toString()].toString(),
            ),
          ),
        )
      ],
      rows: List.generate(
        teamAmount,
            (teamIndex) => DataRow(
          cells: [
            DataCell(Text("T ${teamIndex + 1}")),
            ...List.generate(
              data[teamIndex].length,
                  (disciplineIndex) {
                return DataCell(
                    Text(data[teamIndex][disciplineIndex].toString()));
              },
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Auswertung", style: TextStyle(fontSize: 20)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Discipline Grids
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 20),
              child: Column(
                children:
                List.generate(pairings[0].length, (disciplineNumber) {
                  return ExpansionTile(
                    title: Text(
                        "${disciplines[(disciplineNumber + 1).toString()]}"),
                    children: [_disciplineGrid(disciplineNumber)],
                  );
                }),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              child: Divider(thickness: 3),
            ),
            const Text("Erreichte Punkte der Teams in allen Disziplinen"),
            if (!showSumGrid) _toggleGridButton(0),
            if (showSumGrid) _disciplineSumGrid(),
            const Padding(
              padding: EdgeInsets.only(bottom: 25),
              child: Text("Gemittelte Punkte in allen Disziplinen"),
            ),
            if (!showNormGrid) _toggleGridButton(1),
            if (showNormGrid) _disciplineNormGrid(),
            const Padding(
              padding: EdgeInsets.only(bottom: 25, top: 25),
              child: Text("Sieges Tabelle", style: TextStyle(fontSize: 22)),
            ),
            if (!showWinnerGrid) _toggleGridButton(2),
            if (showWinnerGrid) _winnerGrid(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
