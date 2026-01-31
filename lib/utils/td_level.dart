import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart' hide Grid;
import 'package:td/overlays/grid_overlay.dart';

class TDLevel extends Component with HasGameReference {
  late final TowerPlacementGrid grid;
  final List<PolygonComponent> offZoneAreas = [];
  late final PolygonComponent road;
  final List<List<Vector2>> enemyPaths = [];

  late final Vector2 enemySpawn;
  late final NotifyingVector2 size;

  static Future<TDLevel> fromTiledComponent({
    required TiledComponent tiledComponent,
    required World world,
  }) async {
    final size = tiledComponent.size;

    late final PolygonComponent road;
    final offZoneAreas = <PolygonComponent>[];
    final enemyPaths = <List<Vector2>>[];

    final mapGameObjects = tiledComponent.tileMap.getLayer<ObjectGroup>(
      'gameObjects',
    );
    for (final obj in mapGameObjects!.objects) {
      if (obj.name == 'road_area') {
        road = PolygonComponent(
          obj.polygon
              .map((point) => Vector2(point.x + obj.x, point.y + obj.y))
              .toList(),
        );

        offZoneAreas.add(road);
      } else if (obj.name.startsWith('path_')) {
        if (obj.polyline.isEmpty) {
          throw Exception('Path object ${obj.name} has no polyline data.');
        }
        enemyPaths.add(
          obj.polyline
              .map((point) => Vector2(point.x + obj.x, point.y + obj.y))
              .toList(),
        );
      }
    }
    if (enemyPaths.isEmpty) {
      throw Exception('No enemy trajectories found in the map.');
    }

    final grid = TowerPlacementGrid(
      mapSize: tiledComponent.size.toSize(),
      offZoneAreas: offZoneAreas,
    );
    await world.addAll([tiledComponent, grid]);

    return TDLevel()
      ..grid = grid
      ..offZoneAreas.addAll(offZoneAreas)
      ..road = road
      ..enemyPaths.addAll(enemyPaths)
      ..enemySpawn = enemyPaths[0].first
      ..size = NotifyingVector2(size.x, size.y);
  }

  double getRotationForClosestEnemyPath(Vector2 targetPosition) {
    Vector2? bestDir;
    var bestDistance2 = double.infinity;

    for (final path in enemyPaths) {
      for (var i = 0; i < path.length - 1; i++) {
        final a = path[i];
        final b = path[i + 1];
        // Path line
        final ab = b - a;
        if (ab.length2 == 0) continue;

        // From Tower to path start
        final ap = targetPosition - a;

        // Get scalar
        var t = ap.dot(ab) / ab.length2;
        if (t < 0) t = 0;
        if (t > 1) t = 1;
        // Go from point a line ab scalar amount.
        final closestPoint = a + ab * t;

        final candidate = closestPoint.distanceToSquared(targetPosition);
        if (candidate < bestDistance2) {
          bestDistance2 = candidate;
          bestDir = closestPoint - targetPosition;
        }
      }
    }
    return bestDir!.screenAngle();
  }
}
