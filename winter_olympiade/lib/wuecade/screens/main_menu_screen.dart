import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../game/assets.dart';
import '../game/flappy_wue_game.dart';
import 'game_over_screen.dart';

class FlappyMain extends StatelessWidget {
  const FlappyMain({super.key});

  @override
  Widget build(BuildContext context) {
    final game = FlappyWueGame();

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


class FlappyMainMenuScreen extends StatelessWidget {
  final FlappyWueGame game;
  static const String id = 'mainMenu';

  const FlappyMainMenuScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    game.pauseEngine();

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          game.overlays.remove('mainMenu');
          game.resumeEngine();
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(Assets.menu), fit: BoxFit.cover)),
          child: Image.asset(Assets.message),
        ),
      ),
    );
  }
}
