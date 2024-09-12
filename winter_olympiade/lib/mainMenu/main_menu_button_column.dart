import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../games/Dart/darts_start_screen.dart';
import '../games/chess_timer.dart';
import '../setup/upload_points_screen.dart';
import 'main_menu_button.dart';

class MainButtonColumn extends StatelessWidget {
  final int currentRound;
  final int selectedTeam;
  final Duration maxChessTime;

  const MainButtonColumn({
    super.key,
    required this.currentRound,
    required this.selectedTeam,
    required this.maxChessTime,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        children: [
          MainMenuButton(
              text: "Ergebnisse nachtragen",
              icon: Icons.edit,
              onPressed: () {
                HapticFeedback.mediumImpact();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UploadResults(currentRound: currentRound, teamNumber: selectedTeam),
                    ));
              },
              heroTag: "uploadHero"),
          MainMenuButton(
              text: "Dartsrechner",
              icon: Icons.sports_esports,
              onPressed: () {
                HapticFeedback.mediumImpact();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DartStartScreen(),
                    ));
              },
              heroTag: "dartsHero"),
          MainMenuButton(
              text: "Schachuhr",
              icon: Icons.timer,
              onPressed: () {
                HapticFeedback.mediumImpact();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChessTimer(maxTime: maxChessTime.inSeconds),
                    ));
              },
              heroTag: "ChessClockHero"),
        ],
      ),
    );
  }
}
