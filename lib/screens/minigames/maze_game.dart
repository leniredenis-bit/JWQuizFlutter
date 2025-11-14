import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/audio_service.dart';

class MazeGame extends StatefulWidget {
  const MazeGame({super.key});

  @override
  State<MazeGame> createState() => _MazeGameState();
}

class _MazeGameState extends State<MazeGame> {
  final AudioService _audioService = AudioService();
  
  // Player position
  int _playerRow = 0;
  int _playerCol = 0;
  
  // Game state
  bool _isGameWon = false;
  int _moves = 0;
  
  // Maze layout (0 = path, 1 = wall, 2 = start, 3 = end)
  final List<List<int>> _maze = [
    [2, 0, 1, 0, 0, 0, 1, 0, 0, 0],
    [0, 0, 1, 0, 1, 0, 1, 0, 1, 0],
    [1, 0, 0, 0, 1, 0, 0, 0, 1, 0],
    [1, 1, 1, 0, 1, 1, 1, 0, 1, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 1, 0],
    [0, 1, 1, 1, 1, 1, 1, 1, 1, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [1, 1, 1, 0, 1, 1, 1, 1, 1, 0],
    [0, 0, 1, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 1, 1, 1, 0, 1, 3],
  ];

  @override
  void initState() {
    super.initState();
    _audioService.playBackgroundMusic('quiz-home.mp3');
  }

  @override
  void dispose() {
    _audioService.stopBackgroundMusic();
    super.dispose();
  }

  void _movePlayer(int deltaRow, int deltaCol) {
    if (_isGameWon) return;

    int newRow = _playerRow + deltaRow;
    int newCol = _playerCol + deltaCol;

    // Check boundaries
    if (newRow < 0 || newRow >= _maze.length || newCol < 0 || newCol >= _maze[0].length) {
      return;
    }

    // Check if it's a wall
    if (_maze[newRow][newCol] == 1) {
      _audioService.playWrongAnswer();
      return;
    }

    setState(() {
      _playerRow = newRow;
      _playerCol = newCol;
      _moves++;
    });

    _audioService.playClick();

    // Check if reached the end
    if (_maze[newRow][newCol] == 3) {
      setState(() {
        _isGameWon = true;
      });
      _audioService.playVictory();
    }
  }

  void _resetGame() {
    setState(() {
      _playerRow = 0;
      _playerCol = 0;
      _isGameWon = false;
      _moves = 0;
    });
  }

  Color _getCellColor(int row, int col) {
    if (row == _playerRow && col == _playerCol) {
      return Colors.blue; // Player
    }
    
    switch (_maze[row][col]) {
      case 0:
        return Colors.white; // Path
      case 1:
        return Colors.grey.shade800; // Wall
      case 2:
        return Colors.green; // Start
      case 3:
        return Colors.red; // End
      default:
        return Colors.white;
    }
  }

  String _getCellEmoji(int row, int col) {
    if (row == _playerRow && col == _playerCol) {
      return '😊';
    }
    if (_maze[row][col] == 2) {
      return '🏁';
    }
    if (_maze[row][col] == 3) {
      return '🏆';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      autofocus: true,
      onKeyEvent: (KeyEvent event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            _movePlayer(-1, 0);
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            _movePlayer(1, 0);
          } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            _movePlayer(0, -1);
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            _movePlayer(0, 1);
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('🧩 Labirinto'),
          backgroundColor: Colors.orange,
          actions: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'Movimentos: $_moves',
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
              colors: [Colors.orange.shade200, Colors.orange.shade600],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isGameWon)
                  Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '🎉 PARABÉNS! 🎉',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Você completou em $_moves movimentos!',
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ],
                    ),
                  ),

                // Maze grid
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: List.generate(_maze.length, (row) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_maze[row].length, (col) {
                          return Container(
                            width: 35,
                            height: 35,
                            margin: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: _getCellColor(row, col),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Colors.black.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                _getCellEmoji(row, col),
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          );
                        }),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 30),

                // Instructions
                const Text(
                  'Use as setas do teclado',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 10),

                // Arrow buttons for mobile
                Column(
                  children: [
                    // Up arrow
                    IconButton(
                      onPressed: () => _movePlayer(-1, 0),
                      icon: const Icon(Icons.arrow_upward, size: 40),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Left arrow
                        IconButton(
                          onPressed: () => _movePlayer(0, -1),
                          icon: const Icon(Icons.arrow_back, size: 40),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        const SizedBox(width: 80),
                        // Right arrow
                        IconButton(
                          onPressed: () => _movePlayer(0, 1),
                          icon: const Icon(Icons.arrow_forward, size: 40),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),
                    // Down arrow
                    IconButton(
                      onPressed: () => _movePlayer(1, 0),
                      icon: const Icon(Icons.arrow_downward, size: 40),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Reset button
                ElevatedButton.icon(
                  onPressed: _resetGame,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reiniciar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
