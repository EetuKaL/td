import 'dart:math';

import 'package:flame/components.dart';
import 'package:td/towers/ranged_tower.dart';

class Cannon extends RangedTower {
  static final Vector2 _kSpriteOffset = Vector2(0, -12);
  static final double _kTurnSpeed = pi / 10; // 18 degrees per second
  @override
  double get turnSpeed => _kTurnSpeed;
  Cannon({
    required super.position,
    required super.size,
    required super.nativeAngle,
  }) : super(
         name: 'Cannon',
         images: ['towers/cannon/cannon.png'],
         towerMaxLevel: 3,
         damage: const [25.0, 35.0, 50.0],
         fireRate: const [1.0, 0.8, 0.6],
         spotDistance: const [150.0, 170.0, 200.0],
         attackSound: const [
           'towers/cannon/cannon_shoot_1.wav',
           'towers/cannon/cannon_shoot_2.wav',
         ],
       ) {
    anchor = Anchor.center;
  }

  @override
  Vector2 get spriteOffset => _kSpriteOffset;
}
