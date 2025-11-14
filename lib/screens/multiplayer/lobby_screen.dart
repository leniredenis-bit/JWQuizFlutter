import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../models/multiplayer/room.dart';
import '../../services/multiplayer/mock_multiplayer_service.dart';
import 'multiplayer_quiz_screen.dart';

/// Tela do Lobby - Sala de espera antes de iniciar o jogo
class LobbyScreen extends StatefulWidget {
  final String roomCode;
  final String playerId;

  const LobbyScreen({
    Key? key,
    required this.roomCode,
    required this.playerId,
  }) : super(key: key);

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  StreamSubscription<Room>? _roomSubscription;
  Room? _currentRoom;
  bool _isStarting = false;

  @override
  void initState() {
    super.initState();
    MockMultiplayerService.initialize();
    _listenToRoomUpdates();
  }

  @override
  void dispose() {
    _roomSubscription?.cancel();
    super.dispose();
  }

  void _listenToRoomUpdates() {
    _roomSubscription = MockMultiplayerService.roomStream(widget.roomCode).listen(
      (room) {
        setState(() {
          _currentRoom = room;
        });

        // Se o jogo começou, navegar para tela de quiz
        if (room.status == RoomStatus.playing) {
          _navigateToQuiz();
        }

        // Se a sala foi fechada, voltar
        if (room.status == RoomStatus.closed) {
          _showRoomClosedDialog();
        }
      },
      onError: (error) {
        _showErrorDialog('Erro de conexão: $error');
      },
    );
  }

  Future<void> _navigateToQuiz() async {
    if (!mounted) return;
    
    // Pequeno delay para suavizar transição
    await Future.delayed(Duration(milliseconds: 500));
    
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

  Future<void> _startGame() async {
    if (_currentRoom == null) return;
    if (_currentRoom!.players.length < 2) {
      _showErrorDialog('É necessário pelo menos 2 jogadores para iniciar');
      return;
    }

    setState(() => _isStarting = true);

    try {
      await MockMultiplayerService.startGame(widget.roomCode);
      // A navegação acontecerá automaticamente via stream
    } catch (e) {
      setState(() => _isStarting = false);
      _showErrorDialog('Erro ao iniciar: $e');
    }
  }

  Future<void> _removePlayer(String playerId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF162447),
        title: Text('Remover jogador?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Tem certeza que deseja remover este jogador da sala?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Remover', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await MockMultiplayerService.removePlayer(
          roomCode: widget.roomCode,
          playerId: playerId,
        );
      } catch (e) {
        _showErrorDialog('Erro ao remover jogador: $e');
      }
    }
  }

  Future<void> _leaveRoom() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF162447),
        title: Text('Sair da sala?', style: TextStyle(color: Colors.white)),
        content: Text(
          _isHost
              ? 'Você é o anfitrião. Outro jogador será promovido automaticamente.'
              : 'Tem certeza que deseja sair?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Sair', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await MockMultiplayerService.removePlayer(
          roomCode: widget.roomCode,
          playerId: widget.playerId,
        );
        if (mounted) Navigator.pop(context);
      } catch (e) {
        _showErrorDialog('Erro ao sair: $e');
      }
    }
  }

  Future<void> _closeRoom() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF162447),
        title: Text('📢 Encerrar sala?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Isso irá expulsar todos os jogadores e fechar a sala permanentemente.',
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

    if (confirmed == true) {
      try {
        await MockMultiplayerService.closeRoom(widget.roomCode);
        if (mounted) Navigator.pop(context);
      } catch (e) {
        _showErrorDialog('Erro ao encerrar: $e');
      }
    }
  }

  void _copyRoomCode() {
    Clipboard.setData(ClipboardData(text: widget.roomCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Código copiado: ${widget.roomCode}'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareRoomCode() {
    // TODO: Implementar share nativo (usar package share_plus)
    _copyRoomCode();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Compartilhe o código ${widget.roomCode} com seus amigos!'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showRoomClosedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF162447),
        title: Text('Sala encerrada', style: TextStyle(color: Colors.white)),
        content: Text(
          'O anfitrião encerrou a sala.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF162447),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Erro', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(message, style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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

    final players = _currentRoom!.players.values.toList();
    final isStarting = _currentRoom!.status == RoomStatus.starting;

    return WillPopScope(
      onWillPop: () async {
        await _leaveRoom();
        return false;
      },
      child: Scaffold(
        backgroundColor: Color(0xFF101A2C),
        appBar: AppBar(
          title: Text('Sala ${widget.roomCode}', style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF162447),
          iconTheme: IconThemeData(color: Colors.white),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: _leaveRoom,
          ),
          actions: [
            if (_isHost)
              IconButton(
                icon: Icon(Icons.close),
                onPressed: _closeRoom,
                tooltip: 'Encerrar sala',
              ),
          ],
        ),
        body: Column(
          children: [
            // Código da sala e compartilhar
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
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
                    'Código da Sala',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: Color(0xFF23395D),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.roomCode,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 8,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.copy, color: Colors.white),
                        onPressed: _copyRoomCode,
                        tooltip: 'Copiar código',
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: Icon(Icons.share, size: 18),
                    label: Text('Compartilhar Código'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF3A5A8C),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: _shareRoomCode,
                  ),
                ],
              ),
            ),

            // Lista de jogadores
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: players.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text(
                        '👥 Jogadores (${players.length}/${_currentRoom!.maxPlayers})',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }

                  final player = players[index - 1];
                  final isMe = player.id == widget.playerId;

                  return Container(
                    margin: EdgeInsets.only(bottom: 8),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? Color(0xFF23395D) : Color(0xFF162447),
                      borderRadius: BorderRadius.circular(12),
                      border: isMe ? Border.all(color: Color(0xFF3A5A8C), width: 2) : null,
                    ),
                    child: Row(
                      children: [
                        Text(player.avatar, style: TextStyle(fontSize: 32)),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    player.nickname,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (player.isHost) ...[
                                    SizedBox(width: 8),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.amber,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'ANFITRIÃO',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                  if (isMe) ...[
                                    SizedBox(width: 8),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Color(0xFF3A5A8C),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'VOCÊ',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Pronto para jogar ✓',
                                style: TextStyle(color: Colors.green.shade300, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        if (_isHost && !player.isHost)
                          IconButton(
                            icon: Icon(Icons.person_remove, color: Colors.red.shade300),
                            onPressed: () => _removePlayer(player.id),
                            tooltip: 'Remover jogador',
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Botão Iniciar ou Aguardando
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
              child: Column(
                children: [
                  if (!_isHost)
                    Container(
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
                            'Aguardando o anfitrião iniciar...',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  if (_isHost)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isStarting ? Colors.grey : Colors.green.shade700,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        onPressed: (isStarting || _isStarting) ? null : _startGame,
                        child: isStarting
                            ? Text(
                                'Iniciando em 3... 2... 1...',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.play_arrow, size: 28),
                                  SizedBox(width: 8),
                                  Text(
                                    'Iniciar Partida',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
      ),
    );
  }
}
