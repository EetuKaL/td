import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:td/overlays/grid_overlay.dart';
import 'package:td/td.dart';
import 'package:td/utils/debug_flags.dart';

class DebugOverlay extends StatefulWidget {
  final TDGame game;

  const DebugOverlay({required this.game, super.key});

  @override
  State<DebugOverlay> createState() => _DebugOverlayState();
}

class _DebugOverlayState extends State<DebugOverlay>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) {
      if (mounted) setState(() {});
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!DebugFlags.enabled) {
      return const SizedBox.shrink();
    }

    // If game isn't loaded yet, don't try to access level/grid.
    TowerPlacementGrid? grid;
    try {
      grid = widget.game.level.grid;
    } catch (_) {
      grid = null;
    }

    if (grid == null) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _GridDebugPainter(game: widget.game, grid: grid),
      ),
    );
  }
}

class _GridDebugPainter extends CustomPainter {
  final TDGame game;
  final TowerPlacementGrid grid;

  _GridDebugPainter({required this.game, required this.grid});

  @override
  void paint(Canvas canvas, Size size) {
    _paintBeams(canvas);
    _paintGrid(canvas);
  }

  void _paintBeams(Canvas canvas) {
    if (game.debugBeams.isEmpty) return;

    for (final beam in game.debugBeams) {
      final from = game.camera.localToGlobal(beam.from);
      final to = game.camera.localToGlobal(beam.to);

      final paint = Paint()
        ..color = beam.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = beam.strokeWidth;

      canvas.drawLine(Offset(from.x, from.y), Offset(to.x, to.y), paint);
    }
  }

  void _paintGrid(Canvas canvas) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (var row = 0; row < grid.rowCount; row++) {
      for (var col = 0; col < grid.colCount; col++) {
        final origin = grid.cellOrigins[row][col];
        final worldTl = origin;
        final worldBr = origin + Vector2(grid.gridCellSize, grid.gridCellSize);

        final tl = game.camera.localToGlobal(worldTl);
        final br = game.camera.localToGlobal(worldBr);

        final rect = Rect.fromLTRB(tl.x, tl.y, br.x, br.y);
        final isInOffZone = grid.isCellInOffZone(row, col);

        paint.color = isInOffZone
            ? const Color.fromARGB(239, 238, 7, 7)
            : const Color.fromARGB(242, 0, 255, 0);

        canvas.drawRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GridDebugPainter oldDelegate) {
    return oldDelegate.game != game || oldDelegate.grid != grid;
  }
}
