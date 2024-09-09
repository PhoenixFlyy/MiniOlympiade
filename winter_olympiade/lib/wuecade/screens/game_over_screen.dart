import 'package:flutter/material.dart';
import '../game/assets.dart';
import '../game/flappy_wue_game.dart';

class GameOverScreen extends StatelessWidget {
  final FlappyWueGame game;
  static const String id = 'gameOver';

  const GameOverScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black38,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Score: ${game.bird.score}',
              style: const TextStyle(
                fontSize: 60,
                color: Colors.white,
                fontFamily: 'Game',
              ),
            ),
            Image.asset(Assets.gameOver),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: onRestart,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text(
                  'Restart',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                )),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () => onExit(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                child: const Text(
                  'Exit',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ))
          ],
        ),
      ),
    );
  }

  void onRestart() {
    game.bird.reset();
    game.overlays.remove('gameOver');
    game.resumeEngine();
  }

  void onExit(BuildContext context) {
    game.overlays.remove('gameOver');
    game.pauseEngine();
    Navigator.pop(context);
  }
}