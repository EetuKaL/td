import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:td/utils/td_level.dart';

class TdCamera extends CameraComponent {
  final NotifyingVector2 canvasSize;
  final Vector2 _centerAt;
  final double _zoomFactor;
  TdCamera._({
    required super.world,
    required this.canvasSize,
    required Vector2 centerAt,
    required double zoomFactor,
  }) : _centerAt = centerAt,
       _zoomFactor = zoomFactor {
    adjustCamera();
    canvasSize.addListener(() {
      adjustCamera();
    });
  }

  void adjustCamera() {
    viewfinder.anchor = Anchor.center;
    viewfinder.position = _centerAt;
    viewfinder.zoom = _zoomFactor;
  }

  static TdCamera fromMapDetails(
    World world, {
    required NotifyingVector2 canvasSize,
    required TDLevel gameMap,
  }) {
    final cam = TdCamera._(
      world: world,
      canvasSize: canvasSize,
      centerAt: gameMap.size / 2,
      zoomFactor: canvasSize.x / gameMap.size.x,
    );
    return cam;
  }
}
