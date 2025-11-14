import 'dart:async';
import 'dart:math';
import '../../models/multiplayer/room.dart';
import '../../models/multiplayer/player.dart';
import '../../models/quiz_service.dart';

/// Serviço MOCK para simular backend multiplayer
/// Permite testar o fluxo completo sem Firebase
class MockMultiplayerService {
  // Simulação de "banco de dados" local
  static final Map<String, Room> _rooms = {};
  
  // Controllers para streams (simular tempo real)
  static final Map<String, StreamController<Room>> _roomControllers = {};
  
  // Timer para verificar expiração de salas
  static Timer? _expirationTimer;

  /// Inicia o serviço de monitoramento
  static void initialize() {
    // Verifica salas expiradas a cada minuto
    _expirationTimer?.cancel();
    _expirationTimer = Timer.periodic(Duration(minutes: 1), (_) {
      _checkExpiredRooms();
    });
  }

  /// Para o serviço
  static void dispose() {
    _expirationTimer?.cancel();
    for (final controller in _roomControllers.values) {
      controller.close();
    }
    _roomControllers.clear();
    _rooms.clear();
  }

  /// Gera um código único de 6 dígitos
  static String _generateRoomCode() {
    final random = Random();
    String code;
    do {
      code = (random.nextInt(900000) + 100000).toString(); // 100000-999999
    } while (_rooms.containsKey(code));
    return code;
  }

  /// Cria uma nova sala
  static Future<Room> createRoom({
    required String hostId,
    required String hostNickname,
    int totalQuestions = 10,
    int roundTimeLimit = 15,
    int maxPlayers = 100, // Capacidade padrão ampliada
  }) async {
    await Future.delayed(Duration(milliseconds: 300)); // Simula latência

    final roomCode = _generateRoomCode();
    
    // Criar jogador host
    final host = Player(
      id: hostId,
      nickname: hostNickname,
      isHost: true,
      avatar: '👑',
    );

    // Selecionar perguntas aleatórias
    final allQuestions = await QuizService.loadQuestions();
    final selectedQuestions = QuizService.getRandomQuestions(allQuestions, totalQuestions);
    final questionIds = selectedQuestions.map((q) => q.id.toString()).toList();

    final room = Room(
      id: roomCode,
      hostId: hostId,
      players: {hostId: host},
      totalQuestions: totalQuestions,
      questionIds: questionIds,
      roundTimeLimit: roundTimeLimit,
      maxPlayers: maxPlayers,
    );

    _rooms[roomCode] = room;
    _roomControllers[roomCode] = StreamController<Room>.broadcast();
    _roomControllers[roomCode]!.add(room);

    return room;
  }

  /// Entra em uma sala existente
  static Future<Room> joinRoom({
    required String roomCode,
    required String playerId,
    required String nickname,
  }) async {
    await Future.delayed(Duration(milliseconds: 300)); // Simula latência

    final room = _rooms[roomCode];
    if (room == null) {
      throw Exception('Sala não encontrada. Verifique o código.');
    }

    if (room.status != RoomStatus.waiting) {
      throw Exception('Esta sala já está em andamento.');
    }

    if (room.isFull) {
      throw Exception('Esta sala está cheia.');
    }

    if (room.players.containsKey(playerId)) {
      throw Exception('Você já está nesta sala.');
    }

    // Selecionar avatar aleatório
    final avatars = ['😊', '🙂', '😄', '🤗', '😇', '🤓', '😎', '🥳'];
    final random = Random();
    final avatar = avatars[random.nextInt(avatars.length)];

    final player = Player(
      id: playerId,
      nickname: nickname,
      avatar: avatar,
    );

    final updatedRoom = room.addPlayer(player);
    _rooms[roomCode] = updatedRoom;
    _roomControllers[roomCode]?.add(updatedRoom);

    return updatedRoom;
  }

  /// Remove um jogador da sala
  static Future<Room?> removePlayer({
    required String roomCode,
    required String playerId,
  }) async {
    await Future.delayed(Duration(milliseconds: 200));

    final room = _rooms[roomCode];
    if (room == null) return null;

    final updatedRoom = room.removePlayer(playerId);
    
    // Se o host saiu e ainda há jogadores, transferir host
    if (playerId == room.hostId && updatedRoom.players.isNotEmpty) {
      final newHostId = updatedRoom.players.keys.first;
      final finalRoom = updatedRoom.transferHost(newHostId);
      _rooms[roomCode] = finalRoom;
      _roomControllers[roomCode]?.add(finalRoom);
      return finalRoom;
    }

    // Se não há mais jogadores, encerra a sala
    if (updatedRoom.players.isEmpty) {
      return closeRoom(roomCode);
    }

    _rooms[roomCode] = updatedRoom;
    _roomControllers[roomCode]?.add(updatedRoom);
    return updatedRoom;
  }

