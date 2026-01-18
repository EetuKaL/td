import 'dart:ui';
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:td/towers/tower.dart';

class TowerOptionsOverlay extends Component with ParentIsA<Viewport> {
  final Tower tower;
  TowerOptionsOverlay({required this.tower});

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final viewportSize = parent.size;
    final paint = Paint()..color = const Color(0xAA000000);

    double height = 132.0;

    canvas.drawRect(
      Rect.fromLTWH(0, viewportSize.y - height, viewportSize.x, height),
      paint,
    );

    final img = tower.sprite?.toImageSync();

    if (img != null) {
      canvas.drawImage(img, Offset(16, viewportSize.y - height), paint);
    }
    height -= 38.0;
    final marginLeft = (img?.width ?? 0) + 48.0;
    final typeParagraph =
        (ParagraphBuilder(
                ParagraphStyle(
                  fontSize: 16,
                  textAlign: TextAlign.left,
                  maxLines: 1,
                ),
              )
              ..pushStyle(TextStyle(color: Color(0xFFFFFFFF)))
              ..addText('Tower: ${tower.runtimeType}'))
            .build();

    typeParagraph.layout(ParagraphConstraints(width: viewportSize.x));
    canvas.drawParagraph(
      typeParagraph,
      Offset(marginLeft, viewportSize.y - height),
    );
    height -= 24.0;

    final damageParagraph =
        (ParagraphBuilder(
                ParagraphStyle(
                  fontSize: 16,
                  textAlign: TextAlign.left,
                  maxLines: 1,
                ),
              )
              ..pushStyle(TextStyle(color: Color(0xFFFFFFFF)))
              ..addText('Damage: ${tower.damage}'))
            .build();
    damageParagraph.layout(ParagraphConstraints(width: viewportSize.x));
    canvas.drawParagraph(
      damageParagraph,
      Offset(marginLeft, viewportSize.y - height),
    );
    height -= 24.0;

    final fireRateParagraph =
        (ParagraphBuilder(
                ParagraphStyle(
                  fontSize: 16,
                  textAlign: TextAlign.left,
                  maxLines: 1,
                ),
              )
              ..pushStyle(TextStyle(color: Color(0xFFFFFFFF)))
              ..addText('Fire rate: ${tower.fireRate}'))
            .build();
    fireRateParagraph.layout(ParagraphConstraints(width: viewportSize.x));
    canvas.drawParagraph(
      fireRateParagraph,
      Offset(marginLeft, viewportSize.y - height),
    );
    height -= 24.0;
    final spotDistanceParagraph =
        (ParagraphBuilder(
                ParagraphStyle(
                  fontSize: 16,
                  textAlign: TextAlign.left,
                  maxLines: 1,
                ),
              )
              ..pushStyle(TextStyle(color: Color(0xFFFFFFFF)))
              ..addText('Spot Distance: ${tower.spotDistance}'))
            .build();
    spotDistanceParagraph.layout(ParagraphConstraints(width: viewportSize.x));
    canvas.drawParagraph(
      spotDistanceParagraph,
      Offset(marginLeft, viewportSize.y - height),
    );
  }
}
