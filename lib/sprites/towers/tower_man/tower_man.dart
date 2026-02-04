import 'package:flame/components.dart';

abstract class TowerMan extends SpriteComponent {
  static double walkSpeed = 0.0;
  static double damage = 0.0;
  static double range = 0.0;
  static double health = 0.0;

  TowerMan({required super.position, required super.size})
    : super(anchor: Anchor.center);

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
