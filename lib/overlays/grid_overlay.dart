import 'dart:ui';
import 'package:flame/components.dart';

const double gridCellSize = 32.0;

class GridCellIndex {
  final int row;
  final int col;

  const GridCellIndex(this.row, this.col);
}

class TowerPlacementGrid extends Component {
  late final List<List<Vector2>> cellOrigins;
  final List<PolygonComponent> offZoneAreas;
  late final int rowCount;
  late final int colCount;

  TowerPlacementGrid({required Size mapSize, required this.offZoneAreas})
    : assert(
        mapSize.width % gridCellSize == 0 && mapSize.height % gridCellSize == 0,
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

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (var row = 0; row < rowCount; row++) {
      for (var col = 0; col < colCount; col++) {
        final origin = cellOrigins[row][col];
        final rect = Rect.fromLTWH(
          origin.x,
          origin.y,
          gridCellSize,
          gridCellSize,
        );

        final isInOffZone = isCellInOffZone(row, col);

        paint.color = isInOffZone
            ? const Color.fromARGB(239, 238, 7, 7)
            : const Color.fromARGB(242, 0, 255, 0);

        canvas.drawRect(rect, paint);
      }
    }
  }
}
