import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:td/towers/projectiles/projectile.dart';
import 'package:td/towers/tower.dart';
import 'package:td/utils/sprite_extenstion.dart';

class Cannon extends RangedTower {
  static AudioPool? _shootPool;

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
  Future<void> onLoad() async {
    await super.onLoad();

    _shootPool ??= await FlameAudio.createPool(
      'towers/cannon-1-shoot.wav',
      maxPlayers: 8,
    );

    // Warm up the underlying platform player so any one-time initialization
    // warnings (Windows debug) happen during load instead of the first shot.
    final stop = await _shootPool!.start(volume: 0);
    await stop();
  }

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
  Future<String> loadAttackSound() async {
    // Preload so first shot doesn't hitch, but keep using asset keys for play.
    await FlameAudio.audioCache.load('towers/cannon-1-shoot.wav');
    return 'towers/cannon-1-shoot.wav';
  }

  @override
  void attack(Vector2 targetPosition) {
    _shootPool?.start();
  }
}
