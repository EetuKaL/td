import 'dart:math';

import 'package:flame/components.dart';
import 'package:td/towers/ranged_tower.dart';

class Cannon extends RangedTower {
  Cannon({required super.position, required super.size})
    : super(
        name: 'Cannon',
        images: [
          'towers/cannon/cannon_1.png',
          'towers/cannon/cannon_2.png',
          'towers/cannon/cannon_3.png',
        ],
        towerMaxLevel: 3,
        damage: const [25.0, 35.0, 50.0],
        fireRate: const [1.0, 0.8, 0.6],
        spotDistance: const [150.0, 170.0, 200.0],
        attackSound: const [
          'towers/cannon/cannon_shoot_1.wav',
          'towers/cannon/cannon_shoot_2.wav',
        ],
      ) {
    anchor = Anchor.bottomCenter;
  }

  @override
  Vector2 get placementOffset => Vector2(0, -12);

  @override
  double get aimAngleOffset => pi / 2;
}
