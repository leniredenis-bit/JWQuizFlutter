import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/multiplayer/room.dart';
import '../../services/multiplayer/mock_multiplayer_service.dart';
import 'multiplayer_quiz_screen.dart';
import 'final_result_screen.dart';

/// Tela de resultados parciais após cada rodada
class RoundResultScreen extends StatefulWidget {
  final String roomCode;
  final String playerId;

  const RoundResultScreen({
    Key? key,
    required this.roomCode,
    required this.playerId,
  }) : super(key: key);

  @override
  State<RoundResultScreen> createState() => _RoundResultScreenState();
}

class _RoundResultScreenState extends State<RoundResultScreen> with SingleTickerProviderStateMixin {
  StreamSubscription<Room>? _roomSubscription;
  Room? _currentRoom;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    
    _animationController.forward();
    _listenToRoomUpdates();
    _loadRoom();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _roomSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadRoom() async {
    final room = MockMultiplayerService.getRoom(widget.roomCode);
    if (room != null) {
      setState(() {
        _currentRoom = room;
      });
    }
  }

  void _listenToRoomUpdates() {
    _roomSubscription = MockMultiplayerService.roomStream(widget.roomCode).listen(
      (room) {
        setState(() {
          _currentRoom = room;
        });

        // Se próxima pergunta começou, navegar para quiz
        if (room.status == RoomStatus.playing) {
          _navigateToNextQuestion();
        }

        // Se jogo terminou, navegar para resultados finais
        if (room.status == RoomStatus.finished) {
          _navigateToFinalResults();
        }
      },
    );
  }

  Future<void> _navigateToNextQuestion() async {
    if (!mounted) return;
    
    await Future.delayed(Duration(milliseconds: 300));
    
    if (!mounted) return;
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MultiplayerQuizScreen(
          roomCode: widget.roomCode,
          playerId: widget.playerId,
        ),
      ),
    );
  }

  Future<void> _navigateToFinalResults() async {
    if (!mounted) return;
    
    await Future.delayed(Duration(milliseconds: 300));
    
    if (!mounted) return;
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => FinalResultScreen(
          roomCode: widget.roomCode,
          playerId: widget.playerId,
        ),
      ),
    );
  }

  Future<void> _nextQuestion() async {
    try {
      await MockMultiplayerService.nextQuestion(widget.roomCode);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
      );
    }
  }

  bool get _isHost {
    return _currentRoom?.hostId == widget.playerId;
  }

  @override
  Widget build(BuildContext context) {
    if (_currentRoom == null) {
      return Scaffold(
        backgroundColor: Color(0xFF101A2C),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF3A5A8C)),
        ),
      );
    }

    final players = _currentRoom!.rankedPlayers;
    final currentPlayer = players.firstWhere((p) => p.id == widget.playerId);
    final currentPlayerRank = players.indexOf(currentPlayer) + 1;

    return Scaffold(
      backgroundColor: Color(0xFF101A2C),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Resultados da Rodada'),
        backgroundColor: Color(0xFF162447),
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Status do jogador
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Color(0xFF162447),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    currentPlayer.lastAnswerCorrect ? '✅ Acertou!' : '❌ Errou',
                    style: TextStyle(
                      color: currentPlayer.lastAnswerCorrect ? Colors.green : Colors.red,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatBox(
                        icon: '🏆',
                        label: 'Posição',
                        value: '$currentPlayerRank°',
                      ),
                      _buildStatBox(
                        icon: '⭐',
                        label: 'Pontos',
                        value: '${currentPlayer.score}',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Ranking
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: players.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Text(
                        '📊 Ranking Atual',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }

                  final player = players[index - 1];
                  final rank = index;
                  final isMe = player.id == widget.playerId;

                  // Medalhas
                  String? medal;
                  Color? medalColor;
                  if (rank == 1) {
                    medal = '🥇';
                    medalColor = Colors.amber;
                  } else if (rank == 2) {
                    medal = '🥈';
                    medalColor = Colors.grey.shade400;
                  } else if (rank == 3) {
                    medal = '🥉';
                    medalColor = Colors.orange.shade700;
                  }

                  return Container(
                    margin: EdgeInsets.only(bottom: 8),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isMe ? Color(0xFF23395D) : Color(0xFF162447),
                      borderRadius: BorderRadius.circular(12),
                      border: isMe ? Border.all(color: Color(0xFF3A5A8C), width: 2) : null,
                      boxShadow: rank <= 3
                          ? [
                              BoxShadow(
                                color: (medalColor ?? Colors.transparent).withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        // Ranking
                        Container(
                          width: 40,
                          child: Text(
                            medal ?? '$rank°',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: medal != null ? 28 : 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(width: 12),
                        // Avatar
                        Text(player.avatar, style: TextStyle(fontSize: 32)),
                        SizedBox(width: 12),
                        // Nome
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                player.nickname,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    player.lastAnswerCorrect ? Icons.check_circle : Icons.cancel,
                                    color: player.lastAnswerCorrect ? Colors.green : Colors.red,
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    player.lastAnswerCorrect ? 'Acertou' : 'Errou',
                                    style: TextStyle(
                                      color: player.lastAnswerCorrect ? Colors.green : Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Pontuação
                        Column(
                          children: [
                            Text(
                              '${player.score}',
                              style: TextStyle(
                                color: Colors.amber,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'pontos',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Botão Próxima (apenas host)
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF162447),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: _isHost
                  ? SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF3A5A8C),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        onPressed: _nextQuestion,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.arrow_forward, size: 24),
                            SizedBox(width: 8),
                            Text(
                              'Próxima Pergunta',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFF23395D),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Aguardando o anfitrião...',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox({
    required String icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF23395D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(icon, style: TextStyle(fontSize: 32)),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
