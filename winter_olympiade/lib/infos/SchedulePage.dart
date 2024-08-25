import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:olympiade/infos/achievements/achievement_provider.dart';

class SchedulePage extends StatefulWidget {
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
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  Timer? _timer;
  int _secondsSpent = 0;

  @override
  void initState() {
    super.initState();
    // Starte den Timer, wenn die Seite betreten wird
    _startTimer();
  }

  @override
  void dispose() {
    // Stoppe den Timer, wenn die Seite verlassen wird
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _secondsSpent++;

      if (_secondsSpent >= 60) {
        // Achievement freigeben
        context.read<AchievementProvider>().completeAchievementByTitle('Verlaufen?');

        // Stoppe den Timer, da das Achievement freigegeben wurde
        _timer?.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
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
                    widget.disciplines[index.toString()] ?? 'Disziplin $index',
                  ),
                );
              },
            ),
            rows: List<DataRow>.generate(
              widget.pairings.length,
                  (rowIndex) {
                final isSpecialRow = rowIndex == widget.currentRowForColor - 1;
                final backgroundColor =
                isSpecialRow ? Colors.blue : Colors.transparent;

                return DataRow(
                  color: MaterialStateProperty.all<Color>(backgroundColor),
                  cells: List<DataCell>.generate(
                    widget.pairings[rowIndex].length + 1,
                        (cellIndex) {
                      if (cellIndex == 0) {
                        return DataCell(Text('Runde ${rowIndex + 1}'));
                      }
                      return DataCell(
                        Text(widget.pairings[rowIndex][cellIndex - 1],
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
