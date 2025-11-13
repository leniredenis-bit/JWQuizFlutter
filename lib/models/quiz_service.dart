import 'dart:convert';
import 'package:flutter/services.dart';
import 'question.dart';

class QuizService {
  static List<Question>? _questions;

  static Future<List<Question>> loadQuestions() async {
    if (_questions != null) {
      return _questions!;
    }

    // Carregar como bytes e decodificar explicitamente como UTF-8
    final ByteData data = await rootBundle.load('assets/data/perguntas_atualizado.json');
    final String jsonString = utf8.decode(data.buffer.asUint8List());
    final List<dynamic> jsonList = json.decode(jsonString);
    
    _questions = jsonList.map((json) => Question.fromJson(json)).toList();
    return _questions!;
  }

  static List<Question> filterByDifficulty(List<Question> questions, int difficulty) {
    return questions.where((q) => q.dificuldade == difficulty).toList();
  }

  static List<Question> filterByTag(List<Question> questions, String tag) {
    return questions.where((q) => 
      q.tags.any((t) => t.toLowerCase() == tag.toLowerCase())
    ).toList();
  }

  static List<Question> getRandomQuestions(List<Question> questions, int count) {
    final shuffled = List<Question>.from(questions)..shuffle();
    return shuffled.take(count).toList();
  }

  // Extrair todas as tags únicas com contagem
  static Future<Map<String, int>> getAllTags() async {
    final questions = await loadQuestions();
    final Map<String, int> tagCounts = {};
    
    for (var question in questions) {
      for (var tag in question.tags) {
        final tagLower = tag.toLowerCase().trim();
        if (tagLower.isNotEmpty) {
          tagCounts[tagLower] = (tagCounts[tagLower] ?? 0) + 1;
        }
      }
    }
    
    return tagCounts;
  }

  // Obter tags ordenadas por popularidade
  static Future<List<MapEntry<String, int>>> getPopularTags({int? limit}) async {
    final tagCounts = await getAllTags();
    final sortedTags = tagCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    if (limit != null && limit < sortedTags.length) {
      return sortedTags.sublist(0, limit);
    }
    
    return sortedTags;
  }
}
