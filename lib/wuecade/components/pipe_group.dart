import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:olympiade/wuecade/components/pipe.dart';
import '../game/assets.dart';
import '../game/configuration.dart';
import '../game/flappy_wue_game.dart';
import '../game/pipe_position.dart';

class PipeGroup extends PositionComponent with HasGameRef<FlappyWueGame> {
  final Function(String)? onAchievementReached;

  PipeGroup({this.onAchievementReached});

  final _random = Random();

  @override
  Future<void> onLoad() async {
    position.x = gameRef.size.x;

    final heightMinusGround = gameRef.size.y - Config.groundHeight;

    final spacing = Config.minPipeSpacing + _random.nextDouble();

    final minCenterY = Config.minPipeHeight + (spacing / 2);
    final maxCenterY = heightMinusGround - Config.minPipeHeight - (spacing / 2);

    final centerY = minCenterY + _random.nextDouble() * (maxCenterY - minCenterY);

    addAll([
      Pipe(pipePosition: PipePosition.top, height: centerY - (spacing / 2)),
      Pipe(pipePosition: PipePosition.bottom, height: heightMinusGround - (centerY + (spacing / 2))),
    ]);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x -= Config.gameSpeed * dt;

    if (position.x < -30) {
      removeFromParent();
      updateScore();
    }

    if (gameRef.isHit) {
      removeFromParent();
      gameRef.isHit = false;
    }
  }

  void updateScore() {
    gameRef.bird.score += 1;
    FlameAudio.play(Assets.point);
    if (gameRef.bird.score == 10) {
      onAchievementReached?.call('Flappy Chick');
    }

    if (gameRef.bird.score == 50) {
      onAchievementReached?.call('Flappy Eagle');
    }
  }
}