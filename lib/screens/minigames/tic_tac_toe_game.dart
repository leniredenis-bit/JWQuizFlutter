import 'dart:math';
import 'package:flutter/material.dart';
import '../../services/audio_service.dart';

enum Player { X, O, none }
enum Mode { twoPlayers, vsAi }
enum AiDifficulty { easy, impossible }

class TicTacToeGame extends StatefulWidget {
  const TicTacToeGame({super.key});

  @override
  State<TicTacToeGame> createState() => _TicTacToeGameState();
}

class _TicTacToeGameState extends State<TicTacToeGame> {
  // Board: 9 positions
  List<Player> board = List<Player>.filled(9, Player.none);
  Player current = Player.X; // who plays now
  Mode mode = Mode.vsAi;
  AiDifficulty aiDifficulty = AiDifficulty.impossible;
  bool xStarts = true;

  // Score
  int xWins = 0;
  int oWins = 0;
  int draws = 0;

  bool gameOver = false;
  String infoText = '';

  final Random _rnd = Random();

  @override
  void initState() {
    super.initState();
    resetBoard();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void resetBoard({bool keepStarter = true}) {
    setState(() {
      board = List<Player>.filled(9, Player.none);
      gameOver = false;
      if (!keepStarter) {
        xStarts = !xStarts;
      }
      current = xStarts ? Player.X : Player.O;
      infoText = 'Vez: ${playerToString(current)}';
      // If AI starts
      if (mode == Mode.vsAi && current == Player.O) {
        Future.delayed(const Duration(milliseconds: 350), () => aiMove());
      }
    });
  }

  void resetAll() {
    AudioService().playClick();
    setState(() {
      xWins = 0;
      oWins = 0;
      draws = 0;
    });
    resetBoard(keepStarter: true);
  }

  // Convert player to display string
  String playerToString(Player p) {
    if (p == Player.X) return 'X';
    if (p == Player.O) return 'O';
    return '-';
  }

  // Handle tap on cell
  void handleTap(int index) {
    if (gameOver) return;
    if (board[index] != Player.none) return;

    // If vs AI and it's O's turn and AI controls O, block user taps
    if (mode == Mode.vsAi && current == Player.O) return;

    // Som de clique ao jogar
    AudioService().playClick();

    setState(() {
      board[index] = current;
      evaluateAfterMove();
    });

    // If after player's move it's AI's turn, trigger AI
    if (!gameOver && mode == Mode.vsAi && current == Player.O) {
      Future.delayed(const Duration(milliseconds: 350), () => aiMove());
    }
  }

  void evaluateAfterMove() {
    final result = checkWinner(board);
    if (result != Player.none) {
      // someone won
      gameOver = true;
      if (result == Player.X) {
        xWins++;
        AudioService().playVictory();
      } else if (result == Player.O) {
        oWins++;
        AudioService().playGameOver();
      }
      infoText = 'Jogador ${playerToString(result)} venceu!';
      setState(() {});
      return;
    }

    if (!board.contains(Player.none)) {
      // draw
      gameOver = true;
      draws++;
      infoText = 'Empate!';
      setState(() {});
      return;
    }

    // continue
    current = (current == Player.X) ? Player.O : Player.X;
    infoText = 'Vez: ${playerToString(current)}';
    setState(() {});
  }

  // AI move logic
  void aiMove() {
    if (gameOver) return;
    // AI plays as O
    int move;
    if (aiDifficulty == AiDifficulty.easy) {
      // random empty cell
      final empties = <int>[];
      for (int i = 0; i < 9; i++) {
        if (board[i] == Player.none) empties.add(i);
      }
      if (empties.isEmpty) return;
      move = empties[_rnd.nextInt(empties.length)];
    } else {
      // Minimax for optimal play
      move = findBestMove(board, Player.O);
    }

    AudioService().playClick();

    setState(() {
      board[move] = Player.O;
      evaluateAfterMove();
    });
  }

  // Check winner: returns Player.X / Player.O / Player.none
  Player checkWinner(List<Player> b) {
    const lines = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];
    for (final line in lines) {
      final a = b[line[0]];
      final c = b[line[1]];
      final d = b[line[2]];
      if (a != Player.none && a == c && a == d) {
        return a;
      }
    }
    return Player.none;
  }

  // Minimax algorithm: returns best move index for playerToMove
  int findBestMove(List<Player> b, Player playerToMove) {
    int bestVal = -1000;
    int bestMove = -1;

    for (int i = 0; i < 9; i++) {
      if (b[i] == Player.none) {
        b[i] = playerToMove;
        int moveVal = minimax(b, 0, false, playerToMove);
        b[i] = Player.none;
        if (moveVal > bestVal) {
          bestMove = i;
          bestVal = moveVal;
        }
      }
    }

    // If no best found (shouldn't happen), pick random
    if (bestMove == -1) {
      final empties = <int>[];
      for (int i = 0; i < 9; i++) {
        if (b[i] == Player.none) empties.add(i);
      }
      if (empties.isEmpty) return 0;
      return empties[_rnd.nextInt(empties.length)];
    }

    return bestMove;
  }

