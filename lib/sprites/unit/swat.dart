import 'package:flame/components.dart';
import 'package:td/sprites/abilities/attack_ability.dart';
import 'package:td/sprites/unit/unit.dart';

class Swat extends Unit with AttackAbility {
  Swat({
    required Vector2 position,
    required Vector2 size,
    double hp = 150,
    double spotRange = 150,
    double damage = 10,
    double fireRate = 1.0,
  }) : super(position: position, size: size, hp: hp) {
    anchor = Anchor.bottomCenter;

    initAttackAbility(
      damage: damage,
      fireRate: fireRate,
      spotDistance: spotRange,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    updateAttack(dt);
  }
}
