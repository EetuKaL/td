import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:td/towers/tower_controller.dart';

abstract class Tower extends SpriteComponent {
  int _level;
  final int _towerMaxLevel;
  final List<double> _damage;
  double get damage => _damage[min(_level, _damage.length) - 1];
  bool showRadius = false;

  /// Cooldown between attacks in seconds (lower = faster).
  final List<double> _fireRate;
  double get fireRate => _fireRate[min(_level, _fireRate.length) - 1];

  final List<double> _spotDistance;
  double get spotDistance =>
      _spotDistance[min(_level, _spotDistance.length) - 1];

  final List<String> _attackSound;
  String get attackSound => _attackSound[min(_level, _attackSound.length) - 1];

  final TowerController Function(Tower) controllerBuilder;
  late final TowerController action;

  Tower({
    required int towerMaxLevel,
    required List<double> damage,
    required List<double> fireRate,
    required List<double> spotDistance,
    required List<String> attackSound,

    required Vector2 position,
    required Vector2 size,
    required this.controllerBuilder,

    int level = 1,
  }) : _level = level,
       _towerMaxLevel = towerMaxLevel,
       _damage = damage,
       _fireRate = fireRate,
       _spotDistance = spotDistance,
       _attackSound = attackSound,

       super(position: position, size: size, anchor: Anchor.bottomCenter) {
    assert(
      damage.length >= 1 &&
          fireRate.length >= 1 &&
          spotDistance.length >= 1 &&
          attackSound.length >= 1,
      'Stats lists must have at least one entry each.',
    );
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await loadSpriteForLevel(_level);
    action = controllerBuilder(this);
    await add(action);
  }

  Future<Sprite> loadSprite() async {
    // Default implementation - override in subclasses
    return await Sprite.load('towers/Tower 01.png');
  }

  /// Override if the tower has different visuals per level.
  Future<Sprite> loadSpriteForLevel(int level) async => loadSprite();

  int get level => _level;

  int get towerMaxLevel => _towerMaxLevel;

  bool get isAtMaxLevel => _level >= _towerMaxLevel;

  void levelUp(Sprite evolvedSprite) {
    _level = level < _towerMaxLevel ? level + 1 : level;
    sprite = evolvedSprite;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (!showRadius) return;

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
