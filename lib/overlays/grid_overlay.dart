import 'dart:ui';

import 'package:flame/components.dart';

class GridCellIndex {
  final int row;
  final int col;

  const GridCellIndex(this.row, this.col);
}

class TowerPlacementGrid {
  static const double gridCellBase = 32.0;
  late final List<List<Vector2>> cellOrigins;
  final List<PolygonComponent> offZoneAreas;
  late final int rowCount;
  late final int colCount;
  final double gridCellSize;

  TowerPlacementGrid({
    required Size mapSize,
    required this.offZoneAreas,
    required this.gridCellSize,
  }) : assert(
         mapSize.width % gridCellSize == 0 &&
             mapSize.height % gridCellSize == 0,
         'Map size must be divisible by grid cell size',
       ) {
    rowCount = (mapSize.height / gridCellSize).toInt();
    colCount = (mapSize.width / gridCellSize).toInt();

    cellOrigins = List.generate(rowCount, (index) {
      return List.generate(colCount, (jindex) {
        return Vector2(jindex * gridCellSize, index * gridCellSize);
      });
    });
  }

  GridCellIndex? cellIndexFromWorldPosition(Vector2 worldPosition) {
    if (worldPosition.x < 0 || worldPosition.y < 0) {
      return null;
    }

    final col = (worldPosition.x / gridCellSize).floor();
    final row = (worldPosition.y / gridCellSize).floor();

    if (row < 0 || row >= rowCount || col < 0 || col >= colCount) {
      return null;
    }

    return GridCellIndex(row, col);
  }

  Vector2 cellCenter(int row, int col) {
    final origin = cellOrigins[row][col];
    return Vector2(origin.x + gridCellSize / 2, origin.y + gridCellSize / 2);
  }

  bool isCellInOffZone(int row, int col) {
    final center = cellCenter(row, col);
    for (final area in offZoneAreas) {
      if (area.containsPoint(center)) {
        return true;
      }
    }
    return false;
  }

  bool isCellBuildable(int row, int col) {
    return !isCellInOffZone(row, col);
  }
}
