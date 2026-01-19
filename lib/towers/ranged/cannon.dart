import 'dart:ui';
import 'package:flame/components.dart';
import 'package:td/towers/ranged_tower.dart';
import 'package:td/towers/tower_controller.dart';
import 'package:td/utils/sprite_extenstion.dart';

class Cannon extends RangedTower {
  Cannon({required super.position, required super.size})
    : super(
        towerMaxLevel: 3,
        damage: const [25.0, 35.0, 50.0],
        fireRate: const [1.0, 0.8, 0.6],
        spotDistance: const [150.0, 170.0, 200.0],
        attackSound: const [
          'towers/cannon/cannon_shoot_1.wav',
          'towers/cannon/cannon_shoot_2.wav',
          'towers/cannon/cannon_shoot_3.wav',
        ],
        controllerBuilder: RangedTowerController.fromTower,
      );

  @override
  Future<Sprite> loadSpriteForLevel(int level) async {
    // Tower 01.png is a 3-variant sheet: 3 columns, 1 row.
    // Each variant is 64x128 in pixels; we render it scaled in-world.
    final col = (level - 1).clamp(0, 2);
    return await SpriteExtension.singleFromSpriteSheet(
      'towers/Tower 01.png',
      rowCount: 1,
      columnCount: 3,
      singleSize: const Size(64, 128),
      takeFrom: (rowIndex: 0, colIndex: col),
    );
  }
}
