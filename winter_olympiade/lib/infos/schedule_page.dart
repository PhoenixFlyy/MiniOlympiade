import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:olympiade/infos/achievements/achievement_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SchedulePage extends StatefulWidget {
  final List<List<String>> pairings;
  final Map<String, String> disciplines;
  final int currentRowForColor;

  const SchedulePage({
    super.key,
    required this.pairings,
    required this.disciplines,
    required this.currentRowForColor,
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Hero(
            tag: "scheduleHero",
            child: Text(
                'Laufplan  -  Team $selectedTeam',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.normal,
                  fontStyle: FontStyle.normal,
                  letterSpacing: 0.0,
                  wordSpacing: 0.0,
                  decoration: TextDecoration.none,
                  decorationColor: Colors.transparent,
                  decorationStyle: TextDecorationStyle.solid,
                  fontFamily: null,
                  height: 1.0,
                )
            )),
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
                  color: WidgetStateProperty.all<Color>(backgroundColor),
                  cells: List<DataCell>.generate(
                    widget.pairings[rowIndex].length + 1,
                        (cellIndex) {
                      if (cellIndex == 0) {
                        return DataCell(Text('Runde ${rowIndex + 1}'));
                      }
                      final isSpecialCell = isSpecialRow && widget.pairings[rowIndex][cellIndex - 1].contains(selectedTeam.toString());
                      return DataCell(
                        Text(
                            widget.pairings[rowIndex][cellIndex - 1],
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