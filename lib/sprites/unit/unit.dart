import 'dart:async';

import 'package:flame/components.dart';
import 'package:td/td.dart';
import 'package:td/utils/health_bar.dart';

/// Unit is movable game object that basically can only die.
/// Everything else is implement in ability mixins.
class Unit extends SpriteAnimationComponent with HasGameReference<TDGame> {
  double _hp;
  final double _maxHp;

  double get hp => _hp;
  double get maxHp => _maxHp;

  Unit({
    super.key,
    required double hp,
    required Vector2 position,
    required Vector2 size,
    Anchor? anchor,
  }) : _hp = hp,
       _maxHp = hp,
       super(position: position, size: size, anchor: anchor ?? Anchor.center);

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    await add(HealthBar(current: () => hp, max: () => maxHp));
  }

  void takeHit(double damage) {
    _hp -= damage;
    if (_hp <= 0) {
      _hp = 0;
      onKilled();
    } else {
      onDamaged(damage);
    }
  }

  void onDamaged(double damage) {}

  void onKilled() => removeNow();

  void removeNow() {
    // Keep TDGame.enemies in sync with the component tree.
    // When the enemy is mounted, prefer the game's removal API.
    if (isMounted) {
      game.removeEnemy(this);
    } else {
      removeFromParent();
    }
  }

  bool get canMove => true;

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
}
