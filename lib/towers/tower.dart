import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:td/towers/projectiles/projectile.dart';
import 'package:td/towers/tower_man/tower_man.dart';

abstract class _Tower extends SpriteComponent {
  /// Distance to spot enemies
  final double spotDistance;

  /// Radians
  final double turnSpeed;

  /// Shoot sound
  late final Uri attackSound;

  _Tower({
    super.key,
    required this.spotDistance,
    required this.turnSpeed,
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size, anchor: Anchor.bottomCenter);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await loadSprite();
    attackSound = await loadattackSound();
  }

  Future<Sprite> loadSprite() async {
    // Default implementation - override in subclasses
    return await Sprite.load('towers/Tower 01.png');
  }

  /// Override this method in subclasses to provide specific shoot sounds
  Future<Uri> loadattackSound() async {
    // Default implementation - override in subclasses
    return Uri.parse('towers/cannon-1-shoot.wav');
  }

  shoot() {
    FlameAudio.play(attackSound.path);
    // Additional shooting logic here
  }
}

class RangedTower extends _Tower {
  final Projectile projectile;
  final double fireRate;
  RangedTower({
    super.key,
    required this.projectile,
    required this.fireRate,
    required super.spotDistance,
    required super.turnSpeed,
    required super.position,
    required super.size,
  });
}

class MannedTower extends _Tower {
  final TowerMan crew;
  final int crewCount;
  MannedTower({
    super.key,
    required super.spotDistance,
    required super.turnSpeed,
    required super.position,
    required super.size,
    required this.crew,
    required this.crewCount,
  });
}
