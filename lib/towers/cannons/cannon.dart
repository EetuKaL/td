import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:td/towers/cannons/tower.dart';

class Cannon extends Tower {
  Cannon({required super.position, required super.size})
    : super(spotDistance: 150, turnSpeed: 1.0);

  @override
  Future<void> onLoad() async {
    animation = await SpriteAnimation.load(
      'towers/cannon-1.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.2,
        amountPerRow: 2,
        textureSize: Vector2.all(32.0),
        loop: true,
      ),
    );
    anchor = Anchor.center;
    return super.onLoad();
  }

  @override
  Future<Uri> loadShootSound() async {
    // Load your specific sound here
    return await FlameAudio.audioCache.load('towers/cannon-1-shoot.wav');
  }

  @override
  void update(double dt) {
    super.update(dt);
    angle += turnSpeed * dt;
  }
}
