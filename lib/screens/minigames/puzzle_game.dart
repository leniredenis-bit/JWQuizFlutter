import 'package:flutter/material.dart';
import 'dart:math';
import '../../services/audio_service.dart';

class PuzzleGame extends StatefulWidget {
  const PuzzleGame({super.key});

  @override
  State<PuzzleGame> createState() => _PuzzleGameState();
}

class PuzzlePiece {
  final int id;
  final String emoji;
  final Color color;
  
  PuzzlePiece({required this.id, required this.emoji, required this.color});
}

class _PuzzleGameState extends State<PuzzleGame> {
  final AudioService _audioService = AudioService();
  
  // Puzzle configuration
  static const int gridSize = 3; // 3x3 jigsaw puzzle
  static const int totalPieces = gridSize * gridSize;
  
  // Game state
  late List<PuzzlePiece?> _board; // The puzzle board (where pieces are placed)
  late List<PuzzlePiece> _availablePieces; // Pieces to drag from
  int _moves = 0;
  bool _isGameWon = false;
  
  // Puzzle pieces with biblical/spiritual emojis
  final List<PuzzlePiece> _allPieces = [
    PuzzlePiece(id: 0, emoji: '📖', color: Colors.blue.shade300),
    PuzzlePiece(id: 1, emoji: '🙏', color: Colors.purple.shade300),
    PuzzlePiece(id: 2, emoji: '✝️', color: Colors.red.shade300),
    PuzzlePiece(id: 3, emoji: '🕊️', color: Colors.teal.shade300),
    PuzzlePiece(id: 4, emoji: '⭐', color: Colors.yellow.shade300),
    PuzzlePiece(id: 5, emoji: '🌟', color: Colors.orange.shade300),
    PuzzlePiece(id: 6, emoji: '💝', color: Colors.pink.shade300),
    PuzzlePiece(id: 7, emoji: '🌈', color: Colors.green.shade300),
    PuzzlePiece(id: 8, emoji: '🔔', color: Colors.indigo.shade300),
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
    // Initialize empty board
    _board = List.filled(totalPieces, null);
    
    // Shuffle available pieces
    _availablePieces = List.from(_allPieces);
    _availablePieces.shuffle(Random());
    
    setState(() {
      _moves = 0;
      _isGameWon = false;
    });
  }

  void _onPiecePlaced(int boardIndex, PuzzlePiece piece) {
    if (_isGameWon) return;
    
    setState(() {
      // Remove piece from available pieces
      _availablePieces.removeWhere((p) => p.id == piece.id);
      
      // Place piece on board
      _board[boardIndex] = piece;
      
      _moves++;
    });
    
    // Play sound based on correctness
    if (boardIndex == piece.id) {
      _audioService.playClick();
    } else {
      _audioService.playMismatch();
    }
    
    // Check if puzzle is solved
    if (_isPuzzleSolved()) {
      setState(() {
        _isGameWon = true;
      });
      _audioService.playVictory();
    }
  }

  void _onPieceRemoved(int boardIndex) {
    if (_isGameWon) return;
    
    setState(() {
      PuzzlePiece? piece = _board[boardIndex];
      if (piece != null) {
        _board[boardIndex] = null;
        _availablePieces.add(piece);
        _moves++;
      }
    });
  }

  bool _isPuzzleSolved() {
    for (int i = 0; i < totalPieces; i++) {
      if (_board[i] == null || _board[i]!.id != i) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧩 Quebra-Cabeça Jigsaw'),
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
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

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
                    'Arraste os emojis para os slots corretos',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 20),

                // Puzzle board (drop targets)
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
                      itemCount: totalPieces,
                      itemBuilder: (context, index) {
                        PuzzlePiece? placedPiece = _board[index];
                        bool isCorrect = placedPiece != null && placedPiece.id == index;
                        
                        return DragTarget<PuzzlePiece>(
                          onWillAcceptWithDetails: (details) => placedPiece == null,
                          onAcceptWithDetails: (details) => _onPiecePlaced(index, details.data),
                          builder: (context, candidateData, rejectedData) {
                            return GestureDetector(
                              onTap: placedPiece != null ? () => _onPieceRemoved(index) : null,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                decoration: BoxDecoration(
                                  color: placedPiece != null
                                      ? placedPiece.color
                                      : Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isCorrect 
                                        ? Colors.green
                                        : candidateData.isNotEmpty 
                                            ? Colors.yellow
                                            : Colors.white.withOpacity(0.3),
                                    width: isCorrect ? 3 : 2,
                                  ),
                                  boxShadow: placedPiece != null ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 5,
                                      spreadRadius: 2,
                                    ),
                                  ] : [],
                                ),
                                child: Center(
                                  child: placedPiece != null
                                      ? Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              placedPiece.emoji,
                                              style: const TextStyle(fontSize: 40),
                                            ),
                                            if (isCorrect)
                                              const Icon(
                                                Icons.check_circle,
                                                color: Colors.green,
                                                size: 20,
                                              ),
                                          ],
                                        )
                                      : Text(
                                          '${index + 1}',
                                          style: TextStyle(
                                            fontSize: 24,
                                            color: Colors.white.withOpacity(0.3),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Available pieces to drag
                if (_availablePieces.isNotEmpty)
                  Column(
                    children: [
                      const Text(
                        'Arraste as peças:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _availablePieces.map((piece) {
                            return Draggable<PuzzlePiece>(
                              data: piece,
                              feedback: Material(
                                color: Colors.transparent,
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: piece.color.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.5),
                                        blurRadius: 10,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      piece.emoji,
                                      style: const TextStyle(fontSize: 40),
                                    ),
                                  ),
                                ),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.3,
                                child: _buildPieceWidget(piece),
                              ),
                              child: _buildPieceWidget(piece),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 30),

                // Reset button
                ElevatedButton.icon(
                  onPressed: _initializePuzzle,
                  icon: const Icon(Icons.shuffle, size: 24),
                  label: const Text(
                    'Reiniciar',
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

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPieceWidget(PuzzlePiece piece) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: piece.color,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Text(
          piece.emoji,
          style: const TextStyle(fontSize: 40),
        ),
      ),
    );
  }
}
