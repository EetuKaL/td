import 'dart:math';

import 'package:flame/components.dart';
import 'package:td/sprites/unit/unit.dart';

/// A lightweight spatial hash for quickly finding nearby enemies.
///
/// Instead of each tower scanning all enemies, towers query only
/// enemies in grid buckets overlapping their range.
class EnemySpatialIndex {
  final double cellSize;

  final Map<Point<int>, List<Unit>> _buckets = {};

  EnemySpatialIndex({required this.cellSize});

  void clear() => _buckets.clear();

  void rebuild(Iterable<Unit> enemies) {
    _buckets.clear();
    for (final enemy in enemies) {
      final cell = _cellFor(enemy.position);
      (_buckets[cell] ??= <Unit>[]).add(enemy);
    }
  }

  /// Returns candidates in the square bounding box of the radius.
  /// Callers should still do precise distance checks.
  Iterable<Unit> queryRadius(Vector2 origin, double radius) sync* {
    final minX = ((origin.x - radius) / cellSize).floor();
    final maxX = ((origin.x + radius) / cellSize).floor();
    final minY = ((origin.y - radius) / cellSize).floor();
    final maxY = ((origin.y + radius) / cellSize).floor();

    for (var cy = minY; cy <= maxY; cy++) {
      for (var cx = minX; cx <= maxX; cx++) {
        final bucket = _buckets[Point<int>(cx, cy)];
        if (bucket == null) continue;
        for (final enemy in bucket) {
          yield enemy;
        }
      }
    }
  }

  Point<int> _cellFor(Vector2 position) {
    return Point<int>(
      (position.x / cellSize).floor(),
      (position.y / cellSize).floor(),
    );
  }
}
