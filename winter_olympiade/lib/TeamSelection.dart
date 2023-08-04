import 'package:flutter/material.dart';
import 'main_menu.dart';

class TeamSelection extends StatefulWidget {
  const TeamSelection({super.key});

  @override
  State<TeamSelection> createState() => _TeamSelectionState();
}

class _TeamSelectionState extends State<TeamSelection> {
  String selectedTeam = ''; // Hier kannst du das ausgewählte Team speichern

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Team Auswahl'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Wrap(
              spacing: 8.0,
              children: _buildTeamChips(), // Methode, um Chips zu erstellen
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (context) =>
                            MainMenu()));
              },
              child: Text('Zum Hauptmenü'),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTeamChips() {
    List<String> teams = [
      'Team 1',
      'Team 2',
      'Team 3',
      'Team 4',
      'Team 5',
      'Team 6'
    ];

    return teams.map((team) {
      bool isSelected = selectedTeam == team;

      return ChoiceChip(
        label: Text(team),
        selected: isSelected,
        onSelected: (bool value) {
          setState(() {
            selectedTeam =
                value ? team : ''; // Auswähltes Team setzen oder leeren
          });
        },
      );
    }).toList();
  }
}
