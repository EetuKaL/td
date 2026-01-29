import 'dart:ui';

import 'package:flame/components.dart';
import 'package:td/utils/debug_flags.dart';

class DebugLineDrawer extends Component {
  final List<Vector2> points;
  DebugLineDrawer({required this.points});

  @override
  void render(Canvas canvas) {
    if (!DebugFlags.enabled) return;
    final paint = Paint()
      ..color = const Color.fromARGB(255, 247, 0, 255)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    if (points.length < 2) return;

    final path = Path()..moveTo(points[0].x, points[0].y);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].x, points[i].y);
    }

    canvas.drawPath(path, paint);
  }
}
