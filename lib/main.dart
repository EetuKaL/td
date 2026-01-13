import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:td/td.dart';

void main() {
  runApp(GameWidget.controlled(gameFactory: () => TDGame()));
}
