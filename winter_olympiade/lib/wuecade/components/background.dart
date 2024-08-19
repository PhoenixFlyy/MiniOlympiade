import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import '../game/assets.dart';
import '../game/flappy_wue_game.dart';

class Background extends SpriteComponent with HasGameRef<FlappyWueGame> {
  Background();

  @override
  Future<void> onLoad() async {
    final background = await Flame.images.load(Assets.background);
    size = gameRef.size;
    sprite = Sprite(background);
  }
}