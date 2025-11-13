class Question {
  final String id;
  final String pergunta;
  final List<String> opcoes;
  final int respostaCorreta; // Índice 0-3
  final int dificuldade; // 1=Fácil, 2=Médio, 3=Difícil
  final List<String> tags;
  final String? referencia;
  final String? textoBiblico;

  Question({
    required this.id,
    required this.pergunta,
    required this.opcoes,
    required this.respostaCorreta,
    required this.dificuldade,
    required this.tags,
    this.referencia,
    this.textoBiblico,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    // Mapear resposta_correta (string) para índice (int)
    final String respostaString = json['resposta_correta'] ?? '';
    final List<String> opcoes = List<String>.from(json['opcoes'] ?? []);
    int indiceResposta = 0;
    
    for (int i = 0; i < opcoes.length; i++) {
      if (opcoes[i] == respostaString) {
        indiceResposta = i;
        break;
      }
    }

    return Question(
      id: json['id']?.toString() ?? '0',
      pergunta: json['pergunta'] ?? '',
      opcoes: opcoes,
      respostaCorreta: indiceResposta,
      dificuldade: json['dificuldade'] ?? 2,
      tags: List<String>.from(json['tags'] ?? []),
      referencia: json['referencia'],
      textoBiblico: json['texto_biblico'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pergunta': pergunta,
      'opcoes': opcoes,
      'resposta_correta': opcoes[respostaCorreta],
      'dificuldade': dificuldade,
      'tags': tags,
      'referencia': referencia,
      'texto_biblico': textoBiblico,
    };
  }

  String getDificuldadeTexto() {
    switch (dificuldade) {
      case 1:
        return 'Fácil';
      case 2:
        return 'Médio';
      case 3:
        return 'Difícil';
      default:
        return 'Médio';
    }
  }
}
