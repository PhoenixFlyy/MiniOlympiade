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
  bool scoreUpdated = false;

  @override
  Future<void> onLoad() async {
    position.x = gameRef.size.x;

    final heightMinusGround = gameRef.size.y - Config.groundHeight;

    final spacing = gameRef.minPipeSpacing + _random.nextDouble() * 50.0;

    final minCenterY = gameRef.minPipeHeight + (spacing / 2);
    final maxCenterY = heightMinusGround - gameRef.minPipeHeight - (spacing / 2);

    final centerY = minCenterY + _random.nextDouble() * (maxCenterY - minCenterY);

    addAll([
      Pipe(pipePosition: PipePosition.top, height: centerY - (spacing / 2)),
      Pipe(pipePosition: PipePosition.bottom, height: heightMinusGround - (centerY + (spacing / 2))),
    ]);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x -= gameRef.gameSpeed * dt;

    if (!scoreUpdated && position.x <= 50) {
      scoreUpdated = true;
      updateScore();
    }

    if (position.x < -30) {
      removeFromParent();
    }

    if (gameRef.isHit) {
      removeFromParent();
      gameRef.isHit = false;
    }
  }

  void updateScore() {
    gameRef.bird.score += 1;
    FlameAudio.play(Assets.point);
    if (gameRef.isExpertMode) {
      gameRef.increaseGameSpeed();
    }

    if (gameRef.bird.score == 10) {
      onAchievementReached?.call('Flappy Chick');
    }

    if (gameRef.bird.score == 50) {
      onAchievementReached?.call('Flappy Eagle');
    }
  }
}