import 'player.dart';

/// Estados possíveis de uma sala multiplayer
enum RoomStatus {
  waiting, // Aguardando jogadores no lobby
  starting, // Iniciando o jogo (3, 2, 1...)
  playing, // Jogo em andamento
  roundEnd, // Fim de uma rodada (mostrando resultados)
  finished, // Jogo finalizado
  closed, // Sala encerrada
}

/// Modelo que representa uma sala multiplayer
class Room {
  final String id; // Código único da sala (6 dígitos ou UUID)
  final String hostId; // ID do anfitrião
  final Map<String, Player> players; // Mapa de jogadores (id -> Player)
  RoomStatus status; // Estado atual da sala
  final DateTime createdAt; // Quando a sala foi criada
  DateTime lastActivity; // Última atividade na sala
  int currentQuestionIndex; // Índice da pergunta atual
  int totalQuestions; // Total de perguntas na partida
  List<String> questionIds; // IDs das perguntas selecionadas
  int roundTimeLimit; // Tempo limite por rodada (segundos)
  DateTime? roundStartTime; // Quando a rodada atual começou
  int maxPlayers; // Número máximo de jogadores

  Room({
    required this.id,
    required this.hostId,
    Map<String, Player>? players,
    this.status = RoomStatus.waiting,
    DateTime? createdAt,
    DateTime? lastActivity,
    this.currentQuestionIndex = 0,
    this.totalQuestions = 10,
    List<String>? questionIds,
    this.roundTimeLimit = 15,
    this.roundStartTime,
    this.maxPlayers = 100, // Capacidade ampliada para salas grandes
  })  : players = players ?? {},
        questionIds = questionIds ?? [],
        createdAt = createdAt ?? DateTime.now(),
        lastActivity = lastActivity ?? DateTime.now();

  /// Retorna o anfitrião da sala
  Player? get host => players[hostId];

  /// Retorna lista de jogadores ordenada por pontuação
  List<Player> get rankedPlayers {
    final playersList = players.values.toList();
    playersList.sort((a, b) => b.score.compareTo(a.score));
    return playersList;
  }

  /// Verifica se todos os jogadores responderam
  bool get allPlayersAnswered {
    return players.values.every((player) => player.hasAnswered);
  }

  /// Verifica se a sala está cheia
  bool get isFull {
    return players.length >= maxPlayers;
  }

  /// Verifica se a sala expirou (1 hora de inatividade)
  bool get isExpired {
    final now = DateTime.now();
    final difference = now.difference(lastActivity);
    return difference.inHours >= 1;
  }

  /// Verifica se deve mostrar aviso de expiração (55 minutos)
  bool get shouldShowExpirationWarning {
    final now = DateTime.now();
    final difference = now.difference(lastActivity);
    return difference.inMinutes >= 55 && difference.inMinutes < 60;
  }

  /// Tempo restante até expiração (em minutos)
  int get minutesUntilExpiration {
    final now = DateTime.now();
    final difference = now.difference(lastActivity);
    final remaining = 60 - difference.inMinutes;
    return remaining > 0 ? remaining : 0;
  }

  /// Converte a sala para Map (para Firebase/JSON)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hostId': hostId,
      'players': players.map((key, player) => MapEntry(key, player.toMap())),
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'lastActivity': lastActivity.toIso8601String(),
      'currentQuestionIndex': currentQuestionIndex,
      'totalQuestions': totalQuestions,
      'questionIds': questionIds,
      'roundTimeLimit': roundTimeLimit,
      'roundStartTime': roundStartTime?.toIso8601String(),
      'maxPlayers': maxPlayers,
    };
  }

  /// Cria uma sala a partir de um Map (do Firebase/JSON)
  factory Room.fromMap(Map<String, dynamic> map) {
    return Room(
      id: map['id'] as String,
      hostId: map['hostId'] as String,
      players: (map['players'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
              key,
              Player.fromMap(value as Map<String, dynamic>),
            ),
          ) ??
          {},
      status: RoomStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => RoomStatus.waiting,
      ),
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastActivity: DateTime.parse(map['lastActivity'] as String),
      currentQuestionIndex: map['currentQuestionIndex'] as int? ?? 0,
      totalQuestions: map['totalQuestions'] as int? ?? 10,
      questionIds: List<String>.from(map['questionIds'] as List? ?? []),
      roundTimeLimit: map['roundTimeLimit'] as int? ?? 15,
      roundStartTime: map['roundStartTime'] != null
          ? DateTime.parse(map['roundStartTime'] as String)
          : null,
      maxPlayers: map['maxPlayers'] as int? ?? 8,
    );
  }

  /// Cria uma cópia da sala com campos modificados
  Room copyWith({
    String? id,
    String? hostId,
    Map<String, Player>? players,
    RoomStatus? status,
    DateTime? createdAt,
    DateTime? lastActivity,
    int? currentQuestionIndex,
    int? totalQuestions,
    List<String>? questionIds,
    int? roundTimeLimit,
    DateTime? roundStartTime,
    int? maxPlayers,
  }) {
    return Room(
      id: id ?? this.id,
      hostId: hostId ?? this.hostId,
      players: players ?? this.players,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      lastActivity: lastActivity ?? this.lastActivity,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      questionIds: questionIds ?? this.questionIds,
      roundTimeLimit: roundTimeLimit ?? this.roundTimeLimit,
      roundStartTime: roundStartTime ?? this.roundStartTime,
      maxPlayers: maxPlayers ?? this.maxPlayers,
    );
  }

  /// Adiciona um jogador à sala
  Room addPlayer(Player player) {
    final newPlayers = Map<String, Player>.from(players);
    newPlayers[player.id] = player;
    return copyWith(
      players: newPlayers,
      lastActivity: DateTime.now(),
    );
  }

  /// Remove um jogador da sala
  Room removePlayer(String playerId) {
    final newPlayers = Map<String, Player>.from(players);
    newPlayers.remove(playerId);
    return copyWith(
      players: newPlayers,
      lastActivity: DateTime.now(),
    );
  }

  /// Atualiza um jogador específico
  Room updatePlayer(String playerId, Player updatedPlayer) {
    final newPlayers = Map<String, Player>.from(players);
    newPlayers[playerId] = updatedPlayer;
    return copyWith(
      players: newPlayers,
      lastActivity: DateTime.now(),
    );
  }

  /// Transfere anfitrião para outro jogador
  Room transferHost(String newHostId) {
    if (!players.containsKey(newHostId)) {
      throw Exception('Jogador não encontrado na sala');
    }

    final newPlayers = Map<String, Player>.from(players);
    
    // Remove host do anfitrião atual
    if (players.containsKey(hostId)) {
      newPlayers[hostId] = players[hostId]!.copyWith(isHost: false);
    }
    
    // Define novo host
    newPlayers[newHostId] = players[newHostId]!.copyWith(isHost: true);

    return copyWith(
      hostId: newHostId,
      players: newPlayers,
      lastActivity: DateTime.now(),
    );
  }

  /// Reseta a rodada para todos os jogadores
  Room resetRound() {
    final newPlayers = players.map(
      (key, player) => MapEntry(key, player.resetRound()),
    );
    return copyWith(
      players: newPlayers,
      roundStartTime: DateTime.now(),
      lastActivity: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'Room(id: $id, host: $hostId, players: ${players.length}, status: $status)';
  }
}
