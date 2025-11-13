import 'package:flutter/material.dart';
import 'dart:async';
import '../models/stats_service.dart';

class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({Key? key}) : super(key: key);

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class MemoryCard {
  final int id;
  final String emoji;
  final String name;
  bool isFlipped;
  bool isMatched;

  MemoryCard({
    required this.id,
    required this.emoji,
    required this.name,
    this.isFlipped = false,
    this.isMatched = false,
  });
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  List<MemoryCard> cards = [];
  List<int> flippedIndices = [];
  int attempts = 0;
  int matches = 0;
  Timer? _timer;
  int secondsElapsed = 0;
  bool isProcessing = false;

  // Dados bíblicos para o jogo
  final List<Map<String, String>> biblicalPairs = [
    {'emoji': '🍎', 'name': 'Adão e Eva'},
    {'emoji': '⛵', 'name': 'Arca de Noé'},
    {'emoji': '👑', 'name': 'Rei Davi'},
    {'emoji': '🐟', 'name': 'Jonas e o Peixe'},
    {'emoji': '🦁', 'name': 'Daniel e Leões'},
    {'emoji': '⭐', 'name': 'Estrela de Belém'},
    {'emoji': '🍞', 'name': 'Pães e Peixes'},
    {'emoji': '✝️', 'name': 'Cruz de Jesus'},
  ];

  @override
  void initState() {
    super.initState();
    initializeGame();
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        secondsElapsed++;
      });
    });
  }

  void initializeGame() {
    cards.clear();
    int id = 0;
    
    // Criar pares de cartas
    for (var pair in biblicalPairs) {
      cards.add(MemoryCard(
        id: id++,
        emoji: pair['emoji']!,
        name: pair['name']!,
      ));
      cards.add(MemoryCard(
        id: id++,
        emoji: pair['emoji']!,
        name: pair['name']!,
      ));
    }
    
    // Embaralhar
    cards.shuffle();
  }

  void onCardTap(int index) {
    if (isProcessing) return;
    if (cards[index].isFlipped || cards[index].isMatched) return;
    if (flippedIndices.length >= 2) return;

    setState(() {
      cards[index].isFlipped = true;
      flippedIndices.add(index);
    });

    if (flippedIndices.length == 2) {
      isProcessing = true;
      checkMatch();
    }
  }

  void checkMatch() {
    final index1 = flippedIndices[0];
    final index2 = flippedIndices[1];
    final card1 = cards[index1];
    final card2 = cards[index2];

    setState(() {
      attempts++;
    });

    if (card1.name == card2.name) {
      // Par encontrado!
      setState(() {
        card1.isMatched = true;
        card2.isMatched = true;
        matches++;
      });
      
      flippedIndices.clear();
      isProcessing = false;

      // Verificar se o jogo terminou
      if (matches == biblicalPairs.length) {
        _timer?.cancel();
        // Salvar estatísticas
        StatsService.saveMemoryGameStats(timeInSeconds: secondsElapsed);
        Future.delayed(Duration(milliseconds: 500), () {
          showVictoryDialog();
        });
      }
    } else {
      // Não é par, virar de volta
      Future.delayed(Duration(milliseconds: 800), () {
        setState(() {
          card1.isFlipped = false;
          card2.isFlipped = false;
          flippedIndices.clear();
          isProcessing = false;
        });
      });
    }
  }

  void showVictoryDialog() {
    final minutes = secondsElapsed ~/ 60;
    final seconds = secondsElapsed % 60;
    final timeString = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF162447),
        title: Text(
          '🎉 Parabéns!',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Você completou o jogo!',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text('⏱️', style: TextStyle(fontSize: 32)),
                    SizedBox(height: 8),
                    Text(
                      timeString,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Tempo',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text('🎯', style: TextStyle(fontSize: 32)),
                    SizedBox(height: 8),
                    Text(
                      '$attempts',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Tentativas',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                attempts = 0;
                matches = 0;
                secondsElapsed = 0;
                flippedIndices.clear();
                initializeGame();
                startTimer();
              });
            },
            child: Text('Jogar Novamente', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text('Voltar', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  void resetGame() {
    setState(() {
      attempts = 0;
      matches = 0;
      secondsElapsed = 0;
      flippedIndices.clear();
      isProcessing = false;
      initializeGame();
    });
    _timer?.cancel();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = secondsElapsed ~/ 60;
    final seconds = secondsElapsed % 60;
    final timeString = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: Color(0xFF101A2C),
      appBar: AppBar(
        title: Text('Jogo da Memória Bíblico'),
        backgroundColor: Color(0xFF162447),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: resetGame,
            tooltip: 'Reiniciar',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Stats do jogo
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF162447),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text('⏱️', style: TextStyle(fontSize: 24)),
                      SizedBox(height: 4),
                      Text(
                        timeString,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text('🎯', style: TextStyle(fontSize: 24)),
                      SizedBox(height: 4),
                      Text(
                        '$attempts',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text('✅', style: TextStyle(fontSize: 24)),
                      SizedBox(height: 4),
                      Text(
                        '$matches/${biblicalPairs.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            
            // Grid de cartas 4x4
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.75,
                ),
                itemCount: cards.length,
                itemBuilder: (context, index) {
                  final card = cards[index];
                  
                  return GestureDetector(
                    onTap: () => onCardTap(index),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: card.isMatched
                            ? Colors.green.shade700
                            : card.isFlipped
                                ? Color(0xFF3A5A8C)
                                : Color(0xFF23395D),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: card.isFlipped || card.isMatched
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    card.emoji,
                                    style: TextStyle(fontSize: 32),
                                  ),
                                  SizedBox(height: 4),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: Text(
                                      card.name,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              )
                            : Icon(
                                Icons.question_mark,
                                color: Colors.white54,
                                size: 32,
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
