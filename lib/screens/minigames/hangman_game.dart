import 'package:flutter/material.dart';
import 'dart:math';
import '../../services/audio_service.dart';

// Custom Painter para desenhar o boneco da forca
class HangmanPainter extends CustomPainter {
  final int errors;

  HangmanPainter(this.errors);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // 1. Cabeça
    if (errors >= 1) {
      canvas.drawCircle(
        Offset(size.width / 2, size.height * 0.25),
        25,
        paint,
      );
      
      // Olhos tristes
      canvas.drawCircle(
        Offset(size.width / 2 - 8, size.height * 0.23),
        3,
        fillPaint,
      );
      canvas.drawCircle(
        Offset(size.width / 2 + 8, size.height * 0.23),
        3,
        fillPaint,
      );
      
      // Boca triste
      final mouthPath = Path();
      mouthPath.moveTo(size.width / 2 - 10, size.height * 0.28);
      mouthPath.quadraticBezierTo(
        size.width / 2, size.height * 0.26,
        size.width / 2 + 10, size.height * 0.28,
      );
      canvas.drawPath(mouthPath, paint);
    }

    // 2. Corpo
    if (errors >= 2) {
      canvas.drawLine(
        Offset(size.width / 2, size.height * 0.32),
        Offset(size.width / 2, size.height * 0.55),
        paint,
      );
    }

    // 3. Braço esquerdo
    if (errors >= 3) {
      canvas.drawLine(
        Offset(size.width / 2, size.height * 0.38),
        Offset(size.width / 2 - 25, size.height * 0.48),
        paint,
      );
    }

    // 4. Braço direito
    if (errors >= 4) {
      canvas.drawLine(
        Offset(size.width / 2, size.height * 0.38),
        Offset(size.width / 2 + 25, size.height * 0.48),
        paint,
      );
    }

    // 5. Perna esquerda
    if (errors >= 5) {
      canvas.drawLine(
        Offset(size.width / 2, size.height * 0.55),
        Offset(size.width / 2 - 20, size.height * 0.75),
        paint,
      );
    }

    // 6. Perna direita - GAME OVER
    if (errors >= 6) {
      canvas.drawLine(
        Offset(size.width / 2, size.height * 0.55),
        Offset(size.width / 2 + 20, size.height * 0.75),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(HangmanPainter oldDelegate) => errors != oldDelegate.errors;
}

class HangmanGame extends StatefulWidget {
  const HangmanGame({super.key});

  @override
  State<HangmanGame> createState() => _HangmanGameState();
}

class _HangmanGameState extends State<HangmanGame> {
  // Palavras bíblicas seguras
  final List<String> words = [
    "MOISES", "DANIEL", "JESUS", "RUTE", "ESTER", "ISAIAS",
    "AMOR", "FE", "SALMO", "JOSE", "PAZ", "ABRAAO", "ORACAO",
    "DAVI", "MARIA", "PEDRO", "PAULO", "JOAO", "ATOS", "GENESIS"
  ];

  late String chosenWord;
  List<String> guessedLetters = [];
  List<String> wrongLetters = [];
  int maxErrors = 6;

  @override
  void initState() {
    super.initState();
    _restartGame();
  }

  void _restartGame() {
    AudioService().playClick();
    chosenWord = words[Random().nextInt(words.length)];
    guessedLetters = [];
    wrongLetters = [];
    setState(() {});
  }

  bool get hasWon =>
      chosenWord.split('').every((letter) => guessedLetters.contains(letter));

  bool get hasLost => wrongLetters.length >= maxErrors;

  void _guessLetter(String letter) {
    if (guessedLetters.contains(letter) || wrongLetters.contains(letter)) {
      return;
    }

    AudioService().playClick();

    if (chosenWord.contains(letter)) {
      guessedLetters.add(letter);
      if (hasWon) {
        AudioService().playVictory();
      } else {
        AudioService().playCorrectAnswer();
      }
    } else {
      wrongLetters.add(letter);
      if (hasLost) {
        AudioService().playGameOver();
      } else {
        AudioService().playWrongAnswer();
      }
    }

    setState(() {});
  }

  Widget _buildHangmanDrawing() {
    int errors = wrongLetters.length;

    return Column(
      children: [
        Text("Erros: $errors / $maxErrors",
            style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Container(
          height: 200,
          width: 200,
          child: CustomPaint(
            painter: HangmanPainter(errors),
            size: Size(200, 200),
          ),
        ),
      ],
    );
  }

  Widget _buildWordDisplay() {
    return Wrap(
      spacing: 8,
      alignment: WrapAlignment.center,
      children: chosenWord
          .split('')
          .map((letter) => Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white54, width: 2),
                  borderRadius: BorderRadius.circular(8),
                  color: Color(0xFF1E2A3A),
                ),
                child: Text(
                  guessedLetters.contains(letter) ? letter : "_",
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildKeyboard() {
    const letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    
    // Layout responsivo para mobile
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calcula tamanho dos botões baseado na largura disponível
        double buttonSize = (constraints.maxWidth - 60) / 7; // 7 botões por linha com espaçamento
        buttonSize = buttonSize.clamp(32.0, 48.0); // Mínimo 32, máximo 48

        return Wrap(
          spacing: 4,
          runSpacing: 4,
          alignment: WrapAlignment.center,
          children: letters.split('').map((letter) {
            bool disabled = guessedLetters.contains(letter) ||
                wrongLetters.contains(letter) ||
                hasWon ||
                hasLost;

            bool isWrong = wrongLetters.contains(letter);
            bool isCorrect = guessedLetters.contains(letter);

            return SizedBox(
              width: buttonSize,
              height: buttonSize,
              child: ElevatedButton(
                onPressed: disabled ? null : () => _guessLetter(letter),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCorrect ? Colors.green : (isWrong ? Colors.red.shade300 : Color(0xFF4A90E2)),
                  disabledBackgroundColor: isCorrect ? Colors.green.shade700 : (isWrong ? Colors.red.shade700 : Colors.grey.shade600),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: EdgeInsets.all(4),
                ),
                child: FittedBox(
                  child: Text(
                    letter,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF101A2C),
      appBar: AppBar(
        title: const Text("Jogo da Forca", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF162447),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHangmanDrawing(),
            const SizedBox(height: 20),
            _buildWordDisplay(),
            const SizedBox(height: 20),
            if (hasWon)
              const Text(
                "🎉 Parabéns! Você acertou!",
                style: TextStyle(fontSize: 24, color: Colors.green, fontWeight: FontWeight.bold),
              ),
            if (hasLost)
              Text(
                "😢 Você perdeu!\nA palavra era: $chosenWord",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, color: Colors.red, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 20),
            if (!hasWon && !hasLost) _buildKeyboard(),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _restartGame,
              icon: Icon(Icons.refresh),
              label: const Text("Jogar Novamente"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFE24A4A),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
