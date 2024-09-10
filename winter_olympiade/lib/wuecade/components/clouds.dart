import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/parallax.dart';

import '../game/assets.dart';
import '../game/configuration.dart';
import '../game/flappy_wue_game.dart';

class Clouds extends ParallaxComponent<FlappyWueGame> with HasGameRef<FlappyWueGame> {
  Clouds();

  @override
  Future<void> onLoad() async {
    final image = await Flame.images.load(Assets.clouds);
    position = Vector2(x, -(gameRef.size.y - Config.cloudsHeight));
    parallax = Parallax([
      ParallaxLayer(
        ParallaxImage(image, fill: LayerFill.none),
      ),
    ]);
  }

  @override
  void update(double dt) {
    super.update(dt);
    parallax?.baseVelocity.x = Config.gameSpeed;
  }
}
