import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:td/towers/tower_controller.dart';

abstract class Tower extends SpriteComponent {
  double get fireRate => 0.0;
  double get damage => 0.0;
  double get spotDistance => 0.0;
  String get attackSound => 'towers/cannon-1-shoot.wav';
  final TowerController Function(Tower) controllerBuilder;

  late final TowerController action;

  Tower({
    required Vector2 position,
    required Vector2 size,
    required this.controllerBuilder,
  }) : super(position: position, size: size, anchor: Anchor.bottomCenter) {
    assert(
      fireRate != 0.0,
      'fireRate cannot be zero, please override it before use',
    );
    assert(
      spotDistance != 0.0,
      'spotDistance cannot be zero, please override it before use',
    );
    assert(
      damage != 0.0,
      'damage cannot be zero, please override it before use',
    );
    assert(
      attackSound.isNotEmpty,
      'attackSound cannot be empty, please override it before use',
    );
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await loadSprite();
    action = controllerBuilder(this);
    await add(action);
  }

  Future<Sprite> loadSprite() async {
    // Default implementation - override in subclasses
    return await Sprite.load('towers/Tower 01.png');
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()
      ..color = const Color(0xFFFF0000)
      ..strokeWidth = 2.0;

    // Draw the range circle centered on the tower's anchor point.
    // Note: this is local-space because Flame already transforms the canvas
    // for this component.
    final anchorPoint = anchor.toVector2()..multiply(size);
    canvas.drawCircle(
      anchorPoint.toOffset(),
      spotDistance,
      paint..style = PaintingStyle.stroke,
    );
  }
}
