import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:td/enemies/enemy.dart';
import 'package:td/td.dart';
import 'package:td/towers/manned_tower.dart';
import 'package:td/towers/ranged_tower.dart';
import 'package:td/utils/debug_beam.dart';

enum TowerAction { idle, attack }

/// Controllers work as bridge between Tower models and the game logic,
/// for keeping structure scalable and dependencies only injected
abstract class TowerController extends Component with HasGameReference<TDGame> {
  TowerAction action;
  final PositionComponent _positionSource;
  final double _spotDistance;

  double _cooldownSeconds = 0.0;

  static final Map<String, Future<AudioPool>> _audioPoolFutures = {};

  TowerController({
    required this.action,
    required PositionComponent positionSource,
    required double spotDistance,
  }) : _positionSource = positionSource,
       _spotDistance = spotDistance;

  Vector2 get _worldPosition => _positionSource.position;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await onControllerLoad();

    switch (action) {
      case TowerAction.idle:
        await onIdleLoad();
        break;
      case TowerAction.attack:
        await onAttackLoad();
        break;
    }
  }

  Future<void> onControllerLoad() async {}

  Future<void> onIdleLoad() async {}

  Future<void> onAttackLoad() async {}

  void setAction(TowerAction next) {
    if (action == next) return;
    final previous = action;
    action = next;
    _cooldownSeconds = 0.0;
    onActionChanged(previous, next);
  }

  void onActionChanged(TowerAction previous, TowerAction next) {}

  @override
  void update(double dt) {
    super.update(dt);

    final delaySeconds = actionDelaySecondsFor(action);

    if (delaySeconds > 0) {
      if (_cooldownSeconds > 0) {
        _cooldownSeconds -= dt;
        return;
      }
      _cooldownSeconds = delaySeconds;
    }

    switch (action) {
      case TowerAction.idle:
        handleIdle(dt);
        break;
      case TowerAction.attack:
        handleAttack(dt);
        break;
    }
  }

  /// Delay (cooldown) between running a given action.
  ///
  /// - Return `0.0` to run every frame (no throttling)
  /// - Return `> 0.0` to run periodically (e.g. fire rate)
  double actionDelaySecondsFor(TowerAction action) => 0.0;

  /// Override these in subclasses.
  void handleIdle(double dt) {}
  void handleAttack(double dt) {}

  Future<AudioPool> loadAudioPool(String assetPath, {int maxPlayers = 8}) {
    return _audioPoolFutures.putIfAbsent(
      assetPath,
      () => FlameAudio.createPool(assetPath, maxPlayers: maxPlayers),
    );
  }

  Enemy? _findNearestInSpotDistance() {
    Enemy? best;
    var bestDistance2 = double.infinity;

    final origin = _worldPosition;

    for (final enemy in game.enemyIndex.queryRadius(origin, _spotDistance)) {
      final d2 = enemy.position.distanceToSquared(origin);
      if (d2 <= _spotDistance * _spotDistance && d2 < bestDistance2) {
        best = enemy;
        bestDistance2 = d2;
      }
    }
    return best;
  }
}

class RangedTowerController extends TowerController {
  final double _fireRate;
  final String _attackSound;
  final double _damage;
  late final AudioPool _shootPool;

  RangedTowerController({
    required super.action,
    required String attackSound,
    required super.positionSource,
    required super.spotDistance,
    required double damage,
    required double fireRate,
  }) : _fireRate = fireRate,
       _attackSound = attackSound,
       _damage = damage;

  factory RangedTowerController.fromTower(RangedTower tower) {
    return RangedTowerController(
      action: TowerAction.attack,
      attackSound: tower.attackSound,
      positionSource: tower,
      spotDistance: tower.spotDistance,
      damage: tower.damage,
      fireRate: tower.fireRate,
    );
  }

  @override
  Future<void> onControllerLoad() async {
    await super.onControllerLoad();
    _shootPool = await loadAudioPool(_attackSound, maxPlayers: 8);
  }

  @override
  double actionDelaySecondsFor(TowerAction action) {
    switch (action) {
      case TowerAction.attack:
        return _fireRate;
      case TowerAction.idle:
        return 0.0;
    }
  }

  @override
  void handleAttack(double dt) {
    final target = _findNearestInSpotDistance();
    if (target == null) {
      return;
    }

    _shootPool.start();

    game.world.add(
      DebugBeam(
        from: _worldPosition.clone(),
        to: target.position.clone(),
        color: const Color(0xFFFF0000),
        strokeWidth: 3,
        ttlSeconds: 0.5,
      ),
    );

    target.takeHit(_damage);
  }
}

class MannedTowerController extends TowerController {
  MannedTowerController({
    required super.action,
    required super.positionSource,
    required super.spotDistance,
  });

  factory MannedTowerController.fromTower(MannedTower tower) {
    return MannedTowerController(
      action: TowerAction.idle,
      positionSource: tower,
      spotDistance: tower.spotDistance,
    );
  }
}
