import 'dart:ui';

import 'package:flame/components.dart';

class DebugBeamData {
  Vector2 from;
  Vector2 to;
  Color color;
  double strokeWidth;
  double timeLeftSeconds;

  DebugBeamData({
    required this.from,
    required this.to,
    required this.timeLeftSeconds,
    this.color = const Color.fromARGB(255, 247, 0, 255),
    this.strokeWidth = 2.0,
  });
}
