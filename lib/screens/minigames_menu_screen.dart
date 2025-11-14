import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import 'minigames/tic_tac_toe_game.dart';
import 'minigames/hangman_game.dart';
import 'minigames/word_search_game.dart';
import 'minigames/maze_game.dart';
import 'minigames/sequence_game.dart';
import 'minigames/puzzle_game.dart';

class MinigamesMenuScreen extends StatelessWidget {
  const MinigamesMenuScreen({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> minigames = const [
    {
      'emoji': '⭕',
      'title': 'Jogo da Velha',
      'desc': 'Duelo 2 jogadores ou vs IA!',
      'color': Color(0xFF4A90E2),
      'screen': 'TicTacToeGame',
    },
    {
      'emoji': '🎯',
      'title': 'Forca',
      'desc': 'Adivinhe a palavra bíblica!',
      'color': Color(0xFFE24A4A),
      'screen': 'HangmanGame',
    },
    {
      'emoji': '🔍',
      'title': 'Caça-Palavras',
      'desc': 'Encontre palavras escondidas!',
      'color': Color(0xFF50C878),
      'screen': 'WordSearchGame',
    },
    {
      'emoji': '🧩',
      'title': 'Labirinto',
      'desc': 'Encontre a saída!',
      'color': Color(0xFFFF9500),
      'screen': 'MazeGame',
    },
    {
      'emoji': '🎨',
      'title': 'Sequência Rápida',
      'desc': 'Memorize o padrão de cores!',
      'color': Color(0xFF9B59B6),
      'screen': 'SequenceGame',
    },
    {
      'emoji': '🧩',
      'title': 'Quebra-Cabeça',
      'desc': 'Monte a imagem completa!',
      'color': Color(0xFF3498DB),
      'screen': 'PuzzleGame',
    },
  ];

  Widget _getGameScreen(String screenName) {
    switch (screenName) {
      case 'TicTacToeGame':
        return const TicTacToeGame();
      case 'HangmanGame':
        return const HangmanGame();
      case 'WordSearchGame':
        return const WordSearchGame();
      case 'MazeGame':
        return const MazeGame();
      case 'SequenceGame':
        return const SequenceGame();
      case 'PuzzleGame':
        return const PuzzleGame();
      default:
        return const TicTacToeGame();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF101A2C),
      appBar: AppBar(
        title: Text('Outros Minigames', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF162447),
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            AudioService().playClick();
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.0,
          ),
          itemCount: minigames.length,
          itemBuilder: (context, index) {
            final game = minigames[index];
            return GestureDetector(
              onTap: () {
                AudioService().playClick();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => _getGameScreen(game['screen'] as String),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      game['color'],
                      game['color'].withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: game['color'].withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      game['emoji'],
                      style: TextStyle(fontSize: 48),
                    ),
                    SizedBox(height: 8),
                    Text(
                      game['title'],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        game['desc'],
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
