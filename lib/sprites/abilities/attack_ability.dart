import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:td/sprites/unit/unit.dart';
import 'package:td/td.dart';

/// Shared attack loop: aim/turn (optional) + cooldown + attack execution.
///
/// This is implemented as an "ability" so both towers and units can reuse the
/// same logic without duplicating code.
///
/// Usage:
/// - Mix it into a component (`with AttackAbility`).
/// - Initialize the late fields (usually in constructor body / onLoad).
/// - Call [updateAttack] from your `update(dt)`.
mixin AttackAbility on PositionComponent, HasGameReference<TDGame> {
  /// Damage dealt per successful attack.
  late double attackDamage;

  /// Seconds between attacks.
  late double attackFireRate;

  /// Target acquisition radius (pixels in world space).
  late double attackSpotDistance;

  /// How closely the attacker must be aimed at the target before it can attack.
  ///
  /// Value is in radians. If negative, aiming is ignored.
  late double attackAimTolerance;

  /// Rotation speed in radians/sec.
  ///
  /// Use [double.infinity] for instant turning.
  late double attackTurnSpeed;

  /// The rotation used when there is no target.
  late double attackIdleAngle;

  double _cooldownSeconds = 0.0;

  void initAttackAbility({
    required double damage,
    required double fireRate,
    required double spotDistance,
    double aimTolerance = 5 * math.pi / 180,
    double turnSpeed = double.infinity,
    double idleAngle = 0.0,
  }) {
    attackDamage = damage;
    attackFireRate = fireRate;
    attackSpotDistance = spotDistance;
    attackAimTolerance = aimTolerance;
    attackTurnSpeed = turnSpeed;
    attackIdleAngle = idleAngle;
  }

  /// Override for custom targeting logic.
  ///
  /// Default: nearest enemy within [attackSpotDistance].
  Unit? findTarget() => _findNearestInSpotDistance();

  /// Override for custom attack behavior (projectiles, AOE, melee swing, etc).
  ///
  /// Default: apply damage immediately.
  void attack(Unit target) {
    target.takeHit(attackDamage);
  }

  /// Hook to gate attacking (audio pool ready, ammo, stunned, etc).
  ///
  /// Return `true` to allow [attack] this frame.
  bool canAttack(Unit target) => true;

  /// Call from your `update(dt)`.
  void updateAttack(double dt) {
    final target = findTarget();

    // Track desired aim so we can gate attacks when turn speed is finite.
    double? desiredAimAngle;
    var isTargetExactlyOnSelf = false;

    if (target != null) {
      final dir = target.position - position;
      if (dir.length2 > 0) {
        desiredAimAngle = dir.screenAngle();
        _turnTowards(desiredAimAngle, dt);
      } else {
        // Same position: direction is undefined, but we should still allow
        // attacking.
        isTargetExactlyOnSelf = true;
      }
    } else {
      _turnTowards(attackIdleAngle, dt);
    }

    if (_cooldownSeconds > 0) {
      _cooldownSeconds -= dt;
      return;
    }

    if (target == null) return;

    // If the target has a defined direction, only attack when we're aimed.
    if (!isTargetExactlyOnSelf && desiredAimAngle != null) {
      if (!_isAimedAt(desiredAimAngle)) {
        return;
      }
    }

    if (!canAttack(target)) return;

    attack(target);
    _cooldownSeconds = attackFireRate;
  }

  void resetAttackCooldown() {
    _cooldownSeconds = 0.0;
  }

  void _turnTowards(double targetAngle, double dt) {
    final speed = attackTurnSpeed;
    if (speed.isInfinite || speed <= 0 || dt <= 0) {
      angle = targetAngle;
      return;
    }

    final maxDelta = speed * dt;
    angle = _moveAngleTowards(angle, targetAngle, maxDelta);
  }

  double _moveAngleTowards(double current, double target, double maxDelta) {
    final c = _normalizeAngle(current);
    final t = _normalizeAngle(target);
    final diff = _normalizeAngle(t - c);

    if (diff.abs() <= maxDelta) {
      return t;
    }

    final stepped = c + diff.sign * maxDelta;
    return _normalizeAngle(stepped);
  }

  double _normalizeAngle(double radians) {
    var a = radians;
    // Normalize to (-pi, pi]
    while (a <= -math.pi) {
      a += 2 * math.pi;
    }
    while (a > math.pi) {
      a -= 2 * math.pi;
    }
    return a;
  }

  bool _isAimedAt(double targetAngle) {
    final tolerance = attackAimTolerance;
    if (tolerance.isNaN || tolerance.isNegative) {
      return true;
    }
    final diff = _normalizeAngle(_normalizeAngle(targetAngle) - angle);
    return diff.abs() <= tolerance;
  }

  Unit? _findNearestInSpotDistance() {
    Unit? best;
    var bestDistance2 = double.infinity;

    final origin = position;
    final radius = attackSpotDistance;
    if (radius <= 0) return null;

    final radius2 = radius * radius;

    for (final enemy in game.enemyIndex.queryRadius(origin, radius)) {
      if (identical(enemy, this)) continue;

      final d2 = enemy.position.distanceToSquared(origin);
      if (d2 <= radius2 && d2 < bestDistance2) {
        best = enemy;
        bestDistance2 = d2;
      }
    }

    return best;
  }
}
