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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 20),
              child: Column(
                  children:
                      List.generate(pairings[0].length, (disciplineNumber) {
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
                                label: Text(
                              "T ${playerNumber1 + 1}",
                            )),
                          )
                        ],
                        rows: List.generate(
                          amountOfPlayer,
                          (playerNumber2) => DataRow(
                            cells: [
                              DataCell(Text("T ${playerNumber2 + 1}")),
                              ...List.generate(
                                amountOfPlayer,
                                (playerNumber3) {
                                  if (playerNumber2 == playerNumber3) {
                                    return const DataCell(Text("\\",
                                        textAlign: TextAlign.center));
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
                                        return const Text("X");
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                      child: Divider(thickness: 3),
                    ),
                  ],
                );
              })),
            ),
            const Text("Erreichte Punkte der Teams in allen Disziplinen"),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 25),
              child: ConstrainedBox(
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
                      (disciplineNumber) => DataColumn(
                          label: Text(
                              disciplines[(disciplineNumber + 1).toString()]
                                  .toString())),
                    )
                  ],
                  rows: List.generate(
                    amountOfPlayer,
                    (columnNumber) => DataRow(
                      cells: [
                        DataCell(Text("T ${columnNumber + 1}")),
                        ...List.generate(
                          amountOfPlayer,
                          (rowNumber) {
                            return DataCell(FutureBuilder(
                              future: getAllTeamPointsInDisciplineSortedByMatch(
                                  rowNumber + 1, columnNumber + 1),
                              builder: (BuildContext context,
                                  AsyncSnapshot<List<double>> snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Text("X");
                                } else if (snapshot.hasError) {
                                  return const Text("ERROR");
                                } else {
                                  return Text(getPointsInList(snapshot.data!)
                                      .toString());
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
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 25),
              child: Text("Gemittelte Punkte in allen Disziplinen"),
            ),
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
                    (disciplineNumber) => DataColumn(
                        label: Text(
                            disciplines[(disciplineNumber + 1).toString()]
                                .toString())),
                  )
                ],
                rows: List.generate(
                  amountOfPlayer,
                  (columnNumber) => DataRow(
                    cells: [
                      DataCell(Text("T ${columnNumber + 1}")),
                      ...List.generate(
                        amountOfPlayer,
                        (rowNumber) {
                          return DataCell(FutureBuilder(
                            future: getListOfPointsForDiscipline(rowNumber + 1),
                            builder: (BuildContext context,
                                AsyncSnapshot<List<double>> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Text("X");
                              } else if (snapshot.hasError) {
                                return const Text("Error");
                              } else {
                                return Text(getPointsForDiscipline(
                                        snapshot.data!)[columnNumber]
                                    .toString());
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
              padding: EdgeInsets.only(bottom: 25, top: 25),
              child: Text("Sieges Tabelle", style: TextStyle(fontSize: 22)),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width,
                maxWidth: MediaQuery.of(context).size.width,
              ),
              child: FutureBuilder<List<double>>(
                future: getWinner(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    List<double> winnerList = snapshot.data!;
                    return DataTable(
                      columnSpacing: 2,
                      dataRowMinHeight: 40,
                      dividerThickness: 0,
                      columns: [
                        const DataColumn(label: Text("")),
                        ...List.generate(
                          amountOfPlayer,
                          (teamNum) =>
                              DataColumn(label: Text("Team ${teamNum + 1}")),
                        )
                      ],
                      rows: [
                        DataRow(cells: [
                          const DataCell(Text("Punkte:")),
                          ...List.generate(
                            amountOfPlayer,
                            (index) =>
                                DataCell(Text(winnerList[index].toString())),
                          ),
                        ]),
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
