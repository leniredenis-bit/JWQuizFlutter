import '../models/question.dart';

/// Utilitário para calcular tempo de leitura de perguntas
class TimerCalculator {
  // Velocidade média de leitura: 2 palavras por segundo
  static const double _wordsPerSecond = 2.0;
  
  /// Calcula tempo de leitura para o Quiz normal (single player)
  /// Fórmula: (palavras / 2) + 10 segundos base
  static int calculateQuizTime(Question question) {
    final totalWords = _countWords(question);
    final readingTime = (totalWords / _wordsPerSecond).ceil();
    final timeWithBuffer = readingTime + 10;
    
    // Mínimo de 10 segundos, máximo de 60
    return timeWithBuffer.clamp(10, 60);
  }
  
  /// Calcula tempo de leitura para o Multiplayer Online
  /// Fórmula: (palavras / 2) + 20 segundos base (para latência de rede)
  static int calculateMultiplayerTime(Question question) {
    final totalWords = _countWords(question);
    final readingTime = (totalWords / _wordsPerSecond).ceil();
    final timeWithBuffer = readingTime + 20;
    
    // Mínimo de 15 segundos, máximo de 90
    return timeWithBuffer.clamp(15, 90);
  }
  
  /// Conta palavras em uma pergunta (enunciado + todas as opções)
  static int _countWords(Question question) {
    int totalWords = 0;
    
    // Contar palavras do enunciado
    totalWords += _countWordsInText(question.pergunta);
    
    // Contar palavras de todas as opções
    for (final opcao in question.opcoes) {
      totalWords += _countWordsInText(opcao);
    }
    
    return totalWords;
  }
  
  /// Conta palavras em um texto (split por espaços)
  static int _countWordsInText(String text) {
    if (text.trim().isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).length;
  }
  
  /// Calcula tempo médio para uma lista de perguntas (útil para configuração de sala)
  static int calculateAverageTime(List<Question> questions, {bool isMultiplayer = false}) {
    if (questions.isEmpty) return isMultiplayer ? 20 : 15;
    
    int totalTime = 0;
    for (final question in questions) {
      totalTime += isMultiplayer 
          ? calculateMultiplayerTime(question) 
          : calculateQuizTime(question);
    }
    
    return (totalTime / questions.length).round();
  }
}
