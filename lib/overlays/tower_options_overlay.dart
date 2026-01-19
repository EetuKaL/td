import 'dart:ui';
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:td/towers/tower.dart';
import 'package:td/overlays/upgrade_level_button.dart';

class TowerOptionsOverlay extends PositionComponent with ParentIsA<Viewport> {
  final Tower tower;
  TowerOptionsOverlay({required this.tower});

  static const double panelHeight = 132.0;
  static const double panelPadding = 16.0;

  late final UpgradeLevelButton _upgradeButton;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _upgradeButton = UpgradeLevelButton(tower: tower);
    await add(_upgradeButton);
  }

  @override
  void onMount() {
    super.onMount();
    position = Vector2.zero();
    size = parent.size;
    anchor = Anchor.topLeft;
    _layoutChildren();
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    // Viewport size can change when resizing the window.
    size = parent.size;
    _layoutChildren();
  }

  void _layoutChildren() {
    // Place upgrade button on the right side of the panel.
    final yTop = size.y - panelHeight;
    _upgradeButton.position = Vector2(
      size.x - panelPadding - (_upgradeButton.size.x / 2),
      yTop + (panelHeight / 2),
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final viewportSize = size;
    final paint = Paint()..color = const Color(0xAA000000);

    double height = panelHeight;

    canvas.drawRect(
      Rect.fromLTWH(0, viewportSize.y - height, viewportSize.x, height),
      paint,
    );

    final img = tower.sprite?.toImageSync();

    // Keep this safe for any max level count.
    final levelLabel = 'Lv ${tower.level}';

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
              ..addText('Tower: ${tower.runtimeType} $levelLabel'))
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
