import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'MainMenu.dart';
import 'utils/MatchData.dart';

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
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/background1.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Wrap(
                spacing: 8.0,
                children: _buildTeamChips(),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: TextField(
                  controller: teamNameController,
                  decoration: InputDecoration(
                    hintText: 'Gebe deinen (Team) Namen ein',
                    filled: true,
                    fillColor: Colors.black,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.all(16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: teamName.isNotEmpty && selectedTeam != 0
                      ? () async {
                    SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                    prefs.setInt('selectedTeam', selectedTeam);
                    prefs.setString('teamName', teamName);
                    if (context.mounted) {
                      HapticFeedback.heavyImpact();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const MainMenu(),
                        ),
                      );
                    }
                  }
                      : null,
                  child: const Text(
                    'Bestätigen',
                    style: TextStyle(
                      color: Colors.white, // Text color
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTeamChips() {
    return List.generate(amountOfPlayer, (teamIndex) {
      int teamNumber = teamIndex + 1;
      bool isSelected = selectedTeam == teamNumber;

      return ChoiceChip(
        label: Text('Team $teamNumber'),
        selected: isSelected,
        onSelected: (bool value) {
          HapticFeedback.lightImpact();
          setState(() {
            selectedTeam = value ? teamNumber : 0;
          });
        },
      );
    });
  }
}
