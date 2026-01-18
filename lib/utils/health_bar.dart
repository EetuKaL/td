import 'dart:ui';

import 'package:flame/components.dart';

class HealthBar extends PositionComponent with ParentIsA<PositionComponent> {
  final double Function() current;
  final double Function() max;

  final double barWidth;
  final double barHeight;
  final double gapAbove;
  final Color fillColor;
  final Color backgroundColor;
  final double radius;

  HealthBar({
    required this.current,
    required this.max,
    this.barWidth = 40.0,
    this.barHeight = 6.0,
    this.gapAbove = 4.0,
    this.fillColor = const Color(0xFF00FF00),
    this.backgroundColor = const Color(0xFF555555),
    this.radius = 3.0,
  });

  double get healthPercentage {
    final maxValue = max();
    if (maxValue <= 0) return 0.0;
    return (current() / maxValue).clamp(0.0, 1.0);
  }

  @override
  void onMount() {
    super.onMount();
    size = Vector2(barWidth, barHeight);
    anchor = Anchor.bottomCenter;
    // Parent is expected to be a PositionComponent (enemy, tower, etc.).
    // Place the bar centered above the parent.
    position = Vector2(parent.size.x / 2, -gapAbove);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..color = fillColor;

    // Draw the background of the health bar (gray)
    final backgroundPaint = Paint()..color = backgroundColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y),
        Radius.circular(radius),
      ),
      backgroundPaint,
    );

    // Draw the health portion of the bar
    final healthBarWidth = size.x * healthPercentage;
    final healthBarRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, healthBarWidth, size.y),
      Radius.circular(radius),
    );
    canvas.drawRRect(healthBarRect, paint);
  }
}
