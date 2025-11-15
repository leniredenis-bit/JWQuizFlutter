import 'package:flutter/material.dart';
import 'dart:math';
import '../../services/audio_service.dart';

class WordSearchGame extends StatefulWidget {
  const WordSearchGame({super.key});

  @override
  State<WordSearchGame> createState() => _WordSearchGameState();
}

class _WordSearchGameState extends State<WordSearchGame> {
  final AudioService _audioService = AudioService();
  
  // Grid size
  static const int gridSize = 12;
  
  // Biblical words to find
  final List<String> _words = [
    'JESUS', 'FE', 'AMOR', 'PAZ', 'DEUS', 'SALVACAO',
    'ARCA', 'MOISÉS', 'ABRAAO', 'BIBLIA'
  ];
  
  late List<List<String>> _grid;
  final Set<String> _foundWords = {};
  List<Point<int>>? _selectedCells;
  Point<int>? _dragStart;
  
  @override
  void initState() {
    super.initState();
    _audioService.playBackgroundMusic('quiz-home.mp3');
    _generateGrid();
  }

  @override
  void dispose() {
    _audioService.stopBackgroundMusic();
    super.dispose();
  }

  void _generateGrid() {
    _grid = List.generate(
      gridSize,
      (_) => List.generate(gridSize, (_) => ''),
    );
    
    // Place words in the grid
    final random = Random();
    for (String word in _words) {
      bool placed = false;
      int attempts = 0;
      
      while (!placed && attempts < 100) {
        attempts++;
        
        // Random position and direction
        int row = random.nextInt(gridSize);
        int col = random.nextInt(gridSize);
        int direction = random.nextInt(4); // 0=horizontal, 1=vertical, 2=diagonal↘, 3=diagonal↗
        
        if (_canPlaceWord(word, row, col, direction)) {
          _placeWord(word, row, col, direction);
          placed = true;
        }
      }
    }
    
    // Fill empty cells with random letters
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (_grid[i][j].isEmpty) {
          _grid[i][j] = String.fromCharCode(65 + random.nextInt(26)); // A-Z
        }
      }
    }
  }

  bool _canPlaceWord(String word, int row, int col, int direction) {
    int dr = 0, dc = 0;
    
    switch (direction) {
      case 0: dc = 1; break;  // Horizontal →
      case 1: dr = 1; break;  // Vertical ↓
      case 2: dr = 1; dc = 1; break;  // Diagonal ↘
      case 3: dr = -1; dc = 1; break; // Diagonal ↗
    }
    
    for (int i = 0; i < word.length; i++) {
      int r = row + (dr * i);
      int c = col + (dc * i);
      
      if (r < 0 || r >= gridSize || c < 0 || c >= gridSize) {
        return false;
      }
      
      if (_grid[r][c].isNotEmpty && _grid[r][c] != word[i]) {
        return false;
      }
    }
    
    return true;
  }

  void _placeWord(String word, int row, int col, int direction) {
    int dr = 0, dc = 0;
    
    switch (direction) {
      case 0: dc = 1; break;
      case 1: dr = 1; break;
      case 2: dr = 1; dc = 1; break;
      case 3: dr = -1; dc = 1; break;
    }
    
    for (int i = 0; i < word.length; i++) {
      int r = row + (dr * i);
      int c = col + (dc * i);
      _grid[r][c] = word[i];
    }
  }

  void _onCellDragStart(int row, int col) {
    setState(() {
      _dragStart = Point(row, col);
      _selectedCells = [Point(row, col)];
    });
    _audioService.playClick();
  }

  void _onCellDragUpdate(int row, int col) {
    if (_dragStart == null) return;
    if (row < 0 || row >= gridSize || col < 0 || col >= gridSize) return;
    
    // Só atualiza se mudou de célula
    if (_selectedCells != null && _selectedCells!.isNotEmpty) {
      Point<int> lastCell = _selectedCells!.last;
      if (lastCell.x == row && lastCell.y == col) return;
    }
    
    setState(() {
      _selectedCells = _getCellsInLine(_dragStart!, Point(row, col));
    });
  }

  // Converte posição local do toque em índices de linha/coluna
  void _handlePanStart(Offset localPosition) {
    const cellSize = 30.0; // 28px + 2px margin
    const padding = 8.0;
    
    int col = ((localPosition.dx - padding) / cellSize).floor();
    int row = ((localPosition.dy - padding) / cellSize).floor();
    
    if (row >= 0 && row < gridSize && col >= 0 && col < gridSize) {
      _onCellDragStart(row, col);
    }
  }

  void _handlePanUpdate(Offset localPosition) {
    const cellSize = 30.0;
    const padding = 8.0;
    
    int col = ((localPosition.dx - padding) / cellSize).floor();
    int row = ((localPosition.dy - padding) / cellSize).floor();
    
    if (row >= 0 && row < gridSize && col >= 0 && col < gridSize) {
      _onCellDragUpdate(row, col);
    }
  }

  void _onCellDragEnd() {
    if (_selectedCells == null || _selectedCells!.isEmpty) return;
    
    String selectedWord = _selectedCells!
        .map((p) => _grid[p.x][p.y])
        .join('');
    
    // Check if it's a valid word (forward or backward)
    if (_words.contains(selectedWord) && !_foundWords.contains(selectedWord)) {
      setState(() {
        _foundWords.add(selectedWord);
      });
      _audioService.playMatch();
      
      // Check if all words found
      if (_foundWords.length == _words.length) {
        _audioService.playVictory();
      }
    } else {
      _audioService.playMismatch();
    }
    
    setState(() {
      _selectedCells = null;
      _dragStart = null;
    });
  }

  List<Point<int>> _getCellsInLine(Point<int> start, Point<int> end) {
    List<Point<int>> cells = [];
    
    int dr = (end.x - start.x).sign;
    int dc = (end.y - start.y).sign;
    
    // Only allow horizontal, vertical, or diagonal lines
    if (dr.abs() + dc.abs() == 0) {
      return [start];
    }
    
    Point<int> current = start;
    while (true) {
      cells.add(current);
      
      if (current == end) break;
      
      int nextRow = current.x + dr;
      int nextCol = current.y + dc;
      
      if (nextRow < 0 || nextRow >= gridSize || nextCol < 0 || nextCol >= gridSize) {
        break;
      }
      
      current = Point(nextRow, nextCol);
    }
    
    return cells;
  }

  bool _isCellSelected(int row, int col) {
    return _selectedCells?.any((p) => p.x == row && p.y == col) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔍 Caça-Palavras'),
        backgroundColor: Colors.teal,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                '${_foundWords.length}/${_words.length}',
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
            colors: [Colors.teal.shade200, Colors.teal.shade600],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Victory message
                if (_foundWords.length == _words.length)
                  Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Text(
                      '🎉 Parabéns! Você encontrou todas as palavras! 🎉',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Word list
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: _words.map((word) {
                      bool found = _foundWords.contains(word);
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: found ? Colors.green : Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          word,
                          style: TextStyle(
                            color: found ? Colors.white : Colors.white70,
                            fontWeight: FontWeight.bold,
                            decoration: found ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 10),

                // Grid with global gesture detector
                GestureDetector(
                  onPanStart: (details) {
                    _handlePanStart(details.localPosition);
                  },
                  onPanUpdate: (details) {
                    _handlePanUpdate(details.localPosition);
                  },
                  onPanEnd: (_) {
                    _onCellDragEnd();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: List.generate(gridSize, (row) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(gridSize, (col) {
                            bool isSelected = _isCellSelected(row, col);
                            
                            return Container(
                              width: 28,
                              height: 28,
                              margin: const EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? Colors.yellow.withOpacity(0.7)
                                    : Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Center(
                                child: Text(
                                  _grid[row][col],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.black : Colors.black87,
                                  ),
                                ),
                              ),
                            );
                          }),
                        );
                      }),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Reset button
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _foundWords.clear();
                      _generateGrid();
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Novo Jogo'),
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
