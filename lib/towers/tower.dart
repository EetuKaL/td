import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:td/enemies/enemy.dart';
import 'package:td/towers/projectiles/projectile.dart';
import 'package:td/towers/tower_man/tower_man.dart';
import 'package:td/utils/debug_beam.dart';

abstract class _Tower extends SpriteComponent with HasGameReference {
  /// Distance to spot enemies
  final double spotDistance;

  /// Radians
  final double turnSpeed;

  /// Shoot sound
  late final String attackSound;

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
    attackSound = await loadAttackSound();
  }

  Future<Sprite> loadSprite() async {
    // Default implementation - override in subclasses
    return await Sprite.load('towers/Tower 01.png');
  }

  /// Override this method in subclasses to provide specific attack sounds
  Future<String> loadAttackSound() async {
    // Default implementation - override in subclasses
    return 'towers/cannon-1-shoot.wav';
  }

  void attack(Vector2 targetPosition) {
    FlameAudio.play(attackSound);

    // Additional shooting logic here
  }

  Enemy? findNearestEnemyInRange() {
    Enemy? best;
    var bestDistance2 = double.infinity;

    for (final enemy in game.world.children.whereType<Enemy>()) {
      final d2 = enemy.position.distanceToSquared(position);
      if (d2 <= spotDistance * spotDistance && d2 < bestDistance2) {
        best = enemy;
        bestDistance2 = d2;
      }
    }

    return best;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()
      ..color = const Color(0xFFFF0000)
      ..strokeWidth = 2.0;

    // Draw the range circle centered on the tower's anchor point.
    // Note: this is local-space because Flame already transforms the canvas
    // for this component.
    final anchorPoint = anchor.toVector2()..multiply(size);
    canvas.drawCircle(
      anchorPoint.toOffset(),
      spotDistance,
      paint..style = PaintingStyle.stroke,
    );
  }
}

class RangedTower extends _Tower {
  final Projectile projectile;
  final double fireRate;
  double _cooldownLeft = 0;
  RangedTower({
    super.key,
    required this.projectile,
    required this.fireRate,
    required super.spotDistance,
    required super.turnSpeed,
    required super.position,
    required super.size,
  });

  @override
  void update(double dt) {
    super.update(dt);

    _cooldownLeft -= dt;
    if (_cooldownLeft > 0) {
      return;
    }

    final target = findNearestEnemyInRange();
    if (target == null) {
      return;
    }

    attack(target.position);
    game.world.add(
      DebugBeam(from: position.clone(), to: target.position.clone()),
    );

    // Interpret fireRate as shots per second.
    _cooldownLeft = fireRate <= 0 ? 0.5 : (1 / fireRate);
  }
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

  // Inherit base attack behavior for now.
}
