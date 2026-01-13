import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:td/enemies/enemy.dart';
import 'package:td/enemies/native.dart';
import 'package:td/towers/cannons/cannon.dart';
import 'package:td/utils/td_camera.dart';
import 'package:td/utils/td_level.dart';

class TDGame extends FlameGame {
  TDGame() : super();

  List<Component> towers = [];
  List<Enemy> enemies = [];
  late final Timer spawnTimer;
  late final TDLevel level;
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final tiledComponent = await TiledComponent.load(
      'testLevel.tmx',
      Vector2.all(32),
      prefix: 'assets/tiles/testLevel/',
    );

    level = await TDLevel.fromTiledComponent(
      tiledComponent: tiledComponent,
      world: world,
    );

    camera = TdCamera.fromMapDetails(
      world,
      canvasSize: NotifyingVector2(canvasSize.x, canvasSize.y),
      gameMap: level,
    );

    towers.add(
      Cannon(position: level.grid.cells[5][5], size: Vector2.all(32.0)),
    );

    for (var tower in towers) {
      await world.add(tower);
    }

    spawnTimer = Timer(
      2,
      repeat: true,
      onTick: () {
        final newEnemy = Native(
          trajectory:
              level.enemyPaths[Random().nextIntBetween(
                0,
                level.enemyPaths.length - 1,
              )],
          position: level.enemySpawn,
          size: Vector2.all(32.0),
        );
        enemies.add(newEnemy);
        world.add(newEnemy);
      },
    );

    spawnTimer.start();
  }

  @override
  void update(double dt) {
    super.update(dt);
    spawnTimer.update(dt);
  }
}
