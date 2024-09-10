import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:olympiade/wuecade/components/clouds.dart';

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
  Function? onAchievementReached;

  @override
  Future<void> onLoad() async {
    addAll([
      Background(),
      Clouds(),
      Ground(),
      bird = Bird(),
      score = buildScore(),
    ]);

    interval.onTick = () => add(PipeGroup());
  }

  TextComponent buildScore() {
    return TextComponent(
        position: Vector2(size.x / 2, size.y / 2 * 0.2),
        anchor: Anchor.center,
        textRenderer: TextPaint(
          style: const TextStyle(fontSize: 40, fontFamily: 'Game', fontWeight: FontWeight.bold, color: Colors.black),
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

    score.text = 'Score: ${bird.score}';
  }

  void checkAchievements() {
    if (bird.score == 10) {
      onAchievementReached?.call('Flappy Chick');
    }

    if (bird.score == 50) {
      onAchievementReached?.call('Flappy Eagle');
    }
  }
}
