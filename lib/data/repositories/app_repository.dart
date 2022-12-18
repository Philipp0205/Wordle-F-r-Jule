import '../datasources/local/data_manager.dart';
import '../datasources/remote/app_api.dart';
import '../models/guess_daily_result/guess_daily_result.dart';

part './impl/app_repository_impl.dart';

abstract class AppRepository {
  void setLanguageCode({required String lang});
  void setTheme({required bool isDark});

  Future<List<GuessDailyResult>> verifyGuessDaily(
      {required String guess, int size = 5});

  List<GuessDailyResult> verifyGuessDailyLocal(
      {required String guess, required String solution, int size = 5, }) {
    // Iterate through each character in the guess
    // and compare it to the solution
    final List<GuessDailyResult> results = [];
    for (int i = 0; i < guess.length; i++) {
      final char = guess[i];
      final solutionChar = solution[i];
      if (char == solutionChar) {
        results.add(GuessDailyResult(
          slot: i,
          guess:guess,
          result: 'correct',
        ));
      } else if (solution.contains(char)) {
        results.add(GuessDailyResult(
          slot: i,
          guess: guess,
          result: 'present',
        ));
      } else {
        results.add(GuessDailyResult(
          slot: i,
          guess: guess,
          result: 'incorrect',
        ));
      }
    }

    return results;
  }
}
