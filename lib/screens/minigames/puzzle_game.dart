import 'package:flutter/material.dart';
import 'dart:math';
import '../../services/audio_service.dart';

class PuzzleGame extends StatefulWidget {
  const PuzzleGame({super.key});

  @override
  State<PuzzleGame> createState() => _PuzzleGameState();
}

class _PuzzleGameState extends State<PuzzleGame> {
  final AudioService _audioService = AudioService();
  
  // Puzzle configuration
  static const int gridSize = 3; // 3x3 puzzle
  static const int totalTiles = gridSize * gridSize;
  
  // Game state
  late List<int> _tiles;
  int _emptyTileIndex = totalTiles - 1;
  int _moves = 0;
  bool _isGameWon = false;
  
  // Biblical themed colors for tiles
  final List<Color> _tileColors = [
    Colors.red.shade300,
    Colors.blue.shade300,
    Colors.green.shade300,
    Colors.yellow.shade300,
    Colors.purple.shade300,
    Colors.orange.shade300,
    Colors.pink.shade300,
    Colors.teal.shade300,
  ];

  @override
  void initState() {
    super.initState();
    _audioService.playBackgroundMusic('memory-game.mp3');
    _initializePuzzle();
  }

  @override
  void dispose() {
    _audioService.stopBackgroundMusic();
    super.dispose();
  }

  void _initializePuzzle() {
    // Initialize tiles in order (0-8, where 8 is empty)
    _tiles = List.generate(totalTiles, (index) => index);
    
    // Shuffle the puzzle
    _shufflePuzzle();
    
    setState(() {
      _moves = 0;
      _isGameWon = false;
    });
  }

  void _shufflePuzzle() {
    final random = Random();
    
    // Make random valid moves to ensure solvability
    for (int i = 0; i < 100; i++) {
      List<int> validMoves = _getValidMoves();
      if (validMoves.isNotEmpty) {
        int randomMove = validMoves[random.nextInt(validMoves.length)];
        _swapTiles(_emptyTileIndex, randomMove);
      }
    }
  }

  List<int> _getValidMoves() {
    List<int> validMoves = [];
    int row = _emptyTileIndex ~/ gridSize;
    int col = _emptyTileIndex % gridSize;
    
    // Check up
    if (row > 0) validMoves.add(_emptyTileIndex - gridSize);
    // Check down
    if (row < gridSize - 1) validMoves.add(_emptyTileIndex + gridSize);
    // Check left
    if (col > 0) validMoves.add(_emptyTileIndex - 1);
    // Check right
    if (col < gridSize - 1) validMoves.add(_emptyTileIndex + 1);
    
    return validMoves;
  }

  void _swapTiles(int index1, int index2) {
    int temp = _tiles[index1];
    _tiles[index1] = _tiles[index2];
    _tiles[index2] = temp;
    _emptyTileIndex = index2;
  }

  void _onTileTap(int index) {
    if (_isGameWon) return;
    
    // Check if tile is adjacent to empty tile
    int row = index ~/ gridSize;
    int col = index % gridSize;
    int emptyRow = _emptyTileIndex ~/ gridSize;
    int emptyCol = _emptyTileIndex % gridSize;
    
    bool isAdjacent = (row == emptyRow && (col - emptyCol).abs() == 1) ||
                      (col == emptyCol && (row - emptyRow).abs() == 1);
    
    if (!isAdjacent) {
      _audioService.playMismatch();
      return;
    }
    
    setState(() {
      _swapTiles(_emptyTileIndex, index);
      _moves++;
    });
    
    _audioService.playClick();
    
    // Check if puzzle is solved
    if (_isPuzzleSolved()) {
      setState(() {
        _isGameWon = true;
      });
      _audioService.playVictory();
    }
  }

  bool _isPuzzleSolved() {
    for (int i = 0; i < totalTiles; i++) {
      if (_tiles[i] != i) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧩 Quebra-Cabeça'),
        backgroundColor: Colors.indigo,
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
            colors: [Colors.indigo.shade300, Colors.indigo.shade700],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Victory message
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

              // Instructions
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Deslize as peças para ordená-las de 1 a 8',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 20),

              // Puzzle grid
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: SizedBox(
                  width: 330,
                  height: 330,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gridSize,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                    ),
                    itemCount: totalTiles,
                    itemBuilder: (context, index) {
                      int tileNumber = _tiles[index];
                      bool isEmpty = tileNumber == totalTiles - 1;
                      
                      return GestureDetector(
                        onTap: () => _onTileTap(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isEmpty 
                                ? Colors.transparent 
                                : _tileColors[tileNumber % _tileColors.length],
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: isEmpty ? [] : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 5,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: isEmpty 
                                ? null 
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${tileNumber + 1}',
                                        style: const TextStyle(
                                          fontSize: 48,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black,
                                              offset: Offset(2, 2),
                                              blurRadius: 3,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Reset button
              ElevatedButton.icon(
                onPressed: _initializePuzzle,
                icon: const Icon(Icons.shuffle, size: 24),
                label: const Text(
                  'Embaralhar',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
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
