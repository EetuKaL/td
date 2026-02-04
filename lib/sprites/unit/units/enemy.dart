import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:td/sprites/abilities/attack_ability.dart';
import 'package:td/sprites/abilities/follow_path_ability.dart';
import 'package:td/sprites/unit/unit.dart';

/// Generic enemy unit that can move along a path and (optionally) attack.
///
/// This composes abilities instead of inheritance layers.
abstract class Enemy extends Unit with FollowPathAbility, AttackAbility {
  Enemy({
    super.key,
    required super.position,
    required super.size,
    super.anchor,
    required super.hp,

    required List<Vector2> path,
    required double speed,
    required double range,

    bool enableAttack = false,
    double attackDamage = 0,
    double attackFireRate = 1.0,
    double attackSpotDistance = 0,
    double attackAimTolerance = 5 * math.pi / 180,
    double attackTurnSpeed = double.infinity,
    double attackIdleAngle = 0.0,
  }) {
    initFollowPathAbility(speed: speed, range: range, path: path);

    // Initialize attack ability fields regardless; you can decide whether to
    // call updateAttack in update() based on [enableAttack].
    initAttackAbility(
      damage: attackDamage,
      fireRate: attackFireRate,
      spotDistance: attackSpotDistance,
      aimTolerance: attackAimTolerance,
      turnSpeed: attackTurnSpeed,
      idleAngle: attackIdleAngle,
    );

    _attackEnabled = enableAttack;
  }

  bool _attackEnabled = false;

  bool get attackEnabled => _attackEnabled;

  set attackEnabled(bool value) => _attackEnabled = value;

  @override
  void update(double dt) {
    updateFollowPath(dt);
    if (_attackEnabled) {
      updateAttack(dt);
    }
    super.update(dt);
  }
}
