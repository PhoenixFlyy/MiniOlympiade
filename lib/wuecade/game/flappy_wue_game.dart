import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:olympiade/wuecade/game/assets.dart';

import '../components/background.dart';
import '../components/bird.dart';
import '../components/ground.dart';
import '../components/pipe_group.dart';
import 'configuration.dart';

class FlappyWueGame extends FlameGame with TapDetector, HasCollisionDetection {
  FlappyWueGame();

  late Bird bird;
  Timer interval = Timer(Config.pipeInterval, repeat: true);
  bool isHit = false;
  late TextComponent score;
  late TextComponent multiplier;
  Function(String)? onAchievementReached;
  bool isExpertMode = false;

  double gameSpeed = Config.gameSpeed;
  double minPipeHeight = Config.minPipeHeight;
  double minPipeSpacing = Config.minPipeSpacing;

  @override
  Future<void> onLoad() async {
    addAll([
      Background(),
      Ground(),
      bird = Bird(),
      score = buildScore(),
      multiplier = buildMultiplier(),
    ]);

    interval.onTick = () => add(PipeGroup(onAchievementReached: onAchievementReached));
  }

  void updateGameMode() {
    if (isExpertMode) {
      minPipeHeight = Config.expertMinPipeHeight;
      minPipeSpacing = Config.expertMinPipeSpacing;
    } else {
      gameSpeed = Config.gameSpeed;
      minPipeHeight = Config.minPipeHeight;
      minPipeSpacing = Config.minPipeSpacing;
    }
  }

  void increaseGameSpeed() {
    if (isExpertMode) {
      gameSpeed *= 1.02;
    }
  }
  
  void resetGameSpeed() {
    gameSpeed = Config.gameSpeed;
  }

  TextComponent buildScore() {
    return TextComponent(
        position: Vector2(size.x / 2, size.y / 2 * 0.2),
        anchor: Anchor.center,
        textRenderer: TextPaint(
          style: const TextStyle(fontSize: 40, fontFamily: Assets.gameFont, fontWeight: FontWeight.bold, color: Colors.black),
        ));
  }

  TextComponent buildMultiplier() {
    return TextComponent(
        position: Vector2(size.x / 2, size.y / 2 * 0.3),
        anchor: Anchor.center,
        textRenderer: TextPaint(
          style: const TextStyle(fontSize: 25, fontFamily: Assets.gameFont, color: Colors.black),
        ));
  }

  @override
  void onTap() {
    bird.fly();
  }

  @override
  void update(double dt) {
    super.update(dt);
    interval.update(dt);

    if (isHit) {
      score.text = '';
      multiplier.text = '';
    } else {
      score.text = 'Score: ${bird.score}';
      multiplier.text = isExpertMode ? 'Multiplier: x${(gameSpeed / Config.gameSpeed).toStringAsFixed(2)}' : '';
    }
  }
}