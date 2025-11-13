import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/multiplayer/room.dart';
import '../../models/question.dart';
import '../../services/multiplayer/mock_multiplayer_service.dart';
import '../../models/quiz_service.dart';
import '../../utils/timer_calculator.dart';
import 'round_result_screen.dart';

/// Tela de gameplay multiplayer - perguntas com timer
class MultiplayerQuizScreen extends StatefulWidget {
  final String roomCode;
  final String playerId;

  const MultiplayerQuizScreen({
    Key? key,
    required this.roomCode,
    required this.playerId,
  }) : super(key: key);

  @override
  State<MultiplayerQuizScreen> createState() => _MultiplayerQuizScreenState();
}

class _MultiplayerQuizScreenState extends State<MultiplayerQuizScreen> {
  StreamSubscription<Room>? _roomSubscription;
  Room? _currentRoom;
  List<Question> _allQuestions = [];
  Question? _currentQuestion;
  
  int _timeRemaining = 15;
  Timer? _timer;
  
  int? _selectedAnswer;
  bool _hasSubmitted = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _listenToRoomUpdates();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _roomSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    try {
      final questions = await QuizService.loadQuestions();
      setState(() {
        _allQuestions = questions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Erro ao carregar perguntas: $e');
    }
  }

  void _listenToRoomUpdates() {
    _roomSubscription = MockMultiplayerService.roomStream(widget.roomCode).listen(
      (room) {
        setState(() {
          _currentRoom = room;
        });

        // Atualizar pergunta atual
        if (room.status == RoomStatus.playing) {
          _updateCurrentQuestion();
          
          // Se foi resetado (nova rodada), resetar estado local
          final currentPlayer = room.players[widget.playerId];
          if (currentPlayer != null && !currentPlayer.hasAnswered && _hasSubmitted) {
            _resetRound();
          }
        }

        // Se todos responderam ou anfitrião passou, mostrar resultados
        if (room.status == RoomStatus.roundEnd) {
          _navigateToRoundResults();
        }

        // Se jogo terminou, navegar para resultados finais
        if (room.status == RoomStatus.finished) {
          // TODO: Navegar para FinalResultScreen
        }

        // Se sala foi fechada
        if (room.status == RoomStatus.closed) {
          _showRoomClosedDialog();
        }
      },
      onError: (error) {
        _showError('Erro de conexão: $error');
      },
    );
  }

  void _updateCurrentQuestion() {
    if (_currentRoom == null || _allQuestions.isEmpty) return;

    final questionIndex = _currentRoom!.currentQuestionIndex;
    if (questionIndex < _currentRoom!.questionIds.length) {
      final questionId = _currentRoom!.questionIds[questionIndex];
      final question = _allQuestions.firstWhere(
        (q) => q.id.toString() == questionId,
        orElse: () => _allQuestions[0],
      );

      if (_currentQuestion?.id != question.id) {
        setState(() {
          _currentQuestion = question;
        });
        _startTimer();
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    
    // Calcular tempo dinamicamente baseado na pergunta (com +20s para multiplayer)
    final calculatedTime = _currentQuestion != null 
        ? TimerCalculator.calculateMultiplayerTime(_currentQuestion!)
        : 20; // Fallback padrão
    
    setState(() {
      _timeRemaining = calculatedTime;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        setState(() {
          _timeRemaining--;
        });
      } else {
        _timer?.cancel();
        if (!_hasSubmitted) {
          _submitAnswer(null); // Tempo esgotado, resposta nula
        }
      }
    });
  }

  void _resetRound() {
    setState(() {
      _selectedAnswer = null;
      _hasSubmitted = false;
    });
    _startTimer();
  }

  Future<void> _submitAnswer(int? answerIndex) async {
    if (_hasSubmitted) return;
    if (_currentQuestion == null) return;

    setState(() {
      _selectedAnswer = answerIndex;
      _hasSubmitted = true;
    });

    _timer?.cancel();

    final isCorrect = answerIndex == _currentQuestion!.respostaCorreta;
    
    // Calcular pontos (baseado em tempo e dificuldade)
    int points = 0;
    if (isCorrect) {
      int basePoints = 10;
      if (_currentQuestion!.dificuldade == 3) {
        basePoints = 20; // Difícil
      } else if (_currentQuestion!.dificuldade == 2) {
        basePoints = 15; // Médio
      }
      int timeBonus = (_timeRemaining * 0.5).round();
      points = basePoints + timeBonus;
    }

    try {
      await MockMultiplayerService.submitAnswer(
        roomCode: widget.roomCode,
        playerId: widget.playerId,
        answerIndex: answerIndex ?? -1,
        isCorrect: isCorrect,
        points: points,
      );
    } catch (e) {
      _showError('Erro ao enviar resposta: $e');
    }
  }

  Future<void> _navigateToRoundResults() async {
    if (!mounted) return;
    
    // Delay para permitir visualizar feedback da resposta
    await Future.delayed(Duration(milliseconds: 500));
    
    if (!mounted) return;
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => RoundResultScreen(
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
        title: Text('Sala encerrada', style: TextStyle(color: Colors.white)),
        content: Text(
          'O anfitrião encerrou a partida.',
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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  bool get _isHost {
    return _currentRoom?.hostId == widget.playerId;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _currentRoom == null || _currentQuestion == null) {
      return Scaffold(
        backgroundColor: Color(0xFF101A2C),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF3A5A8C)),
              SizedBox(height: 16),
              Text(
                'Carregando pergunta...',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    }

    final allAnswered = _currentRoom!.allPlayersAnswered;
    final playersCount = _currentRoom!.players.length;
    final answeredCount = _currentRoom!.players.values.where((p) => p.hasAnswered).length;

    return WillPopScope(
      onWillPop: () async => false, // Impede voltar durante o quiz
      child: Scaffold(
        backgroundColor: Color(0xFF101A2C),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Pergunta ${_currentRoom!.currentQuestionIndex + 1}/${_currentRoom!.totalQuestions}'),
          backgroundColor: Color(0xFF162447),
          elevation: 0,
          actions: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  '👥 $answeredCount/$playersCount',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Timer e Dificuldade
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _timeRemaining <= 5 ? Colors.red.shade900 : Color(0xFF23395D),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.timer,
                          color: _timeRemaining <= 5 ? Colors.red : Colors.white,
                        ),
                        SizedBox(width: 8),
                        Text(
                          '${_timeRemaining}s',
                          style: TextStyle(
                            color: _timeRemaining <= 5 ? Colors.red : Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Chip(
                    label: Text(_currentQuestion!.getDificuldadeTexto()),
                    backgroundColor: Color(0xFF23395D),
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              SizedBox(height: 24),

              // Pergunta
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFF162447),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pergunta #${_currentQuestion!.id}',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _currentQuestion!.pergunta,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Alternativas
              Expanded(
                child: ListView.builder(
                  itemCount: _currentQuestion!.opcoes.length,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedAnswer == index;
                    final isCorrect = index == _currentQuestion!.respostaCorreta;
                    
                    Color buttonColor = Color(0xFF23395D);
                    if (_hasSubmitted) {
                      if (isCorrect) {
                        buttonColor = Colors.green.shade700;
                      } else if (isSelected && !isCorrect) {
                        buttonColor = Colors.red.shade700;
                      }
                    } else if (isSelected) {
                      buttonColor = Color(0xFF3A5A8C);
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: EdgeInsets.all(16),
                          elevation: isSelected ? 4 : 2,
                        ),
                        onPressed: _hasSubmitted ? null : () => _submitAnswer(index),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.2),
                              ),
                              child: Center(
                                child: Text(
                                  String.fromCharCode(65 + index), // A, B, C, D
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _currentQuestion!.opcoes[index],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (_hasSubmitted && isCorrect)
                              Icon(Icons.check_circle, color: Colors.white),
                            if (_hasSubmitted && isSelected && !isCorrect)
                              Icon(Icons.cancel, color: Colors.white),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Status bar
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF162447),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_hasSubmitted) ...[
                      Icon(Icons.touch_app, color: Colors.white70, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Selecione uma alternativa',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ] else if (!allAnswered) ...[
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Aguardando outros jogadores...',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ] else ...[
                      Icon(Icons.check_circle, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Todos responderam!',
                        style: TextStyle(color: Colors.green),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
