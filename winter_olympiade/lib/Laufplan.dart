import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // Diese Methode sollte innerhalb des _LaufplanState sein
  Future<String> getSelectedTeamMatch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String selectedTeam = prefs.getString('selectedTeam') ?? '';


    String? currentGame;
    for (List<String> round in pairings) {
      for (String game in round) {
        if (game.contains(selectedTeam)) {
          currentGame = game;
          break;
        }
      }
      if (currentGame != null) {
        break;
      }
    }

    // Hier wird geprüft, ob ein Spiel gefunden wurde und entsprechend ein String zurückgegeben
    if (currentGame != null) {
      return 'Team´s Match: $currentGame';
    } else {
      return 'No match found for selected team';
    }
  }

  Future<void> setSelectedTeamMatch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String selectedTeam = prefs.getString('selectedTeam') ?? '';

    String? currentGame;
    int? roundIndex;
    int? matchIndex;
    for (int i = 0; i < pairings.length; i++) {
      for (int j = 0; j < pairings[i].length; j++) {
        if (pairings[i][j].contains(selectedTeam)) {
          currentGame = pairings[i][j];
          roundIndex = i;
          matchIndex = j;
          break;
        }
      }
      if (currentGame != null) {
        break;
      }
    }

    // Hier wird geprüft, ob ein Spiel gefunden wurde und entsprechend die SharedPreferences gesetzt
    if (currentGame != null && roundIndex != null && matchIndex != null) {
      // Zerlegen Sie das Spiel in die beiden Teams und finden Sie das gegnerische Team
      List<String> teams = currentGame.split('-');
      String opponent = teams.first == selectedTeam ? teams.last : teams.first;

      // Disziplin ist der matchIndex (plus 1, weil wir bei 1 und nicht bei 0 anfangen) und Runde ist der roundIndex (plus 1, weil wir bei 1 und nicht bei 0 anfangen)
      int discipline = matchIndex + 1;
      int round = roundIndex + 1;

      prefs.setString('opponent', opponent);
      prefs.setInt('discipline', discipline);
      prefs.setInt('round', round);
    } else {
      prefs.remove('opponent');
      prefs.remove('discipline');
      prefs.remove('round');
    }
  }


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
