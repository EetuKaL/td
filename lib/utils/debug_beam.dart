import 'dart:ui';

import 'package:flame/components.dart';

class DebugBeam extends Component {
  final Vector2 from;
  final Vector2 to;
  final Color color;
  final double strokeWidth;
  double _timeLeft;

  DebugBeam({
    required this.from,
    required this.to,
    double ttlSeconds = 0.12,
    this.color = const Color.fromARGB(255, 247, 0, 255),
    this.strokeWidth = 2.0,
  }) : _timeLeft = ttlSeconds;

  @override
  void update(double dt) {
    _timeLeft -= dt;
    if (_timeLeft <= 0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawLine(from.toOffset(), to.toOffset(), paint);
  }
}
