import 'dart:async';
import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:td/sprites/abilities/attack_ability.dart';
import 'package:td/sprites/unit/unit.dart';
import 'package:td/td.dart';
import 'package:td/sprites/towers/tower.dart';

abstract class RangedTower extends Tower
    with HasGameReference<TDGame>, AttackAbility {
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
    required super.type,
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

    // Keep ability fields in sync with tower stats.
    attackDamage = damage;
    attackFireRate = fireRate;
    attackSpotDistance = spotDistance;
    attackAimTolerance = aimTolerance;
    attackTurnSpeed = turnSpeed;
    attackIdleAngle = idleAngle;

    updateAttack(dt);
  }

  @override
  bool canAttack(Unit target) {
    // Ensure audio pool is ready (non-async update loop).
    if (_shootPool == null || _shootPoolAsset != attackSound) {
      unawaited(_ensureShootPool());
      return false;
    }
    return true;
  }

  @override
  Future<void> levelUp() async {
    await super.levelUp();
    _rebuildShootFrames();
    await _ensureShootPool();
  }

  /// Override for custom targeting logic.
  @override
  Unit? findTarget() => _findNearestInSpotDistance();

  /// Override for custom attack behavior (projectiles, AOE, etc).
  @override
  void attack(Unit target) {
    _startShootAnimation();
    _shootPool?.start();

    game.addDebugBeam(
      from: position,
      to: target.position,
      color: const Color(0xFFFF0000),
      strokeWidth: 3,
      ttlSeconds: 0.5,
    );

    target.takeHit(attackDamage);
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

  Unit? _findNearestInSpotDistance() {
    Unit? best;
    var bestDistance2 = double.infinity;

    final origin = position;
    final radius = attackSpotDistance;
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
