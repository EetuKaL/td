import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:td/td.dart';

class Enemy extends SpriteAnimationComponent with HasGameReference<TDGame> {
  late final List<Vector2> _path;
  final double hp;
  final double speed;
  final double range;
  late final Offset trajectoryOffset;

  Enemy({
    super.key,
    required List<Vector2> path,
    required this.hp,
    required this.speed,
    required this.range,
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size, anchor: Anchor.center) {
    _path = List.from(path);
    trajectoryOffset = Offset(
      Random().nextDoubleBetween(-32, 32),
      Random().nextDoubleBetween(-32, 32),
    );
  }

  void moveAlongTrajectory(double dt) {
    if (!isOnRoad() || _path.isEmpty) {
      // Handle off-road behavior, e.g., slow down or stop
      return;
    }
    // Logic to move the enemy along its trajectory based on speed and dt
    final offsetAdjusted = Vector2(
      _path.first.x + trajectoryOffset.dx,
      _path.first.y + trajectoryOffset.dy,
    );
    final direction = (offsetAdjusted - position).normalized();
    position += direction * speed * dt;
    if ((position - offsetAdjusted).length < range) {
      _path.removeAt(0);
      // Reached the target point
    }
  }

  /* Vector2 toNearestPointOnRoad() {
    Vector2? nearestPoint;

    for (int i = 0; i < game.road.vertices.length; i++) {
      final a = game.road.vertices[i];
      final b = game.road.vertices[i + 1];
      final edgeLine = b - a;

      final ap = position - a;

      final t = (ap.dot(edgeLine) / edgeLine.length2).clamp(0.0, 1.0);
      final projection = a + edgeLine * t;
      if (nearestPoint == null ||
          (position - projection).length < (position - nearestPoint).length) {
        nearestPoint = projection;
      }
    }
    return nearestPoint!;
  } */

  bool isOnRoad() {
    return game.level.road.containsPoint(position);
  }

  @override
  void update(double dt) {
    if (_path.isNotEmpty) {
      moveAlongTrajectory(dt);
    }

    super.update(dt);
  }
}
