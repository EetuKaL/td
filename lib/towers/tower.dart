import 'dart:math';
import 'dart:ui';
import 'dart:typed_data';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:td/utils/debug_flags.dart';

abstract class Tower extends SpriteComponent {
  static TowerDebugOverlay debugOverlay = TowerDebugOverlay.off;

  static void cycleDebugOverlay() {
    switch (debugOverlay) {
      case TowerDebugOverlay.off:
        debugOverlay = TowerDebugOverlay.bounds;
        break;
      case TowerDebugOverlay.bounds:
        debugOverlay = TowerDebugOverlay.opaqueBounds;
        break;
      case TowerDebugOverlay.opaqueBounds:
        debugOverlay = TowerDebugOverlay.off;
        break;
    }
  }

  static final Map<int, ByteData> _imageRgbaCache = {};
  static final Map<int, Future<ByteData>> _imageRgbaFutureCache = {};

  static final Map<String, Rect> _opaqueUnitRectCache = {};
  static final Map<String, Future<Rect>> _opaqueUnitRectFutureCache = {};

  /// Should be localized name of the tower.
  final String name;

  /// Image assets paths for different levels.
  final List<String> images;

  final Size? spriteSize;

  /// Shared memoization for expensive async loads (spritesheets, audio pools, etc).
  ///
  /// Stores both resolved values and in-flight futures to avoid stampeding when
  /// many towers spawn at once.
  static final Map<String, Object> _assetCache = {};
  static final Map<String, Future<Object>> _assetFutureCache = {};

  Future<T> loadCached<T>({
    required String cacheKey,
    required Future<T> Function() loader,
  }) {
    final cached = _assetCache[cacheKey];
    if (cached != null) {
      if (cached is! T) {
        throw StateError(
          'Cache key "$cacheKey" already contains ${cached.runtimeType}, expected $T',
        );
      }
      return Future.value(cached as T);
    }

    final future = _assetFutureCache.putIfAbsent(cacheKey, () async {
      try {
        final value = await loader();
        _assetCache[cacheKey] = value as Object;
        return value as Object;
      } finally {
        // Once resolved (or failed), allow future retries if needed.
        _assetFutureCache.remove(cacheKey);
      }
    });

    return future.then((value) => value as T);
  }

  int _level;
  final int _towerMaxLevel;
  final List<double> _damage;
  double get damage => _damage[min(_level, _damage.length) - 1];
  bool showRadius = false;
  late SpriteSheet sheet;

  /// Cooldown between attacks in seconds (lower = faster).
  final List<double> _fireRate;
  double get fireRate => _fireRate[min(_level, _fireRate.length) - 1];

  final List<double> _spotDistance;
  double get spotDistance =>
      _spotDistance[min(_level, _spotDistance.length) - 1];

  final List<String> _attackSound;
  String get attackSound => _attackSound[min(_level, _attackSound.length) - 1];

  /// Additional world-space offset applied when placing on the grid.
  ///
  /// Useful when the PNG art has extra transparent padding or the "visual"
  /// center of the tower isn't the geometric center of the image.
  ///
  /// Offset is applied after `placementAnchor` is set.
  Vector2 get placementOffset => Vector2.zero();

  Tower({
    required this.name,
    required this.images,
    required int towerMaxLevel,
    required List<double> damage,
    required List<double> fireRate,
    required List<double> spotDistance,
    required List<String> attackSound,
    required Vector2 position,
    required Vector2 size,
    required super.nativeAngle,
    this.spriteSize,

    int level = 1,
  }) : _level = level,
       _towerMaxLevel = towerMaxLevel,
       _damage = damage,
       _fireRate = fireRate,
       _spotDistance = spotDistance,
       _attackSound = attackSound,

       super(position: position, size: size, anchor: Anchor.bottomCenter) {
    assert(
      damage.isNotEmpty &&
          fireRate.isNotEmpty &&
          spotDistance.isNotEmpty &&
          attackSound.isNotEmpty,
      'Stats lists must have at least one entry each.',
    );
  }

  int get level => _level;

  int get towerMaxLevel => _towerMaxLevel;

  bool get isAtMaxLevel => _level >= _towerMaxLevel;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sheet = await _loadSpriteSheet(_level);
    sprite = sheet.getSprite(0, 0);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (showRadius) {
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

    _renderDebugOverlay(canvas);
  }