  /// Inicia o jogo
  static Future<Room> startGame(String roomCode) async {
    await Future.delayed(Duration(milliseconds: 500));

    final room = _rooms[roomCode];
    if (room == null) throw Exception('Sala não encontrada');

    if (room.players.length < 2) {
      throw Exception('É necessário pelo menos 2 jogadores para iniciar');
    }

    final updatedRoom = room.copyWith(
      status: RoomStatus.starting,
      lastActivity: DateTime.now(),
    );

    _rooms[roomCode] = updatedRoom;
    _roomControllers[roomCode]?.add(updatedRoom);

    // Após 3 segundos, muda para "playing"
    Future.delayed(Duration(seconds: 3), () {
      final playingRoom = updatedRoom.copyWith(
        status: RoomStatus.playing,
        roundStartTime: DateTime.now(),
      ).resetRound();
      _rooms[roomCode] = playingRoom;
      _roomControllers[roomCode]?.add(playingRoom);
    });

    return updatedRoom;
  }

  /// Registra a resposta de um jogador
  static Future<Room> submitAnswer({
    required String roomCode,
    required String playerId,
    required int answerIndex,
    required bool isCorrect,
    required int points,
  }) async {
    await Future.delayed(Duration(milliseconds: 150));

    final room = _rooms[roomCode];
    if (room == null) throw Exception('Sala não encontrada');

    final player = room.players[playerId];
    if (player == null) throw Exception('Jogador não encontrado');

    final updatedPlayer = player.copyWith(
      hasAnswered: true,
      lastAnswer: answerIndex,
      lastAnswerCorrect: isCorrect,
      score: player.score + (isCorrect ? points : 0),
    );

    final updatedRoom = room.updatePlayer(playerId, updatedPlayer);
    _rooms[roomCode] = updatedRoom;
    _roomControllers[roomCode]?.add(updatedRoom);

    return updatedRoom;
  }

  /// Avança para a próxima pergunta
  static Future<Room> nextQuestion(String roomCode) async {
    await Future.delayed(Duration(milliseconds: 300));

    final room = _rooms[roomCode];
    if (room == null) throw Exception('Sala não encontrada');

    final nextIndex = room.currentQuestionIndex + 1;

    if (nextIndex >= room.totalQuestions) {
      // Fim do jogo
      final finishedRoom = room.copyWith(
        status: RoomStatus.finished,
        lastActivity: DateTime.now(),
      );
      _rooms[roomCode] = finishedRoom;
      _roomControllers[roomCode]?.add(finishedRoom);
      return finishedRoom;
    }

    // Próxima rodada
    final updatedRoom = room.copyWith(
      currentQuestionIndex: nextIndex,
      status: RoomStatus.playing,
      roundStartTime: DateTime.now(),
    ).resetRound();

    _rooms[roomCode] = updatedRoom;
    _roomControllers[roomCode]?.add(updatedRoom);

    return updatedRoom;
  }

  /// Reinicia o jogo (mesmos jogadores, novas perguntas)
  static Future<Room> restartGame(String roomCode) async {
    await Future.delayed(Duration(milliseconds: 500));

    final room = _rooms[roomCode];
    if (room == null) throw Exception('Sala não encontrada');

    // Selecionar novas perguntas
    final allQuestions = await QuizService.loadQuestions();
    final selectedQuestions = QuizService.getRandomQuestions(allQuestions, room.totalQuestions);
    final questionIds = selectedQuestions.map((q) => q.id.toString()).toList();

    // Resetar pontuação de todos os jogadores
    final resetPlayers = room.players.map(
      (key, player) => MapEntry(key, player.copyWith(score: 0).resetRound()),
    );

    final restartedRoom = room.copyWith(
      status: RoomStatus.waiting,
      currentQuestionIndex: 0,
      questionIds: questionIds,
      players: resetPlayers,
      lastActivity: DateTime.now(),
    );

    _rooms[roomCode] = restartedRoom;
    _roomControllers[roomCode]?.add(restartedRoom);

    return restartedRoom;
  }

  /// Encerra a sala
  static Future<Room?> closeRoom(String roomCode) async {
    await Future.delayed(Duration(milliseconds: 200));

    final room = _rooms[roomCode];
    if (room == null) return null;

    final closedRoom = room.copyWith(status: RoomStatus.closed);
    _roomControllers[roomCode]?.add(closedRoom);
    _roomControllers[roomCode]?.close();
    
    _rooms.remove(roomCode);
    _roomControllers.remove(roomCode);

    return closedRoom;
  }

  /// Stream da sala (tempo real)
  static Stream<Room> roomStream(String roomCode) {
    if (!_roomControllers.containsKey(roomCode)) {
      _roomControllers[roomCode] = StreamController<Room>.broadcast();
    }
    return _roomControllers[roomCode]!.stream;
  }

  /// Obtém dados da sala (sem stream)
  static Room? getRoom(String roomCode) {
    return _rooms[roomCode];
  }

  /// Verifica salas expiradas
  static void _checkExpiredRooms() {
    final expiredRooms = <String>[];
    
    for (final entry in _rooms.entries) {
      if (entry.value.isExpired) {
        expiredRooms.add(entry.key);
      }
    }

    for (final roomCode in expiredRooms) {
      closeRoom(roomCode);
    }
  }

  /// Atualiza atividade da sala (previne expiração)
  static Future<void> updateActivity(String roomCode) async {
    final room = _rooms[roomCode];
    if (room != null) {
      _rooms[roomCode] = room.copyWith(lastActivity: DateTime.now());
    }
  }
}
