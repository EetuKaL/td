import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';

class Tower extends SpriteAnimationComponent {
  /// Distance to spot enemies
  final double spotDistance;

  /// Radians
  final double turnSpeed;

  /// Shoot sound
  late final Uri shootSound;

  Tower({
    super.key,
    required this.spotDistance,
    required this.turnSpeed,
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size, anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    shootSound = await loadShootSound();
    animation = await loadAnimation();
  }

  Future<SpriteAnimation> loadAnimation() async {
    // Default implementation - override in subclasses
    return await SpriteAnimation.load(
      'towers/cannon-1.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.2,
        amountPerRow: 2,
        textureSize: Vector2.all(32.0),
        loop: true,
      ),
    );
  }

  /// Override this method in subclasses to provide specific shoot sounds
  Future<Uri> loadShootSound() async {
    // Default implementation - override in subclasses
    return Uri.parse('towers/cannon-1-shoot.wav');
  }

  shoot() {
    FlameAudio.play(shootSound.path);
    // Additional shooting logic here
  }
}
