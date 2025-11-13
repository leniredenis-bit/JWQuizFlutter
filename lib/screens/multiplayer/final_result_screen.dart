import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import '../../models/multiplayer/room.dart';
import '../../models/multiplayer/player.dart';
import '../../services/multiplayer/mock_multiplayer_service.dart';
import 'lobby_screen.dart';

/// Tela de resultados finais com pódio e animações
class FinalResultScreen extends StatefulWidget {
  final String roomCode;
  final String playerId;

  const FinalResultScreen({
    Key? key,
    required this.roomCode,
    required this.playerId,
  }) : super(key: key);

  @override
  State<FinalResultScreen> createState() => _FinalResultScreenState();
}

class _FinalResultScreenState extends State<FinalResultScreen>
    with TickerProviderStateMixin {
  StreamSubscription<Room>? _roomSubscription;
  Room? _currentRoom;
  
  late AnimationController _confettiController;
  late AnimationController _podiumController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  final List<Offset> _confettiPositions = [];
  bool _isRestarting = false;

  @override
  void initState() {
    super.initState();
    
    // Animação de confete
    _confettiController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..repeat();
    
    // Animação do pódio
    _podiumController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _podiumController, curve: Curves.easeIn),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _podiumController, curve: Curves.elasticOut),
    );
    
    _podiumController.forward();
    
    // Gerar posições de confete
    _generateConfetti();
    
    _listenToRoomUpdates();
    _loadRoom();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _podiumController.dispose();
    _roomSubscription?.cancel();
    super.dispose();
  }

  void _generateConfetti() {
    final random = math.Random();
    for (int i = 0; i < 50; i++) {
      _confettiPositions.add(
        Offset(
          random.nextDouble() * 400 - 200,
          random.nextDouble() * -600,
        ),
      );
    }
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

        // Se reiniciou, voltar para lobby
        if (room.status == RoomStatus.waiting && _isRestarting) {
          _navigateToLobby();
        }

        // Se sala fechou
        if (room.status == RoomStatus.closed) {
          _showRoomClosedDialog();
        }
      },
    );
  }

  Future<void> _navigateToLobby() async {
    if (!mounted) return;
    
    await Future.delayed(Duration(milliseconds: 300));
    
    if (!mounted) return;
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LobbyScreen(
          roomCode: widget.roomCode,
          playerId: widget.playerId,
        ),
      ),
    );
  }

  void _showRoomClosedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF162447),
        title: Row(
          children: [
            Icon(Icons.info, color: Colors.amber),
            SizedBox(width: 8),
            Text('Sala Encerrada', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(
          'O anfitrião encerrou a sala.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Text('OK', style: TextStyle(color: Color(0xFF3A5A8C))),
          ),
        ],
      ),
    );
  }

  Future<void> _restartGame() async {
    setState(() {
      _isRestarting = true;
    });

    try {
      await MockMultiplayerService.restartGame(widget.roomCode);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
      );
      setState(() {
        _isRestarting = false;
      });
    }
  }

  Future<void> _closeRoom() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF162447),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Encerrar Sala?', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(
          'Todos os jogadores serão desconectados.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Encerrar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await MockMultiplayerService.closeRoom(widget.roomCode);
        Navigator.of(context).popUntil((route) => route.isFirst);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
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
    final winner = players.first;
    final isWinner = winner.id == widget.playerId;

    return Scaffold(
      backgroundColor: Color(0xFF101A2C),
      body: Stack(
        children: [
          // Confete (apenas para o vencedor)
          if (isWinner)
            AnimatedBuilder(
              animation: _confettiController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: ConfettiPainter(
                    progress: _confettiController.value,
                    positions: _confettiPositions,
                  ),
                );
              },
            ),

          // Conteúdo
          SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(24),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Text(
                          '🏆 Fim de Jogo!',
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          isWinner ? 'Parabéns! Você venceu! 🎉' : 'Partida finalizada',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Pódio (Top 3)
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildPodium(players),
                  ),
                ),

                SizedBox(height: 24),

                // Lista completa
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: players.length > 3 ? players.length - 3 : 0,
                    itemBuilder: (context, index) {
                      final player = players[index + 3];
                      final rank = index + 4;
                      final isMe = player.id == widget.playerId;

                      return Container(
                        margin: EdgeInsets.only(bottom: 8),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isMe ? Color(0xFF23395D) : Color(0xFF162447),
                          borderRadius: BorderRadius.circular(12),
                          border: isMe ? Border.all(color: Color(0xFF3A5A8C), width: 2) : null,
                        ),
                        child: Row(
                          children: [
                            Text(
                              '$rank°',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 16),
                            Text(player.avatar, style: TextStyle(fontSize: 28)),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                player.nickname,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              '${player.score}',
                              style: TextStyle(
                                color: Colors.amber,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Botões
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
                      ? Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: _isRestarting ? null : _restartGame,
                                icon: _isRestarting
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : Icon(Icons.replay),
                                label: Text(
                                  _isRestarting ? 'Reiniciando...' : 'Jogar Novamente',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: BorderSide(color: Colors.red),
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: _closeRoom,
                                icon: Icon(Icons.close),
                                label: Text(
                                  'Encerrar Sala',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
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
                              if (_isRestarting) ...[
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                                  ),
                                ),
                                SizedBox(width: 12),
                              ],
                              Text(
                                _isRestarting
                                    ? 'Reiniciando partida...'
                                    : 'Aguardando decisão do anfitrião...',
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodium(List<Player> players) {
    return Container(
      height: 280,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 2º lugar
          if (players.length >= 2) _buildPodiumPlace(players[1], 2, 180, Colors.grey.shade400),
          SizedBox(width: 8),
          // 1º lugar
          _buildPodiumPlace(players[0], 1, 220, Colors.amber),
          SizedBox(width: 8),
          // 3º lugar
          if (players.length >= 3) _buildPodiumPlace(players[2], 3, 150, Colors.orange.shade700),
        ],
      ),
    );
  }

  Widget _buildPodiumPlace(Player player, int rank, double height, Color color) {
    final isMe = player.id == widget.playerId;
    String medal = rank == 1 ? '🥇' : rank == 2 ? '🥈' : '🥉';

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Avatar e nome
          Text(player.avatar, style: TextStyle(fontSize: 48)),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isMe ? Color(0xFF3A5A8C) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isMe ? Border.all(color: Colors.white, width: 2) : null,
            ),
            child: Text(
              player.nickname,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: 8),
          // Pontuação
          Text(
            '${player.score}',
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          // Pódio
          Container(
            height: height,
            decoration: BoxDecoration(
              color: color.withOpacity(0.3),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              border: Border.all(color: color, width: 3),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    medal,
                    style: TextStyle(fontSize: 48),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '$rank°',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Painter para animação de confete
class ConfettiPainter extends CustomPainter {
  final double progress;
  final List<Offset> positions;

  ConfettiPainter({required this.progress, required this.positions});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
    ];

    for (int i = 0; i < positions.length; i++) {
      final pos = positions[i];
      final y = pos.dy + (size.height * 1.2 * progress);
      final x = pos.dx + size.width / 2 + math.sin(progress * 6 + i) * 30;

      if (y < size.height) {
        paint.color = colors[i % colors.length];
        canvas.drawCircle(Offset(x, y), 6, paint);
      }
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) => true;
}
