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
  String teamName = "";
  final teamNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    teamNameController.addListener(() {
      setState(() {
        teamName = teamNameController.text;
      });
    });
  }

  @override
  void dispose() {
    teamNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Auswahl'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Wrap(
              spacing: 8.0,
              children: _buildTeamChips(),
            ),
            TextField(
              controller: teamNameController,
            ),
            const Divider(),
            ElevatedButton(
              onPressed: teamName.isNotEmpty && selectedTeam.isNotEmpty
                  ? () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setString('selectedTeam', selectedTeam);
                      prefs.setString('teamName', teamName);
                      if (context.mounted) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const MainMenu(),
                          ),
                        );
                      }
                    }
                  : null,
              child: const Text('Bestätigen'),
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
            selectedTeam = value ? team : '';
          });
        },
      );
    }).toList();
  }
}
