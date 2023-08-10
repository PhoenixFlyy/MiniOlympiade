import 'package:flutter/material.dart';

class SchedulePage extends StatelessWidget {
  final List<List<String>> pairings;
  final Map<String, String> disciplines;
  final int currentRowForColor;

  const SchedulePage({
    Key? key,
    required this.pairings,
    required this.disciplines,
    required this.currentRowForColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laufplan'),
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
            minWidth: MediaQuery.of(context).size.width,
          ),
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
                    disciplines[index.toString()] ?? 'Disziplin $index',
                  ),
                );
              },
            ),
            rows: List<DataRow>.generate(
              pairings.length,
              (rowIndex) {
                final isSpecialRow = rowIndex == currentRowForColor - 1;
                final backgroundColor =
                    isSpecialRow ? Colors.blue : Colors.transparent;

                return DataRow(
                  color: MaterialStateProperty.all<Color>(backgroundColor),
                  cells: List<DataCell>.generate(
                    pairings[rowIndex].length + 1,
                    (cellIndex) {
                      if (cellIndex == 0) {
                        return DataCell(Text('Runde ${rowIndex + 1}'));
                      }
                      return DataCell(
                        Text(pairings[rowIndex][cellIndex - 1],
                            style: const TextStyle(fontSize: 16)),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
