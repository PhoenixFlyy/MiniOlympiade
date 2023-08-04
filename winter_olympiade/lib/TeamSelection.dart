import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:winter_olympiade/MainMenu.dart';

class TeamSelection extends StatefulWidget {
  const TeamSelection({super.key});

  @override
  State<TeamSelection> createState() => _TeamSelectionState();
}

class _TeamSelectionState extends State<TeamSelection> {
  String selectedTeam = '';

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
              children: _buildTeamChips(),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                String storedSelectedTeam = prefs.getString('selectedTeam') ?? '';
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => mainMenu(),
                  ),
                );
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
        onSelected: (bool value) async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          setState(() {
            selectedTeam = value ? team : '';
            prefs.setString('selectedTeam', selectedTeam);
          });
        },
      );
    }).toList();
  }
}