  void _renderDebugOverlay(Canvas canvas) {
    if (!DebugFlags.enabled) return;
    if (debugOverlay == TowerDebugOverlay.off) return;

    // Component bounds (always available)
    final boundsPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = const Color(0xFF00FF00);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), boundsPaint);

    // Anchor point crosshair
    final anchorPoint = anchor.toVector2()..multiply(size);
    final crossPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = const Color(0xFFFFFF00);
    const cross = 6.0;
    canvas.drawLine(
      (anchorPoint + Vector2(-cross, 0)).toOffset(),
      (anchorPoint + Vector2(cross, 0)).toOffset(),
      crossPaint,
    );
    canvas.drawLine(
      (anchorPoint + Vector2(0, -cross)).toOffset(),
      (anchorPoint + Vector2(0, cross)).toOffset(),
      crossPaint,
    );

    if (debugOverlay != TowerDebugOverlay.opaqueBounds) return;

    final current = sprite;
    if (current == null) return;

    final unitRect = _getOpaqueUnitRectIfReady(current);
    if (unitRect == null) {
      _scheduleOpaqueUnitRectComputation(current);
      return;
    }

    final opaquePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = const Color(0xFFFF00FF);

    final rect = Rect.fromLTWH(
      unitRect.left * size.x,
      unitRect.top * size.y,
      unitRect.width * size.x,
      unitRect.height * size.y,
    );
    canvas.drawRect(rect, opaquePaint);
  }

  Rect? _getOpaqueUnitRectIfReady(Sprite sprite) {
    final key = _opaqueKey(sprite);
    if (key == null) return null;
    return _opaqueUnitRectCache[key];
  }

  void _scheduleOpaqueUnitRectComputation(Sprite sprite) {
    final key = _opaqueKey(sprite);
    if (key == null) return;
    if (_opaqueUnitRectCache.containsKey(key) ||
        _opaqueUnitRectFutureCache.containsKey(key)) {
      return;
    }
    _opaqueUnitRectFutureCache[key] = _computeOpaqueUnitRect(sprite).then((r) {
      _opaqueUnitRectCache[key] = r;
      _opaqueUnitRectFutureCache.remove(key);
      return r;
    });
  }

  String? _opaqueKey(Sprite sprite) {
    // Flame's Sprite exposes its source rect via srcPosition/srcSize.
    // If these aren't available for some reason, we just skip opaque debug.
    final img = sprite.image;
    final sp = sprite.srcPosition;
    final ss = sprite.srcSize;

    final sx = sp.x.round();
    final sy = sp.y.round();
    final sw = ss.x.round();
    final sh = ss.y.round();
    if (sw <= 0 || sh <= 0) return null;
    return 'opaque:${identityHashCode(img)}:$sx:$sy:$sw:$sh:thr=1';
  }

  Future<Rect> _computeOpaqueUnitRect(Sprite sprite) async {
    final img = sprite.image;
    final sp = sprite.srcPosition;
    final ss = sprite.srcSize;

    final sx = sp.x.round();
    final sy = sp.y.round();
    final sw = ss.x.round();
    final sh = ss.y.round();
    if (sw <= 0 || sh <= 0) {
      return const Rect.fromLTWH(0, 0, 1, 1);
    }

    final rgba = await _getImageRgba(img);
    final w = img.width;
    final h = img.height;

    final minX0 = sx.clamp(0, w);
    final minY0 = sy.clamp(0, h);
    final maxX0 = (sx + sw).clamp(0, w);
    final maxY0 = (sy + sh).clamp(0, h);

    var minX = maxX0;
    var minY = maxY0;
    var maxX = minX0 - 1;
    var maxY = minY0 - 1;

    for (var y = minY0; y < maxY0; y++) {
      for (var x = minX0; x < maxX0; x++) {
        final idx = (y * w + x) * 4;
        final a = rgba.getUint8(idx + 3);
        if (a > 1) {
          if (x < minX) minX = x;
          if (y < minY) minY = y;
          if (x > maxX) maxX = x;
          if (y > maxY) maxY = y;
        }
      }
    }

    // Fully transparent frame.
    if (maxX < minX || maxY < minY) {
      return const Rect.fromLTWH(0, 0, 1, 1);
    }

    final left = (minX - sx) / sw;
    final top = (minY - sy) / sh;
    final width = (maxX - minX + 1) / sw;
    final height = (maxY - minY + 1) / sh;

    return Rect.fromLTWH(left, top, width, height);
  }

  static Future<ByteData> _getImageRgba(Image image) {
    final id = identityHashCode(image);
    final cached = _imageRgbaCache[id];
    if (cached != null) {
      return Future.value(cached);
    }

    return _imageRgbaFutureCache.putIfAbsent(id, () async {
      final data = await image.toByteData(format: ImageByteFormat.rawRgba);
      if (data == null) {
        // Fall back to an empty buffer (will produce a full-frame rect).
        final empty = ByteData(image.width * image.height * 4);
        _imageRgbaCache[id] = empty;
        _imageRgbaFutureCache.remove(id);
        return empty;
      }
      _imageRgbaCache[id] = data;
      _imageRgbaFutureCache.remove(id);
      return data;
    });
  }

  Future<void> levelUp() async {
    if (isAtMaxLevel) {
      throw StateError('Tower is already at max level.');
    }
    _level += 1;
    await _loadSpriteSheetCached(
      cacheKey: '$name:$_level',
      loader: () async {
        final img = await Flame.images.load(
          images[(_level - 1).clamp(0, images.length - 1)],
        );

        sheet = SpriteSheet(
          image: img,
          srcSize: Vector2(
            spriteSize?.width ?? 256.0,
            spriteSize?.height ?? 256.0,
          ),
        );

        sprite = sheet.getSprite(0, 0);
        return sheet;
      },
    );
  }

  Future<SpriteSheet> _loadSpriteSheetCached({
    required String cacheKey,
    required Future<SpriteSheet> Function() loader,
  }) {
    return loadCached<SpriteSheet>(
      cacheKey: 'spriteSheet:$cacheKey',
      loader: loader,
    );
  }

  Future<SpriteSheet> _loadSpriteSheet(int level) async {
    return _loadSpriteSheetCached(
      cacheKey: '$name:$level',
      loader: () async {
        final img = await Flame.images.load(
          images[(level - 1).clamp(0, images.length - 1)],
        );

        final sheet = SpriteSheet(
          image: img,
          srcSize: Vector2(
            spriteSize?.width ?? 256.0,
            spriteSize?.height ?? 256.0,
          ),
        );

        return sheet;
      },
    );
  }
}

enum TowerDebugOverlay { off, bounds, opaqueBounds }
