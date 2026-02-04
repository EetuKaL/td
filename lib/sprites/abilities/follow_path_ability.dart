import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:td/td.dart';

/// Shared path-following movement with per-unit "trajectory" offset.
///
/// Initialize [speed] + [range] + path via [initFollowPathAbility]/[setPath],
/// then call [updateFollowPath] from your `update(dt)`.
mixin FollowPathAbility on PositionComponent, HasGameReference<TDGame> {
  /// Movement speed in pixels/sec.
  late double speed;

  /// How close the unit must get to a waypoint before advancing.
  late double range;

  final List<Vector2> _path = <Vector2>[];
  late Vector2 _trajectoryOffset;
  bool _hasOffset = false;

  void initFollowPathAbility({
    required double speed,
    required double range,
    required List<Vector2> path,
    double maxOffset = 32,
  }) {
    this.speed = speed;
    this.range = range;
    setPath(path, maxOffset: maxOffset);
  }

  /// Whether this unit is allowed to move right now.
  ///
  /// Override for stun/knockback/death animations.
  bool get canMove => true;

  /// Remaining waypoints (internal list is mutated as waypoints are reached).
  bool get hasPath => _path.isNotEmpty;

  /// Sets a new path and (re)rolls the per-unit trajectory offset.
  void setPath(List<Vector2> path, {double maxOffset = 32}) {
    _path
      ..clear()
      ..addAll(path);

    final rnd = Random();
    _trajectoryOffset = Vector2(
      rnd.nextDoubleBetween(-maxOffset, maxOffset),
      rnd.nextDoubleBetween(-maxOffset, maxOffset),
    );
    _hasOffset = true;
  }

  void clearPath() {
    _path.clear();
  }

  /// Override for different road logic.
  bool isOnRoad() => game.level.road.containsPoint(position);

  /// Call from your `update(dt)`.
  void updateFollowPath(double dt) {
    if (!canMove) return;
    if (_path.isEmpty) return;
    if (!isOnRoad()) return;

    _moveAlongTrajectory(dt);
  }

  void _moveAlongTrajectory(double dt) {
    if (!_hasOffset) {
      // In case someone forgot to call setPath.
      setPath(_path);
    }

    final target = _path.first + _trajectoryOffset;
    final toTarget = target - position;

    if (toTarget.length2 > 0) {
      final direction = toTarget.normalized();
      position += direction * speed * dt;
    }

    if ((position - target).length < range) {
      _path.removeAt(0);
    }
  }
}
