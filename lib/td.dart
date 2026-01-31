import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:td/enemies/enemy.dart';
import 'package:td/enemies/native.dart';
import 'package:td/overlays/tower_options_overlay.dart';
import 'package:td/towers/ranged/cannon.dart';
import 'package:td/towers/tower.dart';
import 'package:td/utils/debug_flags.dart';
import 'package:td/utils/debug_line_drawer.dart';
import 'package:td/utils/td_camera.dart';
import 'package:td/utils/td_level.dart';
import 'package:td/utils/enemy_spatial_index.dart';

class TDGame extends FlameGame with TapCallbacks, KeyboardEvents {
  TDGame() : super();

  final List<Tower> towers = [];
  final List<Enemy> enemies = [];

  final Map<String, Tower> _occupiedCells = {};
  late final Timer spawnTimer;
  late final TDLevel level;

  /// Spatial index used by towers to query nearby enemies.
  late final EnemySpatialIndex enemyIndex;

  void removeEnemy(Enemy enemy) {
    enemies.remove(enemy);
    enemy.removeFromParent();
  }

  void addEnemy(Enemy enemy) {
    enemies.add(enemy);
    world.add(enemy);
  }

  void addTower(Tower tower) {
    towers.add(tower);
    world.add(tower);
  }

  void removeTower(Tower tower) {
    towers.remove(tower);
    tower.removeFromParent();
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.keyD) {
      DebugFlags.enabled = !DebugFlags.enabled;
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.keyT) {
      if (DebugFlags.enabled) {
        Tower.cycleDebugOverlay();
      }
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  String _cellKey(int row, int col) => '$row:$col';

  Vector2 _tapToWorldPosition(TapDownEvent event) {
    // TapDownEvent provides a position in canvas/screen coordinates.
    // Convert it to world coordinates so it matches the grid/tile map.
    return camera.globalToLocal(event.canvasPosition);
  }

  Tower placeTower(Vector2 worldPosition, int row, int col) {
    final towerSize = Vector2(128.0, 128.0);
    final center = level.grid.cellCenter(row, col);
    final rotation = level.getRotationForClosestEnemyPath(center);
    final tower = Cannon(
      position: center,
      size: towerSize,
      nativeAngle: rotation,
    );
    tower.position = center + tower.placementOffset;

    addTower(tower);

    return tower;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    Tower.cycleDebugOverlay();

    // Maps is createf rom 32x32 tiles
    enemyIndex = EnemySpatialIndex(cellSize: 64);

    final tiledComponent = await TiledComponent.load(
      'testLevel.tmx',
      Vector2.all(32),
      prefix: 'assets/tiles/testLevel/',
    );

    level = await TDLevel.fromTiledComponent(
      tiledComponent: tiledComponent,
      world: world,
    );

    for (final path in level.enemyPaths) {
      await world.add(DebugLineDrawer(points: path));
    }

    camera = TdCamera.fromMapDetails(
      world,
      canvasSize: NotifyingVector2(canvasSize.x, canvasSize.y),
      gameMap: level,
    );

    spawnTimer = Timer(
      2,
      repeat: true,
      onTick: () {
        final newEnemy = Native(
          path: level
              .enemyPaths[Random().nextIntBetween(0, level.enemyPaths.length)],
          position: level.enemySpawn,
          size: Vector2.all(32.0),
        );
        addEnemy(newEnemy);
      },
    );

    spawnTimer.start();
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);

    final overlays = camera.viewport.children.whereType<TowerOptionsOverlay>();
    final TowerOptionsOverlay? existingOverlay = overlays.isEmpty
        ? null
        : overlays.first;

    final worldPosition = _tapToWorldPosition(event);
    final index = level.grid.cellIndexFromWorldPosition(worldPosition);

    final key = index == null ? null : _cellKey(index.row, index.col);
    final builtTower = _occupiedCells[key];

    if (existingOverlay != null) {
      existingOverlay.tower.showRadius = false;
      existingOverlay.removeFromParent();

      if (builtTower == existingOverlay.tower) {
        return;
      }
    }

    if (builtTower == null &&
        level.grid.isCellBuildable(index!.row, index.col)) {
      final tower = placeTower(worldPosition, index.row, index.col);
      _occupiedCells[key!] = tower;
    } else if (builtTower != null) {
      builtTower.showRadius = true;
      final overlay = TowerOptionsOverlay(tower: builtTower);
      camera.viewport.add(overlay);
    }
  }

  @override
  void update(double dt) {
    spawnTimer.update(dt);
    super.update(dt);

    // Rebuild after components updated their positions.
    enemyIndex.rebuild(enemies);
  }
}
