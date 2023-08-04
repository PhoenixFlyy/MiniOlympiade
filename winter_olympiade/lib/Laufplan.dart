import 'package:flutter/material.dart';

class Laufplan extends StatefulWidget {
  const Laufplan({Key? key}) : super(key: key);

  @override
  State<Laufplan> createState() => _LaufplanState();
}

class _LaufplanState extends State<Laufplan> {
  List<List<String>> pairings = [
      ['1-6', '3-4', '2-5', '', '', ''],
      ['', '', '', '4-2', '1-5', '6-3'],
      ['3-2', '6-5', '1-4', '', '', ''],
      ['', '', '', '3-5', '4-6', '2-1'],
      ['5-4', '3-1', '6-2', '', '', ''],
      ['', '', '', '6-1', '3-4', '5-2'],
      ['6-3', '2-4', '5-1', '', '', ''],
      ['', '', '', '2-3', '5-6', '4-1'],
      ['2-1', '5-3', '4-6', '', '', ''],
      ['', '', '', '4-5', '1-3', '2-6'],
      ['5-2', '1-6', '3-4', '', '', ''],
      ['', '', '', '6-3', '2-4', '1-5'],
      ['4-1', '3-2', '5-6', '', '', ''],
      ['', '', '', '1-2', '3-5', '4-6'],
      ['2-6', '5-4', '1-3', '', '', ''],
      ['', '', '', '2-5', '1-6', '3-4'],
      ['1-5', '6-3', '4-2', '', '', ''],
      ['', '', '', '1-4', '2-3', '6-5'],
      ['4-6', '2-1', '3-5', '', '', ''],
      ['', '', '', '6-2', '4-5', '1-3'],
      ['3-4', '5-2', '6-1', '', '', ''],
      ['', '', '', '5-1', '3-6', '2-4'],
      ['6-5', '4-1', '2-3', '', '', ''],
      ['', '', '', '4-6', '1-2', '5-3'],
      ['3-1', '2-6', '4-5', '', '', ''],
      ['', '', '', '3-4', '2-5', '1-6'],
      ['2-4', '1-5', '6-3', '', '', ''],
      ['', '', '', '5-6', '1-4', '3-2'],
      ['5-3', '4-6', '1-2', '', '', ''],
      ['', '', '', '1-3', '2-6', '5-4']

    // ... Weitere Zeilen ...
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Laufplan'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            columns: List.generate(
              7,
                  (index) {
                if (index == 0) {
                  return DataColumn(label: Text('Runde'));
                }
                return DataColumn(label: Text('Disziplin $index'));
              },
            ),
            rows: List.generate(
              pairings.length,
                  (rowIndex) {
                return DataRow(
                  cells: List.generate(
                    pairings[rowIndex].length + 1,
                        (cellIndex) {
                      if (cellIndex == 0) {
                        return DataCell(Text('Runde ${rowIndex + 1}'));
                      }
                      return DataCell(
                        TextFormField(
                          initialValue: pairings[rowIndex][cellIndex - 1],
                          onChanged: (value) {
                            setState(() {
                              pairings[rowIndex][cellIndex - 1] = value;
                            });
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.all(8),
                          ),
                          textAlign: TextAlign.center,
                        ),
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

void main() {
  runApp(MaterialApp(home: Laufplan()));
}
