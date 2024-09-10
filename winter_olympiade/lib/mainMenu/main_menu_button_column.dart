import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../games/Dart/darts_start_screen.dart';
import '../games/chess_timer.dart';
import '../infos/achievements/achievement_provider.dart';
import '../infos/achievements/achievement_screen.dart';
import '../infos/rules.dart';
import '../infos/schedule_page.dart';
import '../setup/upload_points_screen.dart';
import '../utils/match_data.dart';
import '../wuecade/screens/main_menu_screen.dart';
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
              text: "Ergebnisse eintragen",
              icon: Icons.edit,
              onPressed: () {
                HapticFeedback.mediumImpact();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UploadResults(currentRound: currentRound, teamNumber: selectedTeam),
                    ));
              },
              withShimmer: true,
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                MainMenuButton(
                    text: "Regeln",
                    icon: Icons.rule,
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      context.read<AchievementProvider>().completeAchievementByTitle('Nimm es ganz genau!');
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RulesScreen(),
                          ));
                    },
                    bottomPadding: false,
                    rightPadding: true,
                    fontSize: 14,
                    heroTag: "rulesHero"),
                MainMenuButton(
                    text: "Laufplan",
                    icon: Icons.directions_run,
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SchedulePage(
                              pairings: pairings,
                              disciplines: disciplines,
                              currentRowForColor: currentRound,
                            ),
                          ));
                    },
                    bottomPadding: false,
                    rightPadding: true,
                    fontSize: 14,
                    heroTag: "scheduleHero"),
                MainMenuButton(
                  text: "Achievements",
                  icon: Icons.emoji_events,
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AchievementScreen(),
                        ));
                  },
                  bottomPadding: false,
                  rightPadding: true,
                  fontSize: 14,
                  heroTag: "achievementHero",
                ),
                MainMenuButton(
                  text: "Wuecade Games",
                  icon: Icons.gamepad,
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FlappyMain(),
                        ));
                  },
                  bottomPadding: false,
                  rightPadding: false,
                  fontSize: 14,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
