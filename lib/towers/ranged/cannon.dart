import 'dart:ui';
import 'package:flame/components.dart';
import 'package:td/towers/ranged_tower.dart';
import 'package:td/towers/tower_controller.dart';
import 'package:td/utils/sprite_extenstion.dart';

class Cannon extends RangedTower {
  @override
  double get fireRate => 1.0;
  @override
  double get damage => 25.0;
  @override
  double get spotDistance => 150.0;
  @override
  String get attackSound => 'towers/cannon-1-shoot.wav';

  Cannon({required super.position, required super.size})
    : super(controllerBuilder: RangedTowerController.fromTower);

  @override
  Future<Sprite> loadSprite() async {
    // Tower 01.png is a 3-variant sheet: 3 columns, 1 row.
    // Each variant is 64x128 in pixels; we render it scaled in-world.
    return SpriteExtension.singleFromSpriteSheet(
      'towers/Tower 01.png',
      rowCount: 1,
      columnCount: 3,
      singleSize: const Size(64, 128),
      takeFrom: (rowIndex: 0, colIndex: 0),
    );
  }
}
