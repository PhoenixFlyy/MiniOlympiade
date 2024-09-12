import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:olympiade/infos/achievements/achievement_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/match_data.dart';

class SchedulePage extends StatefulWidget {
  final int currentRound;

  const SchedulePage({
    super.key,
    required this.currentRound,
  });

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  Timer? _timer;
  int _secondsSpent = 0;
  late int selectedTeam = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _loadSelectedTeam();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _secondsSpent++;

      if (_secondsSpent >= 60) {
        context.read<AchievementProvider>().completeAchievementByTitle('Verlaufen?');
        _timer?.cancel();
      }
    });
  }

  Future<void> _loadSelectedTeam() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() => selectedTeam = prefs.getInt('selectedTeam') ?? 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                final isSpecialRow = rowIndex == widget.currentRound - 1;
                final backgroundColor =
                isSpecialRow ? Colors.blue : Colors.transparent;

                return DataRow(
                  color: WidgetStateProperty.all<Color>(backgroundColor),
                  cells: List<DataCell>.generate(
                    pairings[rowIndex].length + 1,
                        (cellIndex) {
                      if (cellIndex == 0) {
                        return DataCell(Text('Runde ${rowIndex + 1}'));
                      }
                      final isSpecialCell = isSpecialRow && pairings[rowIndex][cellIndex - 1].contains(selectedTeam.toString());
                      return DataCell(
                        Text(
                            pairings[rowIndex][cellIndex - 1],
                            style: TextStyle(
                                fontWeight: isSpecialCell ? FontWeight.bold : null,
                                fontSize: 16,
                                color: isSpecialCell ? Colors.amber : Colors.white
                            )
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