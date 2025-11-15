import 'package:flutter/material.dart';
import 'dart:async';
import '../../services/audio_service.dart';

class SequenceGame extends StatefulWidget {
  const SequenceGame({super.key});

  @override
  State<SequenceGame> createState() => _SequenceGameState();
}

class _SequenceGameState extends State<SequenceGame> {
  final AudioService _audioService = AudioService();

  // Game state
  List<int> _sequence = [];
  List<int> _playerSequence = [];
  int _currentLevel = 1;
  int _highScore = 0;
  bool _isShowingSequence = false;
  bool _isPlayerTurn = false;
  bool _gameOver = false;
  int _currentShowIndex = 0;
  int _lastTappedColor = -1; // Para animação de toque
  bool _showSuccessAnimation = false; // Animação de acerto
  
  static const int maxLevel = 20; // Aumentado para 20 níveis

  // Colors
  final List<Color> _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
  ];

  final List<String> _colorNames = [
    'Vermelho',
    'Azul',
    'Verde',
    'Amarelo',
  ];

  @override
  void initState() {
    super.initState();
    _audioService.playBackgroundMusic('memory-game.mp3');
  }

  @override
  void dispose() {
    _audioService.stopBackgroundMusic();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _sequence = [];
      _playerSequence = [];
      _currentLevel = 1;
      _gameOver = false;
      _isPlayerTurn = false;
    });
    _nextLevel();
  }

  void _nextLevel() {
    setState(() {
      _sequence.add(_generateRandomColor());
      _playerSequence = [];
      _isShowingSequence = true;
      _currentShowIndex = 0;
    });
    _showSequence();
  }

  int _generateRandomColor() {
    return DateTime.now().millisecondsSinceEpoch % 4;
  }

  Future<void> _showSequence() async {
    await Future.delayed(const Duration(milliseconds: 800));

    for (int i = 0; i < _sequence.length; i++) {
      setState(() {
        _currentShowIndex = i;
      });
      _audioService.playClick();
      await Future.delayed(const Duration(milliseconds: 600));
      setState(() {
        _currentShowIndex = -1;
      });
      await Future.delayed(const Duration(milliseconds: 300));
    }

    setState(() {
      _isShowingSequence = false;
      _isPlayerTurn = true;
    });
  }

  void _onColorTap(int colorIndex) async {
    if (!_isPlayerTurn || _gameOver) return;

    // Animação de toque
    setState(() {
      _lastTappedColor = colorIndex;
    });
    _audioService.playClick();
    
    await Future.delayed(const Duration(milliseconds: 200));
    setState(() {
      _lastTappedColor = -1;
    });

    _playerSequence.add(colorIndex);

    // Check if player's move is correct
    int currentIndex = _playerSequence.length - 1;
    if (_playerSequence[currentIndex] != _sequence[currentIndex]) {
      _endGame(false);
      return;
    }

    // Check if player completed the sequence
    if (_playerSequence.length == _sequence.length) {
      // Verifica se ganhou o jogo (chegou no nível 20)
      if (_currentLevel >= maxLevel) {
        _endGame(true);
        return;
      }
      
      setState(() {
        _isPlayerTurn = false;
        _showSuccessAnimation = true;
        _currentLevel++;
        if (_currentLevel - 1 > _highScore) {
          _highScore = _currentLevel - 1;
        }
      });
      _audioService.playCorrectAnswer();
      
      // Animação de sucesso
      await Future.delayed(const Duration(milliseconds: 800));
      setState(() {
        _showSuccessAnimation = false;
      });
      
      await Future.delayed(const Duration(milliseconds: 500));
      _nextLevel();
    }
  }

  void _endGame(bool won) {
    setState(() {
      _gameOver = true;
      _isPlayerTurn = false;
      if (_currentLevel - 1 > _highScore) {
        _highScore = _currentLevel - 1;
      }
    });
    if (won) {
      _audioService.playVictory();
    } else {
      _audioService.playWrongAnswer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧠 Sequência Rápida'),
        backgroundColor: Colors.deepPurple,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'Recorde: $_highScore',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade300, Colors.deepPurple.shade700],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Level indicator
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    const Text(
                      'NÍVEL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$_currentLevel',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Status text / Success Animation
              if (_showSuccessAnimation)
                TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 600),
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  builder: (context, double value, child) {
                    return Transform.scale(
                      scale: 0.5 + (value * 0.5),
                      child: Opacity(
                        opacity: value,
                        child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.5),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.check_circle, color: Colors.white, size: 50),
                              SizedBox(height: 10),
                              Text(
                                '✨ Correto! ✨',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Nível $_currentLevel',
                                style: TextStyle(color: Colors.white70, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                )
              else if (_isShowingSequence)
                const Text(
                  'Observe a sequência...',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                )
              else if (_isPlayerTurn)
                const Text(
                  'Sua vez! Repita a sequência',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                )
              else if (_gameOver)
                Column(
                  children: [
                    Text(
                      _currentLevel >= maxLevel ? '🎉 PARABÉNS! VOCÊ VENCEU! 🎉' : '❌ Fim de Jogo!',
                      style: TextStyle(
                        color: _currentLevel >= maxLevel ? Colors.green : Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _currentLevel >= maxLevel 
                        ? 'Você completou todos os 20 níveis!'
                        : 'Você alcançou o nível $_currentLevel',
                      style: const TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                  ],
                ),

              const SizedBox(height: 40),

              // Color buttons
              if (!_gameOver && _sequence.isNotEmpty)
                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  alignment: WrapAlignment.center,
                  children: List.generate(4, (index) {
                    bool isHighlighted = (_isShowingSequence && 
                        _currentShowIndex >= 0 && 
                        _sequence[_currentShowIndex] == index) ||
                        (_lastTappedColor == index); // Também acende ao tocar
                    
                    return GestureDetector(
                      onTap: () => _onColorTap(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: isHighlighted 
                              ? _colors[index] 
                              : _colors[index].withOpacity(0.6),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: isHighlighted 
                                  ? _colors[index].withOpacity(0.8)
                                  : Colors.black.withOpacity(0.3),
                              blurRadius: isHighlighted ? 20 : 10,
                              spreadRadius: isHighlighted ? 5 : 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _colorNames[index],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  offset: Offset(1, 1),
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),

              const SizedBox(height: 40),

              // Start/Restart button
              if (_sequence.isEmpty || _gameOver)
                ElevatedButton.icon(
                  onPressed: _startGame,
                  icon: const Icon(Icons.play_arrow, size: 28),
                  label: Text(
                    _gameOver ? 'Jogar Novamente' : 'Iniciar Jogo',
                    style: const TextStyle(fontSize: 20),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
