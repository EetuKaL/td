import 'dart:ui';

import 'package:flame/components.dart';

extension SpriteExtension on Sprite {
  /// Cut a single sprite out of a grid-based sprite sheet.
  ///
  /// Parameters:
  /// - [rowCount], [columnCount]: how many rows/cols are in the sheet.
  /// - [singleSize]: size (in pixels) of one sprite cell.
  /// - [takeFrom]: (rowIndex, colIndex) of the cell to extract.
  static Future<Sprite> singleFromSpriteSheet(
    String spriteSheetPath, {
    required int rowCount,
    required int columnCount,
    required Size singleSize,
    required ({int rowIndex, int colIndex}) takeFrom,
  }) async {
    assert(rowCount > 0 && columnCount > 0, 'rowCount/columnCount must be > 0');
    assert(
      singleSize.width > 0 && singleSize.height > 0,
      'singleSize must be > 0',
    );
    assert(
      takeFrom.rowIndex >= 0 && takeFrom.colIndex >= 0,
      'takeFrom indices must be >= 0',
    );
    assert(
      takeFrom.rowIndex < rowCount && takeFrom.colIndex < columnCount,
      'takeFrom out of bounds',
    );

    final sheet = await Sprite.load(spriteSheetPath);
    final sheetWidth = sheet.image.width.toDouble();
    final sheetHeight = sheet.image.height.toDouble();

    final expectedWidth = columnCount * singleSize.width;
    final expectedHeight = rowCount * singleSize.height;

    assert(
      sheetWidth == expectedWidth && sheetHeight == expectedHeight,
      'Sprite sheet size ($sheetWidth x $sheetHeight) does not match expected ($expectedWidth x $expectedHeight) for rowCount=$rowCount columnCount=$columnCount singleSize=$singleSize',
    );

    final srcPosition = Vector2(
      takeFrom.colIndex * singleSize.width,
      takeFrom.rowIndex * singleSize.height,
    );
    final srcSize = Vector2(singleSize.width, singleSize.height);

    return Sprite(sheet.image, srcPosition: srcPosition, srcSize: srcSize);
  }
}
