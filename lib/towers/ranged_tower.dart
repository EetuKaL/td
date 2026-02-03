import 'dart:async';
import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:td/enemies/enemy.dart';
import 'package:td/td.dart';
import 'package:td/towers/tower.dart';
import 'package:td/utils/debug_beam.dart';

abstract class RangedTower extends Tower with HasGameReference<TDGame> {
  // How much aim can be off
  final double aimTolerance;

  /// How closely the tower must be aimed at the target before it can shoot.
  ///
  /// With finite [turnSpeed], this prevents shooting "through the back" while
  /// the sprite is still rotating.
  ///
  /// Value is in radians. Default is 5 degrees.
  final double turnSpeed;
  RangedTower({
    required super.name,
    required super.images,
    required super.towerMaxLevel,
    required super.damage,
    required super.fireRate,
    required super.spotDistance,
    required super.attackSound,
    required super.position,
    required super.size,
    required super.nativeAngle,
    super.level = 1,
    this.aimTolerance = 5 * math.pi / 180,
    this.turnSpeed = double.infinity,
  });

  /// Seconds per animation frame while shooting.
  /// Override to speed up/slow down attack animation.
  double get shootFrameSeconds => 1 / 20;

  double _cooldownSeconds = 0.0;

  AudioPool? _shootPool;
  String? _shootPoolAsset;
  Future<AudioPool>? _shootPoolFuture;

  List<Sprite>? _shootFrames;
  bool _isShootAnimating = false;
  int _shootFrameIndex = 0;
  double _shootFrameClock = 0.0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _rebuildShootFrames();
    await _ensureShootPool();
  }

  @override
  void update(double dt) {
    super.update(dt);

    _updateShootAnimation(dt);

    final target = findTarget();

    // Track desired aim so we can gate firing when turn speed is finite.
    double? desiredAimAngle;
    var isTargetExactlyOnTower = false;

    if (target != null) {
      final dir = target.position - position;
      if (dir.length2 > 0) {
        desiredAimAngle = dir.screenAngle();
        _turnTowards(desiredAimAngle, dt);
      } else {
        // Same position: direction is undefined, but we should still allow
        // shooting.
        isTargetExactlyOnTower = true;
      }
    } else {
      _turnTowards(idleAngle, dt);
    }

    if (_cooldownSeconds > 0) {
      _cooldownSeconds -= dt;
      return;
    }

    if (target == null) return;

    // If the enemy has a defined direction, only shoot when we're aimed.
    if (!isTargetExactlyOnTower && desiredAimAngle != null) {
      if (!_isAimedAt(desiredAimAngle)) {
        return;
      }
    }

    // Ensure audio pool is ready (non-async update loop).
    if (_shootPool == null || _shootPoolAsset != attackSound) {
      unawaited(_ensureShootPool());
      return;
    }

    shoot(target);
    _cooldownSeconds = fireRate;
  }

  void _turnTowards(double targetAngle, double dt) {
    final speed = turnSpeed;
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
    final tolerance = aimTolerance;
    if (tolerance.isNaN || tolerance.isNegative) {
      return true;
    }
    final diff = _normalizeAngle(_normalizeAngle(targetAngle) - angle);
    return diff.abs() <= tolerance;
  }

  @override
  Future<void> levelUp() async {
    await super.levelUp();
    _rebuildShootFrames();
    await _ensureShootPool();
  }

  /// Override for custom targeting logic.
  Enemy? findTarget() => _findNearestInSpotDistance();

  /// Override for custom attack behavior (projectiles, AOE, etc).
  void shoot(Enemy target) {
    _startShootAnimation();
    _shootPool?.start();

    game.world.add(
      DebugBeam(
        from: position.clone(),
        to: target.position.clone(),
        color: const Color(0xFFFF0000),
        strokeWidth: 3,
        ttlSeconds: 0.5,
      ),
    );

    target.takeHit(damage);
  }

  void _rebuildShootFrames() {
    final frames = <Sprite>[];
    for (var row = 0; row < sheet.rows; row++) {
      for (var col = 0; col < sheet.columns; col++) {
        frames.add(sheet.getSprite(row, col));
      }
    }
    if (frames.isEmpty) {
      frames.add(sheet.getSprite(0, 0));
    }

    _shootFrames = frames;
    _isShootAnimating = false;
    _shootFrameIndex = 0;
    _shootFrameClock = 0.0;

    // Ensure idle frame is frame 0.
    sprite = frames.first;
  }

  void _startShootAnimation() {
    final frames = _shootFrames;
    if (frames == null || frames.length <= 1) {
      return;
    }

    _isShootAnimating = true;
    _shootFrameIndex = 0;
    _shootFrameClock = 0.0;
    sprite = frames.first;
  }

  void _updateShootAnimation(double dt) {
    if (!_isShootAnimating) return;

    final frames = _shootFrames;
    if (frames == null || frames.length <= 1) {
      _isShootAnimating = false;
      return;
    }

    _shootFrameClock += dt;
    while (_shootFrameClock >= shootFrameSeconds) {
      _shootFrameClock -= shootFrameSeconds;
      _shootFrameIndex += 1;

      if (_shootFrameIndex >= frames.length) {
        // Finished: return to idle frame 0.
        _isShootAnimating = false;
        _shootFrameIndex = 0;
        sprite = frames.first;
        return;
      }

      sprite = frames[_shootFrameIndex];
    }
  }

  Future<AudioPool> _loadAudioPoolCached(
    String assetPath, {
    int maxPlayers = 8,
  }) {
    return loadCached<AudioPool>(
      cacheKey: 'audioPool:$assetPath:maxPlayers=$maxPlayers',
      loader: () => FlameAudio.createPool(assetPath, maxPlayers: maxPlayers),
    );
  }

  Future<void> _ensureShootPool() async {
    final asset = attackSound;
    if (_shootPoolAsset == asset && _shootPool != null) {
      return;
    }

    // Avoid stampeding futures if something calls this repeatedly.
    if (_shootPoolFuture != null && _shootPoolAsset == asset) {
      return;
    }

    _shootPoolAsset = asset;
    _shootPoolFuture = _loadAudioPoolCached(asset, maxPlayers: 8);
    _shootPool = await _shootPoolFuture!;
  }

  Enemy? _findNearestInSpotDistance() {
    Enemy? best;
    var bestDistance2 = double.infinity;

    final origin = position;
    final radius = spotDistance;
    final radius2 = radius * radius;

    for (final enemy in game.enemyIndex.queryRadius(origin, radius)) {
      final d2 = enemy.position.distanceToSquared(origin);
      if (d2 <= radius2 && d2 < bestDistance2) {
        best = enemy;
        bestDistance2 = d2;
      }
    }

    return best;
  }
}
