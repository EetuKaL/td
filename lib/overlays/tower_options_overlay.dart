import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flame/sprite.dart';
import 'package:td/state/game_bloc/game_bloc.dart';
import 'package:td/td.dart';

class TowerOptionsOverlay extends StatelessWidget {
  final TDGame game;

  const TowerOptionsOverlay({required this.game, super.key});

  static const double panelHeight = 132.0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        final tower = state.selectedTower;
        if (tower == null) return const SizedBox.shrink();

        return Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            color: Colors.transparent,
            child: Container(
              height: panelHeight,
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: Color(0xAA000000)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _TowerSpritePreview(sprite: tower.sprite),
                  Expanded(
                    child: DefaultTextStyle(
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Tower: ${tower.runtimeType} (Lv ${tower.level})',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text('Damage: ${tower.damage}'),
                          Text('Fire rate: ${tower.fireRate}'),
                          Text('Spot Distance: ${tower.spotDistance}'),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: tower.isAtMaxLevel
                        ? null
                        : () async {
                            final bloc = context.read<GameBloc>();
                            await tower.levelUp();
                            bloc.add(const RefreshSelectedTower());
                          },
                    icon: const Icon(Icons.upgrade, color: Colors.white),
                    tooltip: tower.isAtMaxLevel
                        ? 'Max level'
                        : 'Upgrade to Lv ${tower.level + 1}',
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: game.hideTowerOptions,
                    icon: const Icon(Icons.close, color: Colors.white),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TowerSpritePreview extends StatelessWidget {
  final Sprite? sprite;

  const _TowerSpritePreview({required this.sprite});

  @override
  Widget build(BuildContext context) {
    const previewSize = 128.0;

    final s = sprite;
    if (s == null) {
      return const SizedBox(width: previewSize, height: previewSize);
    }

    return SizedBox(
      width: previewSize,
      height: previewSize,
      child: CustomPaint(painter: _SpritePainter(s)),
    );
  }
}

class _SpritePainter extends CustomPainter {
  final Sprite sprite;

  _SpritePainter(this.sprite);

  @override
  void paint(Canvas canvas, Size size) {
    final src = Rect.fromLTWH(
      sprite.srcPosition.x,
      sprite.srcPosition.y,
      sprite.srcSize.x,
      sprite.srcSize.y,
    );

    final srcW = src.width;
    final srcH = src.height;
    if (srcW <= 0 || srcH <= 0) return;

    // Contain the sprite inside the destination box while keeping aspect ratio.
    final scale = math.min(size.width / srcW, size.height / srcH);
    final dstW = srcW * scale;
    final dstH = srcH * scale;
    final dx = (size.width - dstW) / 2;
    final dy = (size.height - dstH) / 2;
    final dst = Rect.fromLTWH(dx, dy, dstW, dstH);

    canvas.drawImageRect(
      sprite.image,
      src,
      dst,
      Paint()..filterQuality = FilterQuality.none,
    );
  }

  @override
  bool shouldRepaint(covariant _SpritePainter oldDelegate) {
    return oldDelegate.sprite.image != sprite.image ||
        oldDelegate.sprite.srcPosition != sprite.srcPosition ||
        oldDelegate.sprite.srcSize != sprite.srcSize;
  }
}
