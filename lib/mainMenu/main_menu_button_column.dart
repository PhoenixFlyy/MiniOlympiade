import 'package:flutter/material.dart';
import 'package:olympiade/mainMenu/activity_button.dart';
import 'package:olympiade/setup/result_screen.dart';

import '../dice/dice_game.dart';
import '../games/Dart/darts_start_screen.dart';
import '../games/chess_timer.dart';
import '../infos/soundboard.dart';
import '../setup/upload_points_screen.dart';
import '../wuecade/screens/main_menu_screen.dart';

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
      padding: const EdgeInsets.only(top: 30),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Aktivitäten", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[350]!)),
          ActivityButton(
            name: "Punktestand",
            description: "Trage die Spielergebnisse schnell und einfach ein",
            iconWidget: const Icon(Icons.upload),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => UploadResults(currentRound: currentRound, teamNumber: selectedTeam))),
          ),
          ActivityButton(
              name: "Darts",
              description: "Klassisches X01 Gameplay mit Einzel- oder Double-Out-Optionen",
              iconWidget: const Icon(Icons.sports_esports),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const DartStartScreen()))),
          ActivityButton(
              name: "Schachuhr",
              description: "Eine Schachuhr, um in Jenga die Zeit zu tracken",
              iconWidget: const Icon(Icons.access_time),
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => ChessTimer(maxTime: maxChessTime.inSeconds)))),
          ActivityButton(
            name: "Soundboard",
            description: "Spiele eine Auswahl an Tönen und Sounds ab",
            iconWidget: const Icon(Icons.music_note),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SoundBoard())),
          ),
          ActivityButton(
            name: "Wuecade Games",
            description: "Spiele FlappyBirds im Olympiaden- und Würzburg-Stil",
            iconWidget: const Icon(Icons.gamepad),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const FlappyMain())),
          ),
          ActivityButton(
              name: "Würfel",
              description: "Würfle und lass das Glück entscheiden",
              iconWidget: const Icon(Icons.casino),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const DiceGame()))
          ),
          ActivityButton(
              name: "Auswertung",
              description: "Anzeige und Auswertung aller Disziplinen Ergebnisse",
              iconWidget: const Icon(Icons.download),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ResultScreen()))
          ),
        ]),
      ),
    );
  }
}