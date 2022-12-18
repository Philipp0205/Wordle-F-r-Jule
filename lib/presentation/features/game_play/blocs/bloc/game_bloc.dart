import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';

import 'package:equatable/equatable.dart';

import '../../../../../data/datasources/local/data_manager.dart';
import '../../../../../data/models/guess_daily_result/guess_daily_result.dart';
import '../../../../../data/repositories/app_repository.dart';
import '../../../../utils/game_mode.dart';
import '../../../../utils/type/input_type.dart';
import '../../../../widgets/keyboard_widget.dart';

part 'game_event.dart';

part 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final AppRepository repository;
  final AppPreferences preferences;

  GameBloc({required this.repository, required this.preferences})
      : super(GameState(inputs: initialInputs)) {
    on<InputEvent>(_handleInputEvent);
    on<VerifyGuessEvent>(_verifyGuessEvent);
    on<ResetNewGameEvent>(_onResetGameEvent);
    on<ResetCheckStateEvent>(_onResetCheckState);
    on<InitGameEvent>(_initGame);
    on<EndGameEvent>(_endGame);
  }

  void _onResetCheckState(ResetCheckStateEvent event, Emitter<GameState> emit) {
    emit(state.copyWith(
      status: CheckState.idle,
    ));
  }

  void _onResetGameEvent(ResetNewGameEvent event, Emitter<GameState> emit) {
    List<String> words = preferences.getWords();
    emit(GameState(inputs: initialInputs, words: words));
  }

  /// Called one time on initial launch.
  /// Saves the two words to local storage
  void _initGame(InitGameEvent event, Emitter<GameState> emit) {
    List<String> words = ['SUPER', 'BLOOM'];
    preferences.saveWords(words);

    emit(state.copyWith(
      words: words,
    ));
  }

  void _verifyGuessEvent(
      VerifyGuessEvent event, Emitter<GameState> emit) async {
    if (event.guess.length != WORD_LEN) return;

    try {
      //! need find better solution for word check
      // final checkWord = words.all.contains(event.guess.toLowerCase());
      // final checkWord = state.words?.contains(event.guess);

      // if (checkWord!) {
      //   emit(state.copyWith(
      //     status: CheckState.mismatched,
      //     // status: CheckState.success,
      //   ));
      //   return;
      // }

      emit(state.copyWith(
        status: CheckState.loading,
      ));

      final guess = event.guess;
      // final results = await repository.verifyGuessDaily(guess: guess);
      final results = repository.verifyGuessDailyLocal(
          guess: guess, solution: state.words!.first);
      final inputs = state.inputs;
      final currentAttempt = state.curAttemptCount;
      final currentGuess = inputs?[currentAttempt];

      final resultInput = currentGuess
          ?.mapIndexed(
            (index, element) =>
                element.copyWith(state: _mapInputState(results[index].result)),
          )
          .toList();

      inputs?[currentAttempt] = resultInput!;

      final isCorrect = _isCorrectGuess(results);

      var keyInputted = state.keyInputted ?? {};

      for (var e in results) {
        final preState =
            keyInputted[e.guess?.toUpperCase() ?? ''] ?? InputState.initial;
        if (preState != InputState.correct) {
          keyInputted[e.guess?.toUpperCase() ?? ''] = _mapInputState(e.result);
        }
      }

      List<String>? words = state.words;
      bool isEnd = false;

      if (isCorrect) {
        words = preferences.getWords();

        words.removeAt(0);
        preferences.saveWords(words);
        print('words: $words');

        if (words.isEmpty) {
          isEnd = true;
        }
      }

      emit(
        state.copyWith(
          inputs: inputs,
          curAttemptCount: currentAttempt + 1,
          curAttempts: '',
          isWin: isCorrect,
          isEnd: isEnd,
          words: words,
          acceptInput: currentAttempt + 1 < MAX_ATTEMPT,
          status: CheckState.success,
          keyInputted: keyInputted,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: CheckState.failure,
        ),
      );
    }
  }

  InputState _mapInputState(String? result) {
    if (result == InputState.present.name) {
      return InputState.present;
    }
    if (result == InputState.correct.name) {
      return InputState.correct;
    }

    return InputState.absent;
  }

  bool _isCorrectGuess(List<GuessDailyResult> results) {
    final isNotCorrect = results.any((element) => element.result != 'correct');
    return !isNotCorrect;
  }

  void _handleInputEvent(InputEvent event, Emitter<GameState> emit) {
    final type = event.type;
    final curAttempts = state.curAttempts;
    final r = state.curAttemptCount;
    final inputs = state.inputs;

    switch (type) {
      case InputType.back:
        if (curAttempts.isNotEmpty) {
          inputs?[r][curAttempts.length - 1].char = "";

          emit(
            state.copyWith(
              curAttempts: curAttempts.substring(0, curAttempts.length - 1),
              inputs: inputs,
            ),
          );
        }

        break;
      case InputType.character:
        if (event.char != null &&
            state.acceptInput &&
            curAttempts.length < WORD_LEN) {
          final newWord = '$curAttempts${event.char!}';
          inputs?[r][curAttempts.length].char = event.char!;

          emit(state.copyWith(
            curAttempts: newWord,
            inputs: inputs,
          ));
        }
        break;
      case InputType.confirm:
        if (curAttempts.length < WORD_LEN) break;
        add(VerifyGuessEvent(guess: curAttempts));
        break;
    }
  }

  void _endGame(EndGameEvent event, Emitter<GameState> emit) {}
}

List<List<PanelItem>> get initialInputs {
  return List.generate(
    MAX_ATTEMPT,
    (index) => List.generate(
      WORD_LEN,
      (i) => PanelItem(),
    ),
  );
}

class PanelItem {
  String char;
  InputState state;

  PanelItem({
    this.char = '',
    this.state = InputState.initial,
  });

  PanelItem copyWith({
    String? char,
    InputState? state,
  }) {
    return PanelItem(
      char: char ?? this.char,
      state: state ?? this.state,
    );
  }
}
