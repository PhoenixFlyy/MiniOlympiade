import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/animation.dart';
import '../game/assets.dart';
import '../game/bird_movement.dart';
import '../game/configuration.dart';
import '../game/flappy_wue_game.dart';

class Bird extends SpriteGroupComponent<BirdMovement>
    with HasGameRef<FlappyWueGame>, CollisionCallbacks {
  Bird();

  int score = 0;

  @override
  Future<void> onLoad() async {
    await loadBirdSprites(Assets.birdUpFlap, Assets.birdMidFlap, Assets.birdDownFlap);

    size = Vector2(50, 40);
    position = Vector2(50, gameRef.size.y / 2 - size.y / 2);
    current = BirdMovement.middle;
    add(CircleHitbox());
  }

  Future<void> loadBirdSprites(String upFlap, String midFlap, String downFlap) async {
    final birdUpFlap = await gameRef.loadSprite(upFlap);
    final birdMidFlap = await gameRef.loadSprite(midFlap);
    final birdDownFlap = await gameRef.loadSprite(downFlap);

    sprites = {
      BirdMovement.up: birdUpFlap,
      BirdMovement.middle: birdMidFlap,
      BirdMovement.down: birdDownFlap,
    };
  }

  void setBirdSkin(String skinType) {
    if (skinType == 'Skin1') {
      loadBirdSprites(Assets.birdUpFlap, Assets.birdMidFlap, Assets.birdDownFlap);
    } else if (skinType == 'Skin2') {
      loadBirdSprites(Assets.birdUpFlap2, Assets.birdMidFlap2, Assets.birdDownFlap2);
    } else if (skinType == 'Skin3') {
      loadBirdSprites(Assets.birdUpFlap3, Assets.birdMidFlap3, Assets.birdDownFlap3);
    }
  }

  void fly() {
    add(MoveByEffect(
      Vector2(0, Config.gravity),
      EffectController(duration: 0.2, curve: Curves.decelerate),
      onComplete: () => current = BirdMovement.down,
    ));
    current = BirdMovement.up;
    FlameAudio.play(Assets.flying);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    gameOver();
  }

  void reset() {
    position = Vector2(50, gameRef.size.y / 2 - size.y / 2);
    score = 0;
  }

  void gameOver() {
    FlameAudio.play(Assets.collision);
    gameRef.overlays.add('gameOver');
    gameRef.pauseEngine();
    game.isHit = true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += Config.birdVelocity * dt;
    if (position.y < 1) {
      gameOver();
    }
  }
}