import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:td/towers/projectiles/projectile.dart';
import 'package:td/towers/tower.dart';
import 'package:td/utils/sprite_extenstion.dart';

class Cannon extends RangedTower {
  Cannon({required super.position, required super.size})
    : super(
        spotDistance: 150,
        turnSpeed: 1.0,
        fireRate: 1.0,
        projectile: Projectile(
          name: 'Cannon Ball',
          speed: 100.0,
          damage: 10.0,
          impactType: ImpactType.explode,
          windResist: 5.0,
        ),
      );

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

  @override
  Future<Uri> loadattackSound() async {
    // Load your specific sound here
    return await FlameAudio.audioCache.load('towers/cannon-1-shoot.wav');
  }
}
