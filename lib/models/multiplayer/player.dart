/// Modelo que representa um jogador na partida multiplayer
class Player {
  final String id; // ID único do jogador
  final String nickname; // Apelido escolhido
  final String avatar; // Emoji avatar (opcional)
  int score; // Pontuação atual
  bool isHost; // Se é o anfitrião da sala
  bool isReady; // Se está pronto para iniciar
  bool hasAnswered; // Se já respondeu a pergunta atual
  int? lastAnswer; // Índice da última resposta (0-3)
  bool lastAnswerCorrect; // Se a última resposta estava correta
  DateTime joinedAt; // Quando entrou na sala
  DateTime? lastActivity; // Última atividade

  Player({
    required this.id,
    required this.nickname,
    this.avatar = '😊',
    this.score = 0,
    this.isHost = false,
    this.isReady = false,
    this.hasAnswered = false,
    this.lastAnswer,
    this.lastAnswerCorrect = false,
    DateTime? joinedAt,
    this.lastActivity,
  }) : joinedAt = joinedAt ?? DateTime.now();

  /// Converte o jogador para Map (para Firebase/JSON)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nickname': nickname,
      'avatar': avatar,
      'score': score,
      'isHost': isHost,
      'isReady': isReady,
      'hasAnswered': hasAnswered,
      'lastAnswer': lastAnswer,
      'lastAnswerCorrect': lastAnswerCorrect,
      'joinedAt': joinedAt.toIso8601String(),
      'lastActivity': lastActivity?.toIso8601String(),
    };
  }

  /// Cria um jogador a partir de um Map (do Firebase/JSON)
  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id'] as String,
      nickname: map['nickname'] as String,
      avatar: map['avatar'] as String? ?? '😊',
      score: map['score'] as int? ?? 0,
      isHost: map['isHost'] as bool? ?? false,
      isReady: map['isReady'] as bool? ?? false,
      hasAnswered: map['hasAnswered'] as bool? ?? false,
      lastAnswer: map['lastAnswer'] as int?,
      lastAnswerCorrect: map['lastAnswerCorrect'] as bool? ?? false,
      joinedAt: DateTime.parse(map['joinedAt'] as String),
      lastActivity: map['lastActivity'] != null
          ? DateTime.parse(map['lastActivity'] as String)
          : null,
    );
  }

  /// Cria uma cópia do jogador com campos modificados
  Player copyWith({
    String? id,
    String? nickname,
    String? avatar,
    int? score,
    bool? isHost,
    bool? isReady,
    bool? hasAnswered,
    int? lastAnswer,
    bool? lastAnswerCorrect,
    DateTime? joinedAt,
    DateTime? lastActivity,
  }) {
    return Player(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      score: score ?? this.score,
      isHost: isHost ?? this.isHost,
      isReady: isReady ?? this.isReady,
      hasAnswered: hasAnswered ?? this.hasAnswered,
      lastAnswer: lastAnswer ?? this.lastAnswer,
      lastAnswerCorrect: lastAnswerCorrect ?? this.lastAnswerCorrect,
      joinedAt: joinedAt ?? this.joinedAt,
      lastActivity: lastActivity ?? this.lastActivity,
    );
  }

  /// Reseta o estado da rodada (para próxima pergunta)
  Player resetRound() {
    return copyWith(
      hasAnswered: false,
      lastAnswer: null,
      lastAnswerCorrect: false,
      lastActivity: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'Player(id: $id, nickname: $nickname, score: $score, isHost: $isHost)';
  }
}
