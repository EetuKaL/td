import 'package:flame/components.dart';
import 'package:td/enemies/enemy.dart';

class Native extends Enemy {
  Native({required super.path, required super.position, required super.size})
    : super(hp: 100, speed: 50, range: 10);

  @override
  Future<void> onLoad() async {
    animation = await SpriteAnimation.load(
      'enemies/native.png',
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.2,
        amountPerRow: 1,
        textureSize: Vector2.all(32.0),
        loop: true,
      ),
    );
    return super.onLoad();
  }
}
