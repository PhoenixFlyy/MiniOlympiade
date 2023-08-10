import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:winter_olympiade/MainMenu.dart';
import 'package:winter_olympiade/utils/MatchDetails.dart';

class TeamSelection extends StatefulWidget {
  const TeamSelection({super.key});

  @override
  State<TeamSelection> createState() => _TeamSelectionState();
}

class _TeamSelectionState extends State<TeamSelection> {
  int selectedTeam = 0;
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Wrap(
            spacing: 8.0,
            children: _buildTeamChips(),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              controller: teamNameController,
            ),
          ),
          FilledButton(
            onPressed: teamName.isNotEmpty && selectedTeam != 0
                ? () async {
              SharedPreferences prefs =
              await SharedPreferences.getInstance();
              prefs.setInt('selectedTeam', selectedTeam);
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
    );
  }

  List<Widget> _buildTeamChips() {
    int numberOfTeams = pairings[0].length;

    return List.generate(numberOfTeams, (teamIndex) {
      int teamNumber = teamIndex + 1;
      bool isSelected = selectedTeam == teamNumber;

      return ChoiceChip(
        label: Text('Team $teamNumber'),
        selected: isSelected,
        onSelected: (bool value) {
          setState(() {
            selectedTeam = value ? teamNumber : 0;
          });
        },
      );
    });
  }
}

