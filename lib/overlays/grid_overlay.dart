import 'dart:ui';
import 'package:flame/components.dart';

const double gridCellSize = 32.0;

class MapGrid extends Component {
  late final List<List<Vector2>> cells;
  final List<PolygonComponent> offZoneAreas;

  MapGrid({required Size mapSize, required this.offZoneAreas})
    : assert(
        mapSize.width % gridCellSize == 0 && mapSize.height % gridCellSize == 0,
        'Map size must be divisible by grid cell size',
      ) {
    cells = List.generate((mapSize.height / gridCellSize).toInt(), (index) {
      return List.generate((mapSize.width / gridCellSize).toInt(), (jindex) {
        return Vector2(jindex * gridCellSize, index * gridCellSize);
      });
    });
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (final row in cells) {
      for (final cell in row) {
        final rect = Rect.fromLTWH(cell.x, cell.y, gridCellSize, gridCellSize);

        final cellCenter = Vector2(
          cell.x + gridCellSize / 2,
          cell.y + gridCellSize / 2,
        );

        bool isInOffZone = false;

        for (final area in offZoneAreas) {
          if (area.containsPoint(cellCenter)) {
            isInOffZone = true;
            break;
          }
        }

        paint.color = isInOffZone
            ? const Color.fromARGB(239, 238, 7, 7)
            : const Color.fromARGB(242, 0, 255, 0);

        canvas.drawRect(rect, paint);
      }
    }
  }
}
