import 'package:bloc/bloc.dart';
import 'package:td/state/game_bloc/src/game_event.dart';
import 'package:td/state/game_bloc/src/game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  GameBloc() : super(const GameState()) {
    on<TowerSelect>((event, emit) {
      emit(GameState(selectedTower: event.tower));
    });

    on<RefreshSelectedTower>((event, emit) {
      emit(GameState(selectedTower: state.selectedTower));
    });
  }
}
