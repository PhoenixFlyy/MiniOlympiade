import 'package:flutter/material.dart';
import 'package:winter_olympiade/utils/GetMatchDetails.dart';
import 'package:winter_olympiade/utils/MatchDetails.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black12,
        title: const Text("Ergebnis", style: TextStyle(fontSize: 20)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
              children: List.generate(pairings[0].length, (disciplineNumber) {
            return Column(
              children: [
                Text(
                    "Discipline: ${disciplines[(disciplineNumber + 1).toString()]}"),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width,
                    maxWidth: MediaQuery.of(context).size.width,
                  ),
                  child: DataTable(
                    columnSpacing: 2,
                    dataRowMinHeight: 40,
                    dividerThickness: 0,
                    columns: [
                      const DataColumn(label: Text("")),
                      ...List.generate(
                        amountOfPlayer,
                        (playerNumber1) => DataColumn(
                            label: Text("Team ${playerNumber1 + 1}")),
                      )
                    ],
                    rows: List.generate(
                      amountOfPlayer,
                      (playerNumber2) => DataRow(
                        cells: [
                          DataCell(Text("Team ${playerNumber2 + 1}")),
                          ...List.generate(
                            amountOfPlayer,
                            (playerNumber3) {
                              if (playerNumber2 == playerNumber3) {
                                return const DataCell(
                                    Text("\\", textAlign: TextAlign.center));
                              }
                              return DataCell(FutureBuilder(
                                future:
                                    getAllTeamPointsInDisciplineSortedByMatch(
                                        disciplineNumber + 1,
                                        playerNumber2 + 1),
                                builder: (BuildContext context,
                                    AsyncSnapshot<List<double>> snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return const Text("ERROR");
                                  } else {
                                    if (snapshot.data != null) {
                                      int shiftedIndex = playerNumber3;
                                      if (playerNumber3 >= playerNumber2) {
                                        shiftedIndex--;
                                      }
                                      return Text(sortValuesByOrder(
                                              snapshot.data!,
                                              getOpponentListByDisciplines(
                                                  disciplineNumber + 1,
                                                  playerNumber2 +
                                                      1))[shiftedIndex]
                                          .toString());
                                    } else {
                                      return Container();
                                    }
                                  }
                                },
                              ));
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  child: Divider(thickness: 3),
                ),
              ],
            );
          })),
        ),
      ),
    );
  }
}
