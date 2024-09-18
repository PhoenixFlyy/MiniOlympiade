import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../infos/achievements/achievement_provider.dart';
import '../game/assets.dart';
import '../game/flappy_wue_game.dart';
import 'game_over_screen.dart';

class FlappyMain extends StatelessWidget {
  const FlappyMain({super.key});

  @override
  Widget build(BuildContext context) {
    final game = FlappyWueGame();

    game.onAchievementReached = (String achievementTitle) {
      if (achievementTitle == 'Flappy Chick') {
        context.read<AchievementProvider>().completeAchievementByTitle('Flappy Chick');
      } else if (achievementTitle == 'Flappy Eagle') {
        context.read<AchievementProvider>().completeAchievementByTitle('Flappy Eagle');
      }
    };

    return Scaffold(
      body: GameWidget(
        game: game,
        initialActiveOverlays: const [FlappyMainMenuScreen.id],
        overlayBuilderMap: {
          'mainMenu': (context, _) => FlappyMainMenuScreen(game: game),
          'gameOver': (context, _) => GameOverScreen(game: game),
        },
      ),
    );
  }
}


class FlappyMainMenuScreen extends StatefulWidget {
  final FlappyWueGame game;
  static const String id = 'mainMenu';

  const FlappyMainMenuScreen({super.key, required this.game});

  @override
  State<FlappyMainMenuScreen> createState() => _FlappyMainMenuScreenState();
}

class _FlappyMainMenuScreenState extends State<FlappyMainMenuScreen> {
  String selectedSkin = 'Skin1';

  @override
  Widget build(BuildContext context) {
    widget.game.pauseEngine();

    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          GestureDetector(
            onTap: () {
              widget.game.overlays.remove('mainMenu');
              widget.game.resumeEngine();
            },
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(Assets.menu),
                  fit: BoxFit.cover,
                ),
              ),
              child: Image.asset(Assets.message),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  "Choose your fighter",
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedSkin = 'Skin1';
                          widget.game.bird.setBirdSkin('Skin1');
                        });
                      },
                      child: Image.asset(
                        'assets/images/bird_midflap.png',
                        width: selectedSkin == 'Skin1' ? 120 : 80,
                        height: selectedSkin == 'Skin1' ? 120 : 80,
                      ),
                    ),
                    const SizedBox(width: 30),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedSkin = 'Skin2';
                          widget.game.bird.setBirdSkin('Skin2');
                        });
                      },
                      child: Image.asset(
                        'assets/images/bird_midflap2.png',
                        width: selectedSkin == 'Skin2' ? 120 : 80,
                        height: selectedSkin == 'Skin2' ? 120 : 80,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedSkin = 'Skin3';
                          widget.game.bird.setBirdSkin('Skin3');
                        });
                      },
                      child: Image.asset(
                        'assets/images/bird_midflap3.png',
                        width: selectedSkin == 'Skin3' ? 120 : 80,
                        height: selectedSkin == 'Skin3' ? 120 : 80,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}