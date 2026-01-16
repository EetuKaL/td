import 'package:flame/components.dart';

abstract class TowerMan extends SpriteComponent {
  final double walkSpeed;
  final double damage;
  final double range;
  final double health;

  TowerMan({
    required this.walkSpeed,
    required this.damage,
    required this.range,
    required this.health,
    required super.position,
    required super.size,
  }) : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await loadAnimation();
  }

  Future<Sprite> loadAnimation() async {
    // Default implementation - override in subclasses
    return Sprite.load('tower_Men/swordman.png');
  }
}

class SwordMan extends TowerMan {
  SwordMan({required super.position, required super.size})
    : super(walkSpeed: 50.0, damage: 10.0, range: 30.0, health: 100.0);
}
