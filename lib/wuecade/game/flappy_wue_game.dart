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
  Function(String)? onAchievementReached;
  bool isExpertMode = false;

  double gameSpeed = Config.gameSpeed;
  double minPipeHeight = Config.minPipeHeight;
  double minPipeSpacing = Config.minPipeSpacing;
  double speedIncrease = 0.0;

  @override
  Future<void> onLoad() async {
    if (isExpertMode) {
      gameSpeed = Config.expertSpeed;
      minPipeHeight = Config.expertMinPipeHeight;
      minPipeSpacing = Config.expertMinPipeSpacing;
      speedIncrease = Config.expertSpeedIncrease;
    }

    addAll([
      Background(),
      Ground(),
      bird = Bird(),
      score = buildScore(),
    ]);

    interval.onTick = () => add(PipeGroup(onAchievementReached: onAchievementReached));
  }

  void increaseGameSpeed() {
    if (isExpertMode) {
      gameSpeed += speedIncrease;
    }
  }

  TextComponent buildScore() {
    return TextComponent(
        position: Vector2(size.x / 2, size.y / 2 * 0.2),
        anchor: Anchor.center,
        textRenderer: TextPaint(
          style: const TextStyle(fontSize: 40, fontFamily: Assets.gameFont, fontWeight: FontWeight.bold, color: Colors.black),
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
    } else {
      score.text = '${isExpertMode ? 'Expert ' : ''} Score: ${bird.score}';
    }
  }
}