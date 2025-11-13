import 'room.dart';
import '../../models/question.dart';

/// Estado do jogo multiplayer
class GameState {
  final Room? currentRoom; // Sala atual do jogador
  final String? currentPlayerId; // ID do jogador atual
  final List<Question> questions; // Perguntas da partida atual
  final Question? currentQuestion; // Pergunta sendo exibida
  final bool isLoading; // Se está carregando dados
  final String? error; // Mensagem de erro, se houver
  final int timeRemaining; // Tempo restante da rodada (segundos)

  GameState({
    this.currentRoom,
    this.currentPlayerId,
    this.questions = const [],
    this.currentQuestion,
    this.isLoading = false,
    this.error,
    this.timeRemaining = 15,
  });

  /// Retorna o jogador atual
  Player? get currentPlayer {
    if (currentRoom == null || currentPlayerId == null) return null;
    return currentRoom!.players[currentPlayerId];
  }

  /// Verifica se o jogador atual é o anfitrião
  bool get isHost {
    return currentPlayer?.isHost ?? false;
  }

  /// Verifica se todos os jogadores responderam
  bool get allPlayersAnswered {
    return currentRoom?.allPlayersAnswered ?? false;
  }

  /// Cria uma cópia do estado com campos modificados
  GameState copyWith({
    Room? currentRoom,
    String? currentPlayerId,
    List<Question>? questions,
    Question? currentQuestion,
    bool? isLoading,
    String? error,
    int? timeRemaining,
  }) {
    return GameState(
      currentRoom: currentRoom ?? this.currentRoom,
      currentPlayerId: currentPlayerId ?? this.currentPlayerId,
      questions: questions ?? this.questions,
      currentQuestion: currentQuestion ?? this.currentQuestion,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      timeRemaining: timeRemaining ?? this.timeRemaining,
    );
  }

  /// Limpa o estado (sai da sala)
  GameState clear() {
    return GameState(
      currentRoom: null,
      currentPlayerId: null,
      questions: [],
      currentQuestion: null,
      isLoading: false,
      error: null,
      timeRemaining: 15,
    );
  }

  @override
  String toString() {
    return 'GameState(room: ${currentRoom?.id}, player: $currentPlayerId, loading: $isLoading)';
  }
}
