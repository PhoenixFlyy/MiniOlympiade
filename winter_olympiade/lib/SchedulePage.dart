import 'package:flutter/material.dart';

class SchedulePage extends StatelessWidget {
  final List<List<String>> pairings;
  final Map<String, String> disciplines;

  const SchedulePage(
      {super.key, required this.pairings, required this.disciplines});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laufplan'),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: DataTable(
          columnSpacing: 12,
          dataRowMinHeight: 40,
          headingRowHeight: 50,
          headingTextStyle: const TextStyle(fontSize: 10),
          dataTextStyle: const TextStyle(fontSize: 10),
          dividerThickness: 2,
          columns: List<DataColumn>.generate(
            7,
            (index) {
              if (index == 0) {
                return const DataColumn(label: Text('Runde'));
              }
              return DataColumn(
                  label: Text(
                      disciplines[index.toString()] ?? 'Disziplin $index'));
            },
          ),
          rows: List<DataRow>.generate(
            pairings.length,
            (rowIndex) {
              return DataRow(
                cells: List<DataCell>.generate(
                  pairings[rowIndex].length + 1,
                  (cellIndex) {
                    if (cellIndex == 0) {
                      return DataCell(Text('Runde ${rowIndex + 1}'));
                    }
                    return DataCell(
                      Text(pairings[rowIndex][cellIndex - 1]),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
