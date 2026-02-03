import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:td/l10n/generated/app_localizations.dart';
import 'package:td/state/game_bloc/game_bloc.dart';
import 'package:td/overlays/debug_overlay.dart';
import 'package:td/overlays/tower_options_overlay.dart';
import 'package:td/td.dart';

void main() {
  runApp(const _TDApp());
}

class _TDApp extends StatelessWidget {
  const _TDApp();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GameBloc(),
      child: Builder(
        builder: (context) {
          final game = TDGame(gameBloc: context.read<GameBloc>());

          return MaterialApp(
            supportedLocales: S.supportedLocales,
            localizationsDelegates: S.localizationsDelegates,
            debugShowCheckedModeBanner: false,
            home: GameWidget<TDGame>.controlled(
              gameFactory: () => game,
              overlayBuilderMap: {
                TDGame.towerOptionsOverlayKey: (context, game) =>
                    TowerOptionsOverlay(game: game),
                TDGame.debugOverlayKey: (context, game) =>
                    DebugOverlay(game: game),
              },
            ),
          );
        },
      ),
    );
  }
}
