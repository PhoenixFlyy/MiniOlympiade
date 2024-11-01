import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import '../game/assets.dart';
import '../game/configuration.dart';
import '../game/flappy_wue_game.dart';
import '../game/pipe_position.dart';

class Pipe extends SpriteComponent with HasGameRef<FlappyWueGame> {
  Pipe({
    required this.pipePosition,
    required this.height,
  });

  @override
  final double height;
  final PipePosition pipePosition;

  @override
  Future<void> onLoad() async {
    final pipe = await Flame.images.load(Assets.pipe);
    final pipeRotated = await Flame.images.load(Assets.pipeRotated);
    size = Vector2(50, height);

    switch (pipePosition) {
      case PipePosition.top:
        position.y = 0;
        sprite = Sprite(pipeRotated);
        break;
      case PipePosition.bottom:
        position.y = gameRef.size.y - size.y - Config.groundHeight;
        sprite = Sprite(pipe);
        break;
    }

    if (gameRef.isExpertMode) {
      paint = Paint()..colorFilter = const ColorFilter.mode(Colors.red, BlendMode.modulate);
    }

    add(RectangleHitbox());
  }
}