import 'package:flutter/material.dart';
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
                      DataColumn(label: Text("X")), // Empty column for shifting
                      ...List.generate(
                        amountOfPlayer,
                        (playerNumber1) =>
                            DataColumn(label: Text("A ${playerNumber1 + 1}")),
                      )
                    ],
                    rows: List.generate(
                      amountOfPlayer,
                      (playerNumber2) => DataRow(
                        cells: [
                          DataCell(Text("Y")), // Empty cell for shifting
                          ...List.generate(
                            amountOfPlayer,
                            (playerNumber3) =>
                                DataCell(Text("B ${playerNumber2 + 1}")),
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
