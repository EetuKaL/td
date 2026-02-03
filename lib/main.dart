import 'dart:isolate';

import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:td/overlays/tower_options_overlay.dart';
import 'package:td/td.dart';

void _isolateMain(RootIsolateToken rootIsolateToken) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
}

void main() {
  RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;
  Isolate.spawn(_isolateMain, rootIsolateToken);

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GameWidget<TDGame>.controlled(
        gameFactory: TDGame.new,
        overlayBuilderMap: {
          TDGame.towerOptionsOverlayKey: (context, game) =>
              TowerOptionsOverlay(game: game),
        },
      ),
    ),
  );
}