  // Minimax returns score from perspective of AI (O)
  int minimax(List<Player> b, int depth, bool isMaximizing, Player aiPlayer) {
    final winner = checkWinner(b);
    if (winner == aiPlayer) return 10 - depth;
    if (winner != Player.none && winner != aiPlayer) return depth - 10;
    if (!b.contains(Player.none)) return 0;

    if (isMaximizing) {
      int best = -1000;
      for (int i = 0; i < 9; i++) {
        if (b[i] == Player.none) {
          b[i] = aiPlayer;
          best = max(best, minimax(b, depth + 1, !isMaximizing, aiPlayer));
          b[i] = Player.none;
        }
      }
      return best;
    } else {
      // minimizing (opponent)
      Player opponent = (aiPlayer == Player.O) ? Player.X : Player.O;
      int best = 1000;
      for (int i = 0; i < 9; i++) {
        if (b[i] == Player.none) {
          b[i] = opponent;
          best = min(best, minimax(b, depth + 1, !isMaximizing, aiPlayer));
          b[i] = Player.none;
        }
      }
      return best;
    }
  }

  // UI Helpers
  Widget buildCell(int index) {
    final p = board[index];
    final color = (p == Player.X) ? Colors.blue : (p == Player.O ? Colors.red : Colors.black54);
    return GestureDetector(
      onTap: () => handleTap(index),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white24, width: 2),
          color: Color(0xFF1E2A3A),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
            child: Text(
              p == Player.none ? '' : playerToString(p),
              key: ValueKey(p),
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ),
      ),
    );
  }

  Widget controlPanel() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF1E2A3A).withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Info/Status text
          Center(
            child: Text(
              infoText,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Mode selection - redesigned
          Container(
            decoration: BoxDecoration(
              color: Color(0xFF0D1620),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      AudioService().playClick();
                      setState(() {
                        mode = Mode.vsAi;
                      });
                      resetBoard();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: mode == Mode.vsAi ? Color(0xFF4A90E2) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.computer,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'vs IA',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: mode == Mode.vsAi ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      AudioService().playClick();
                      setState(() {
                        mode = Mode.twoPlayers;
                      });
                      resetBoard();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: mode == Mode.twoPlayers ? Color(0xFF4A90E2) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            '2 Jogadores',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: mode == Mode.twoPlayers ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Difficulty & Starter
          Row(
            children: [
              // Difficulty (only if vs AI)
              if (mode == Mode.vsAi)
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Color(0xFF0D1620),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.psychology, color: Colors.orange, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: DropdownButton<AiDifficulty>(
                            value: aiDifficulty,
                            isExpanded: true,
                            dropdownColor: Color(0xFF1E2A3A),
                            style: TextStyle(color: Colors.white, fontSize: 14),
                            underline: Container(),
                            items: const [
                              DropdownMenuItem(value: AiDifficulty.easy, child: Text('Fácil')),
                              DropdownMenuItem(value: AiDifficulty.impossible, child: Text('Impossível')),
                            ],
                            onChanged: (v) {
                              if (v == null) return;
                              AudioService().playClick();
                              setState(() {
                                aiDifficulty = v;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              if (mode == Mode.vsAi) const SizedBox(width: 12),
              
              // Who starts
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Color(0xFF0D1620),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.play_arrow, color: Colors.green, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Inicia:',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (!xStarts) {
                                AudioService().playClick();
                                setState(() {
                                  xStarts = true;
                                  resetBoard();
                                });
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: xStarts ? Colors.blue : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'X',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: xStarts ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {
                              if (xStarts) {
                                AudioService().playClick();
                                setState(() {
                                  xStarts = false;
                                  resetBoard();
                                });
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: !xStarts ? Colors.red : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'O',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: !xStarts ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    AudioService().playClick();
                    resetBoard();
                  },
                  icon: const Icon(Icons.replay, size: 20),
                  label: const Text('Reiniciar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4A90E2),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: resetAll,
                  icon: const Icon(Icons.refresh, size: 20),
                  label: const Text('Zerar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFE24A4A),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget scorePanel() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        scoreBox('X', xWins, Colors.blue),
        scoreBox('Empates', draws, Colors.grey),
        scoreBox('O', oWins, Colors.red),
      ],
    );
  }

  Widget scoreBox(String label, int value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 16)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8), border: Border.all(color: color, width: 2)),
          child: Text(value.toString(), style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 20)),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final boardGrid = AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(16),
        itemCount: 9,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemBuilder: (context, index) {
          return buildCell(index);
        },
      ),
    );

    return Scaffold(
      backgroundColor: Color(0xFF101A2C),
      appBar: AppBar(
        title: const Text('Jogo da Velha', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF162447),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            scorePanel(),
            const SizedBox(height: 12),
            Expanded(child: boardGrid),
            const SizedBox(height: 12),
            controlPanel(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
