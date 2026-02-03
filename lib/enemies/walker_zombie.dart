import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:td/enemies/enemy.dart';

class WalkerZombie extends Enemy {
  WalkerZombie({
    required super.path,
    required super.position,
    required super.size,
    int? variant,
  }) : _variant = variant,
       super(hp: 120, speed: 35, range: 10) {
    anchor = Anchor.bottomCenter;
  }

  final int? _variant;

  static final Random _rng = Random();

  @override
  Future<void> onLoad() async {
    final variant = _variant ?? (_rng.nextInt(4) + 1);
    final assetPath = 'enemies/zombie_walker/$variant/Walk.png';

    final image = await Flame.images.load(assetPath);

    animation = SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        amount: image.width ~/ 128,
        stepTime: 0.12,
        textureSize: Vector2(128, 128),
        loop: true,
      ),
    );

    return super.onLoad();
  }
}
