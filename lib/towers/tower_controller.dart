import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:td/enemies/enemy.dart';
import 'package:td/towers/manned_tower.dart';
import 'package:td/towers/ranged_tower.dart';
import 'package:td/utils/debug_beam.dart';

enum TowerAction { idle, attack }

/// Controllers work as bridge between Tower and the game logic,
/// for keeping structure scalable and dependencies only injected
abstract class TowerController extends Component {
  static AudioPool? _shootPool;
  TowerAction action;
  dynamic _actionData;
  final Vector2 _position;
  final double _spotDistance;
  void Function()? _onUpdate;
  final double _damage;
  final String attackSound;

  TowerController({
    required this.attackSound,
    required this.action,
    required Vector2 position,
    required double spotDistance,
    required double damage,
    List<Enemy>? enemies,
  }) : _position = position,
       _spotDistance = spotDistance,
       _damage = damage,
       _actionData = enemies {
    assert(action != TowerAction.idle);
  }
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _shootPool ??= await FlameAudio.createPool(attackSound, maxPlayers: 8);
  }

  @override
  void update(double dt) {
    super.update(dt);
    switch (action) {
      case TowerAction.idle:
        _handleIdle();
        break;
      case TowerAction.attack:
        final nearestEnemy = _findNearestEnemyInRange(
          _actionData as List<Enemy>,
        );
        if (nearestEnemy != null) {
          nearestEnemy.takeHit(_damage);
        }
        _handleAttack(dt, _actionData as List<Enemy>, nearestEnemy);
        break;
    }
  }

  void actionToAttack(List<Enemy> enemies, Function() attackCallback) {
    action = TowerAction.attack;
    _actionData = enemies;
    FlameAudio.play(attackSound);
    _onUpdate = attackCallback;
  }

            final enemies = _actionData;
            if (enemies is! List<Enemy>) {
              // Not armed with a target list yet; stay safe.
              _handleAttack(dt, const <Enemy>[], null);
              break;
            }
            final nearestEnemy = _findNearestEnemyInRange(enemies);
            _handleAttack(dt, enemies, nearestEnemy);
    // No-op for now
    _onUpdate?.call();
  }

  void _handleAttack(double dt, List<Enemy> enemies, Enemy? target) {
    _onUpdate?.call();
    print("TowerController: Handling attack on target $target");
  }

  Enemy? _findNearestEnemyInRange(List<Enemy> enemies) {
    Enemy? best;
    var bestDistance2 = double.infinity;

    for (final enemy in enemies) {
      final d2 = enemy.position.distanceToSquared(_position);
      if (d2 <= _spotDistance * _spotDistance && d2 < bestDistance2) {
        best = enemy;
        bestDistance2 = d2;
      }
    }

    return best;
  }
}

class RangedTowerController extends TowerController {
  double _coolDown = 0.0;
  final double _fireRate;
  RangedTowerController({
    required super.action,
    required super.attackSound,
    required super.position,
    required super.spotDistance,
    required super.damage,
    required double fireRate,
  }) : _fireRate = fireRate;

  factory RangedTowerController.fromTower(RangedTower tower) {
    return RangedTowerController(
      action: TowerAction.idle,
      attackSound: tower.attackSound,
      position: tower.position,
      spotDistance: tower.spotDistance,
      damage: tower.damage,
      fireRate: tower.fireRate,
    );
  }

  @override
  void _handleAttack(double dt, List<Enemy> enemies, Enemy? target) {
    super._handleAttack(dt, enemies, target);
    _coolDown -= dt;
    if (_coolDown <= 0.0 && target != null) {
      // Fire!
      target.takeHit(_damage);
      DebugBeam(
        from: _position.clone(),
        to: target.position.clone(),
      ).addToParent(parent!);
      // Gun smoking.. better wait a bit.
      _coolDown = 1.0 / (_fireRate > 0 ? _fireRate : 1.0);
    }
  }
}

class MannedTowerController extends TowerController {
  MannedTowerController({
    required super.attackSound,
    required super.action,
    required super.position,
    required super.spotDistance,
    required super.damage,
  });

  factory MannedTowerController.fromTower(MannedTower tower) {
    return MannedTowerController(
      action: TowerAction.idle,
      attackSound: tower.attackSound,
      position: tower.position,
      spotDistance: tower.spotDistance,
      damage: tower.damage,
    );
  }
}
