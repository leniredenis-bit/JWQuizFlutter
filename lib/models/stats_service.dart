import 'package:shared_preferences/shared_preferences.dart';

class StatsService {
  static const String _keyTotalQuizzes = 'total_quizzes';
  static const String _keyTotalScore = 'total_score';
  static const String _keyTotalQuestions = 'total_questions';
  static const String _keyCorrectAnswers = 'correct_answers';
  static const String _keyBestScore = 'best_score';
  static const String _keyMemoryGamesPlayed = 'memory_games_played';
  static const String _keyBestMemoryTime = 'best_memory_time';

  // Salvar estatísticas de quiz
  static Future<void> saveQuizStats({
    required int score,
    required int questionsAnswered,
    required int correctAnswers,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Atualizar totais
    final totalQuizzes = (prefs.getInt(_keyTotalQuizzes) ?? 0) + 1;
    final totalScore = (prefs.getInt(_keyTotalScore) ?? 0) + score;
    final totalQuestions = (prefs.getInt(_keyTotalQuestions) ?? 0) + questionsAnswered;
    final totalCorrect = (prefs.getInt(_keyCorrectAnswers) ?? 0) + correctAnswers;
    final bestScore = prefs.getInt(_keyBestScore) ?? 0;
    
    await prefs.setInt(_keyTotalQuizzes, totalQuizzes);
    await prefs.setInt(_keyTotalScore, totalScore);
    await prefs.setInt(_keyTotalQuestions, totalQuestions);
    await prefs.setInt(_keyCorrectAnswers, totalCorrect);
    
    // Atualizar melhor score se necessário
    if (score > bestScore) {
      await prefs.setInt(_keyBestScore, score);
    }
  }

  // Salvar estatísticas do jogo da memória
  static Future<void> saveMemoryGameStats({
    required int timeInSeconds,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    final gamesPlayed = (prefs.getInt(_keyMemoryGamesPlayed) ?? 0) + 1;
    final bestTime = prefs.getInt(_keyBestMemoryTime) ?? 0;
    
    await prefs.setInt(_keyMemoryGamesPlayed, gamesPlayed);
    
    // Atualizar melhor tempo se for menor (ou se for o primeiro)
    if (bestTime == 0 || timeInSeconds < bestTime) {
      await prefs.setInt(_keyBestMemoryTime, timeInSeconds);
    }
  }

  // Carregar todas as estatísticas
  static Future<Map<String, int>> loadAllStats() async {
    final prefs = await SharedPreferences.getInstance();
    
    return {
      'totalQuizzes': prefs.getInt(_keyTotalQuizzes) ?? 0,
      'totalScore': prefs.getInt(_keyTotalScore) ?? 0,
      'totalQuestions': prefs.getInt(_keyTotalQuestions) ?? 0,
      'correctAnswers': prefs.getInt(_keyCorrectAnswers) ?? 0,
      'bestScore': prefs.getInt(_keyBestScore) ?? 0,
      'memoryGamesPlayed': prefs.getInt(_keyMemoryGamesPlayed) ?? 0,
      'bestMemoryTime': prefs.getInt(_keyBestMemoryTime) ?? 0,
    };
  }

  // Resetar todas as estatísticas
  static Future<void> resetStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
