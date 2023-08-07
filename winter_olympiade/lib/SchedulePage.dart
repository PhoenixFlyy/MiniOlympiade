import 'package:flutter/material.dart';

class SchedulePage extends StatelessWidget {
  final List<List<String>> pairings;
  final Map<String, String> disciplines;

  SchedulePage({required this.pairings, required this.disciplines});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Laufplan'),
      ),
      body: InteractiveViewer(
        minScale: 0.5,
        maxScale: 2.0,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: DataTable(
              columnSpacing: 12,  // Reduziert den Spaltenabstand
              dataRowHeight: 40,  // Reduziert die Zeilenhöhe
              headingRowHeight: 50, // Reduziert die Höhe der Überschriftszeile
              headingTextStyle: TextStyle(fontSize: 10),  // Reduziert die Schriftgröße der Überschrift
              dataTextStyle: TextStyle(fontSize: 10),  // Reduziert die Schriftgröße der Daten
              dividerThickness: 2,  // Erhöht die Dicke der Trennlinien
              columns: List<DataColumn>.generate(
                7,
                    (index) {
                  if (index == 0) {
                    return DataColumn(label: Text('Runde'));
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
        ),
      ),
    );
  }
}
