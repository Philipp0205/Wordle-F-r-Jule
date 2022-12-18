part of 'game_bloc.dart';

enum CheckState { idle, loading, success, failure, mismatched }

class GameState extends Equatable {
  const GameState({
    this.curAttempts = '',
    this.curAttemptCount = 0,
    this.acceptInput = true,
    this.inputs,
    this.isWin = false,
    this.status = CheckState.idle,
    this.keyInputted,
    this.words,
    this.isEnd = false,
  });

  final String curAttempts;
  final int curAttemptCount;
  final bool acceptInput;
  final List<List<PanelItem>>? inputs;
  final bool isWin;
  final bool isEnd;
  final CheckState status;
  final Map<String, InputState>? keyInputted;
  final List<String>? words;

  @override
  List<Object?> get props => [
        curAttempts,
        curAttemptCount,
        acceptInput,
        inputs,
        isWin,
        status,
        keyInputted,
        words
      ];

  GameState copyWith(
      {String? curAttempts,
      int? curAttemptCount,
      bool? acceptInput,
      bool? isEnd,
      List<List<PanelItem>>? inputs,
      bool? isWin,
      CheckState? status,
      List<String>? words,
      Map<String, InputState>? keyInputted}) {
    return GameState(
      curAttempts: curAttempts ?? this.curAttempts,
      curAttemptCount: curAttemptCount ?? this.curAttemptCount,
      acceptInput: acceptInput ?? this.acceptInput,
      inputs: inputs ?? this.inputs,
      isWin: isWin ?? this.isWin,
      status: status ?? this.status,
      keyInputted: keyInputted ?? this.keyInputted,
      words: words ?? this.words,
      isEnd: isEnd ?? this.isEnd,
    );
  }
}
