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

// Classe com todos os temas disponíveis
class MemoryThemes {
  static const Map<String, List<Map<String, String>>> themes = {
    'animais': [
      {'emoji': '🐶', 'name': 'Cachorro'},
      {'emoji': '🐱', 'name': 'Gato'},
      {'emoji': '🐭', 'name': 'Rato'},
      {'emoji': '🐹', 'name': 'Hamster'},
      {'emoji': '🐰', 'name': 'Coelho'},
      {'emoji': '🦊', 'name': 'Raposa'},
      {'emoji': '🐻', 'name': 'Urso'},
      {'emoji': '🐼', 'name': 'Panda'},
      {'emoji': '🐨', 'name': 'Coalá'},
      {'emoji': '🐯', 'name': 'Tigre'},
      {'emoji': '🦁', 'name': 'Leão'},
      {'emoji': '🐮', 'name': 'Vaca'},
      {'emoji': '🐷', 'name': 'Porco'},
      {'emoji': '🐸', 'name': 'Sapo'},
      {'emoji': '🐵', 'name': 'Macaco'},
    ],
    'frutas': [
      {'emoji': '🍎', 'name': 'Maçã'},
      {'emoji': '🍌', 'name': 'Banana'},
      {'emoji': '🍇', 'name': 'Uva'},
      {'emoji': '🍓', 'name': 'Morango'},
      {'emoji': '🍈', 'name': 'Melão'},
      {'emoji': '🍒', 'name': 'Cereja'},
      {'emoji': '🍑', 'name': 'Pêssego'},
      {'emoji': '🥝', 'name': 'Kiwi'},
      {'emoji': '🥭', 'name': 'Manga'},
      {'emoji': '🥥', 'name': 'Coco'},
      {'emoji': '🍉', 'name': 'Melancia'},
      {'emoji': '🍊', 'name': 'Laranja'},
      {'emoji': '🍋', 'name': 'Limão'},
      {'emoji': '🍐', 'name': 'Pêra'},
      {'emoji': '🍍', 'name': 'Abacaxi'},
    ],
    'transportes': [
      {'emoji': '🚗', 'name': 'Carro'},
      {'emoji': '🚕', 'name': 'Táxi'},
      {'emoji': '🚌', 'name': 'Ônibus'},
      {'emoji': '🚑', 'name': 'Ambulância'},
      {'emoji': '🚓', 'name': 'Polícia'},
      {'emoji': '🚚', 'name': 'Caminhão'},
      {'emoji': '🚜', 'name': 'Trator'},
      {'emoji': '🚲', 'name': 'Bicicleta'},
      {'emoji': '🏍️', 'name': 'Moto'},
      {'emoji': '✈️', 'name': 'Avião'},
      {'emoji': '🚀', 'name': 'Foguete'},
      {'emoji': '⛵', 'name': 'Barco'},
      {'emoji': '🚢', 'name': 'Navio'},
      {'emoji': '🚂', 'name': 'Trem'},
      {'emoji': '🚁', 'name': 'Helicóptero'},
    ],
    'peixes': [
      {'emoji': '🐟', 'name': 'Peixe'},
      {'emoji': '🐠', 'name': 'Peixe Tropical'},
      {'emoji': '🐡', 'name': 'Baiacu'},
      {'emoji': '🦈', 'name': 'Tubarão'},
      {'emoji': '🐙', 'name': 'Polvo'},
      {'emoji': '🦑', 'name': 'Lula'},
      {'emoji': '🦞', 'name': 'Lagosta'},
      {'emoji': '🦀', 'name': 'Caranguejo'},
      {'emoji': '🐚', 'name': 'Concha'},
      {'emoji': '🐋', 'name': 'Baleia'},
      {'emoji': '🐳', 'name': 'Orca'},
      {'emoji': '🦭', 'name': 'Foca'},
      {'emoji': '🐢', 'name': 'Tartaruga'},
      {'emoji': '🐊', 'name': 'Crocodilo'},
      {'emoji': '🦎', 'name': 'Lagarto'},
    ],
    'aves': [
      {'emoji': '🐦', 'name': 'Pássaro'},
      {'emoji': '🦅', 'name': 'Águia'},
      {'emoji': '🦉', 'name': 'Coruja'},
      {'emoji': '🦆', 'name': 'Pato'},
      {'emoji': '🦜', 'name': 'Papagaio'},
      {'emoji': '🐔', 'name': 'Galinha'},
      {'emoji': '🐧', 'name': 'Pinguim'},
      {'emoji': '🦚', 'name': 'Pavão'},
      {'emoji': '🦢', 'name': 'Cisne'},
      {'emoji': '🦃', 'name': 'Peru'},
      {'emoji': '🐓', 'name': 'Galo'},
      {'emoji': '🦇', 'name': 'Morcego'},
      {'emoji': '🦤', 'name': 'Dodô'},
      {'emoji': '🦩', 'name': 'Flamingo'},
      {'emoji': '🕊️', 'name': 'Pombo'},
    ],
    'numeros': [
      {'emoji': '1️⃣', 'name': 'Um'},
      {'emoji': '2️⃣', 'name': 'Dois'},
      {'emoji': '3️⃣', 'name': 'Três'},
      {'emoji': '4️⃣', 'name': 'Quatro'},
      {'emoji': '5️⃣', 'name': 'Cinco'},
      {'emoji': '6️⃣', 'name': 'Seis'},
      {'emoji': '7️⃣', 'name': 'Sete'},
      {'emoji': '8️⃣', 'name': 'Oito'},
      {'emoji': '9️⃣', 'name': 'Nove'},
      {'emoji': '🔟', 'name': 'Dez'},
      {'emoji': '0️⃣', 'name': 'Zero'},
      {'emoji': '➕', 'name': 'Mais'},
      {'emoji': '➖', 'name': 'Menos'},
      {'emoji': '✖️', 'name': 'Vezes'},
      {'emoji': '➗', 'name': 'Dividir'},
    ],
    'objetos': [
      {'emoji': '📱', 'name': 'Celular'},
      {'emoji': '💻', 'name': 'Computador'},
      {'emoji': '⌚', 'name': 'Relógio'},
      {'emoji': '📷', 'name': 'Câmera'},
      {'emoji': '📹', 'name': 'Vídeo'},
      {'emoji': '📺', 'name': 'TV'},
      {'emoji': '📻', 'name': 'Rádio'},
      {'emoji': '💡', 'name': 'Lâmpada'},
      {'emoji': '🔋', 'name': 'Bateria'},
      {'emoji': '🔌', 'name': 'Tomada'},
      {'emoji': '🧰', 'name': 'Ferramentas'},
      {'emoji': '🔧', 'name': 'Chave'},
      {'emoji': '🔨', 'name': 'Martelo'},
      {'emoji': '✂️', 'name': 'Tesoura'},
      {'emoji': '🔒', 'name': 'Cadeado'},
    ],
    'natureza': [
      {'emoji': '🌸', 'name': 'Cerejeira'},
      {'emoji': '🌺', 'name': 'Flor'},
      {'emoji': '🌻', 'name': 'Girassol'},
      {'emoji': '🌼', 'name': 'Margarida'},
      {'emoji': '🌹', 'name': 'Rosa'},
      {'emoji': '🍃', 'name': 'Folha'},
      {'emoji': '☘️', 'name': 'Trevo'},
      {'emoji': '🌳', 'name': 'Árvore'},
      {'emoji': '🌲', 'name': 'Pinheiro'},
      {'emoji': '🌴', 'name': 'Palmeira'},
      {'emoji': '🌵', 'name': 'Cacto'},
      {'emoji': '🌱', 'name': 'Broto'},
      {'emoji': '🍄', 'name': 'Cogumelo'},
      {'emoji': '🌙', 'name': 'Lua'},
      {'emoji': '☀️', 'name': 'Sol'},
    ],
  };

  // Retorna os itens do tema selecionado
  static List<Map<String, String>> getThemeItems(String theme) {
    if (theme == 'todos') {
      // Mistura todos os temas
      List<Map<String, String>> allItems = [];
      themes.forEach((key, value) {
        allItems.addAll(value);
      });
      allItems.shuffle();
      return allItems;
    }
    return List<Map<String, String>>.from(themes[theme] ?? themes['animais']!);
  }

  // Retorna o nome de exibição do tema
  static String getThemeDisplayName(String theme) {
    const Map<String, String> displayNames = {
      'animais': '🐶 Animais',
      'frutas': '🍎 Frutas',
      'transportes': '🚗 Transportes',
      'peixes': '🐟 Peixes',
      'aves': '🦅 Aves',
      'numeros': '🔢 Números',
      'objetos': '📱 Objetos',
      'natureza': '🌸 Natureza',
      'todos': '🎲 Todos',
    };
    return displayNames[theme] ?? theme;
  }
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  List<MemoryCard> cards = [];
  List<int> flippedIndices = [];
  int attempts = 0;
  int matches = 0;
  Timer? _timer;
  int secondsElapsed = 0;
  bool isProcessing = false;

  // Configurações do jogo
  bool showConfig = true; // Mostra tela de config primeiro
  String selectedTheme = 'animais';
  String selectedDifficulty = 'medio'; // facil=6, medio=10, dificil=15 pares
  int numPlayers = 1;
  int currentPlayer = 0;
  List<int> playerScores = [0]; // Pontos de cada jogador

  // Dados bíblicos para o jogo (mantidos para compatibilidade - não mais usado)
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
    // Não inicia o jogo automaticamente - espera configuração
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startGame() {
    setState(() {
      showConfig = false;
      playerScores = List.filled(numPlayers, 0);
      currentPlayer = 0;
      attempts = 0;
      matches = 0;
      secondsElapsed = 0;
    });
    initializeGame();
    startTimer();
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!showConfig && mounted) {
        setState(() {
          secondsElapsed++;
        });
      }
    });
  }

  void initializeGame() {
    cards.clear();
    
    // Obter número de pares baseado na dificuldade
    int numPairs;
    switch (selectedDifficulty) {
      case 'facil':
        numPairs = 6;
        break;
      case 'dificil':
        numPairs = 15;
        break;
      default: // medio
        numPairs = 10;
    }
    
    // Obter itens do tema selecionado
    List<Map<String, String>> themeItems = MemoryThemes.getThemeItems(selectedTheme);
    themeItems.shuffle();
    
    // Pegar apenas o número de pares necessários
    List<Map<String, String>> selectedItems = themeItems.take(numPairs).toList();
    
    int id = 0;
    
    // Criar pares de cartas
    for (var item in selectedItems) {
      // Adiciona o primeiro card do par
      cards.add(MemoryCard(
        id: id++,
        emoji: item['emoji']!,
        name: item['name']!,
      ));
      // Adiciona o segundo card do par
      cards.add(MemoryCard(
        id: id++,
        emoji: item['emoji']!,
        name: item['name']!,
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
        
        // Adiciona ponto ao jogador atual
        playerScores[currentPlayer]++;
      });
      
      flippedIndices.clear();
      isProcessing = false;

      // Obter número total de pares baseado na dificuldade
      int totalPairs;
      switch (selectedDifficulty) {
        case 'facil':
          totalPairs = 6;
          break;
        case 'dificil':
          totalPairs = 15;
          break;
        default: // medio
          totalPairs = 10;
      }

      // Verificar se o jogo terminou
      if (matches == totalPairs) {
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
          
          // Trocar jogador em modo multiplayer
          if (numPlayers > 1) {
            currentPlayer = (currentPlayer + 1) % numPlayers;
          }
        });
      });
    }
  }

  void showVictoryDialog() {
    final minutes = secondsElapsed ~/ 60;
    final seconds = secondsElapsed % 60;
    final timeString = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    // Encontrar vencedor em modo multiplayer
    String resultText;
    Widget resultsWidget;
    
    if (numPlayers > 1) {
      int maxScore = playerScores.reduce((a, b) => a > b ? a : b);
      List<int> winners = [];
      for (int i = 0; i < playerScores.length; i++) {
        if (playerScores[i] == maxScore) {
          winners.add(i);
        }
      }
      
      if (winners.length == 1) {
        resultText = '🏆 Jogador ${winners[0] + 1} venceu!';
      } else {
        resultText = '🤝 Empate!';
      }
      
      resultsWidget = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            resultText,
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          ...List.generate(numPlayers, (i) {
            bool isWinner = winners.contains(i);
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isWinner ? '👑 ' : '   ',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(
                    'Jogador ${i + 1}: ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  Text(
                    '${playerScores[i]} pares',
                    style: TextStyle(
                      color: isWinner ? Colors.amber : Colors.white70,
                      fontSize: 16,
                      fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      );
    } else {
      resultText = 'Você completou o jogo!';
      resultsWidget = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            resultText,
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
      );
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF162447),
        title: Text(
          '🎉 Parabéns!',
          style: TextStyle(color: Colors.white),
        ),
        content: resultsWidget,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Repetir com mesmas configurações
              setState(() {
                playerScores = List.filled(numPlayers, 0);
                currentPlayer = 0;
                attempts = 0;
                matches = 0;
                secondsElapsed = 0;
              });
              initializeGame();
              startTimer();
            },
            child: Text('🔁 Repetir', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                showConfig = true; // Volta para tela de configuração
              });
            },
            child: Text('Nova Partida', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text('Início', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  void resetGame() {
    setState(() {
      showConfig = true; // Volta para tela de configuração
      _timer?.cancel();
    });
  }

  Widget _buildDifficultyButton(String difficulty, String label, String subtitle) {
    bool isSelected = selectedDifficulty == difficulty;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDifficulty = difficulty;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF23395D) : Color(0xFF101A2C),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.amber : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerButton(int players, String label) {
    bool isSelected = numPlayers == players;
    return GestureDetector(
      onTap: () {
        setState(() {
          numPlayers = players;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF23395D) : Color(0xFF101A2C),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.amber : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 2),
            Text(
              players == 1 ? 'Solo' : '$players jogadores',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tela de configuração
    if (showConfig) {
      return Scaffold(
        backgroundColor: Color(0xFF101A2C),
        appBar: AppBar(
          title: Text('Configurar Jogo'),
          backgroundColor: Color(0xFF162447),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Seleção de Tema (Expansível)
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF162447),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ExpansionTile(
                  title: Text(
                    'Tema: ${MemoryThemes.getThemeDisplayName(selectedTheme)}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  iconColor: Colors.white,
                  collapsedIconColor: Colors.white70,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          'animais',
                          'frutas',
                          'transportes',
                          'peixes',
                          'aves',
                          'numeros',
                          'objetos',
                          'natureza',
                          'todos',
                        ].map((theme) {
                          bool isSelected = selectedTheme == theme;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedTheme = theme;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? Color(0xFF23395D) : Color(0xFF101A2C),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected ? Colors.amber : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                MemoryThemes.getThemeDisplayName(theme),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              
              // Seleção de Dificuldade (Expansível)
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF162447),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ExpansionTile(
                  title: Text(
                    'Dificuldade: ${selectedDifficulty == "facil" ? "Fácil (6 pares)" : selectedDifficulty == "medio" ? "Médio (10 pares)" : "Difícil (15 pares)"}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  iconColor: Colors.white,
                  collapsedIconColor: Colors.white70,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildDifficultyButton('facil', 'Fácil', '6 pares'),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: _buildDifficultyButton('medio', 'Médio', '10 pares'),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: _buildDifficultyButton('dificil', 'Difícil', '15 pares'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              
              // Seleção de Jogadores (Expansível)
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF162447),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ExpansionTile(
                  title: Text(
                    'Jogadores: ${numPlayers == 1 ? "Solo" : "$numPlayers jogadores"}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  iconColor: Colors.white,
                  collapsedIconColor: Colors.white70,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildPlayerButton(1, '1'),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: _buildPlayerButton(2, '2'),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: _buildPlayerButton(3, '3'),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: _buildPlayerButton(4, '4'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),
              
              // Botão Iniciar
              ElevatedButton(
                onPressed: startGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF23395D),
                  padding: EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  '🎮 Iniciar Jogo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Tela do jogo
    final minutes = secondsElapsed ~/ 60;
    final seconds = secondsElapsed % 60;
    final timeString = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    // Calcular número de pares total baseado na dificuldade
    int totalPairs;
    switch (selectedDifficulty) {
      case 'facil':
        totalPairs = 6;
        break;
      case 'dificil':
        totalPairs = 15;
        break;
      default: // medio
        totalPairs = 10;
    }

    // Calcular tamanho da grade baseado no número de cartas
    int crossAxisCount;
    double emojiSize;
    double fontSize;
    
    if (cards.length <= 12) {
      crossAxisCount = 4; // 4x3 para fácil (melhor proporção)
      emojiSize = 48;
      fontSize = 12;
    } else if (cards.length <= 20) {
      crossAxisCount = 4; // 4x5 para médio
      emojiSize = 42;
      fontSize = 11;
    } else {
      crossAxisCount = 5; // 5x6 para difícil
      emojiSize = 36;
      fontSize = 10;
    }

    return Scaffold(
      backgroundColor: Color(0xFF101A2C),
      appBar: AppBar(
        title: Text(numPlayers > 1 
          ? 'Jogo da Memória - Jogador ${currentPlayer + 1}' 
          : 'Jogo da Memória'),
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
              child: numPlayers > 1 
                ? Column(
                    children: [
                      // Placar multiplayer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(numPlayers, (i) {
                          bool isActive = i == currentPlayer;
                          return Container(
                            padding: EdgeInsets.all(8),
                            decoration: isActive ? BoxDecoration(
                              border: Border.all(
                                color: Colors.amber,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ) : null,
                            child: Column(
                              children: [
                                Text(
                                  'J${i + 1}',
                                  style: TextStyle(
                                    color: isActive ? Colors.amber : Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${playerScores[i]}',
                                  style: TextStyle(
                                    color: isActive ? Colors.amber : Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                      Divider(color: Colors.white30, height: 24),
                      // Tempo e tentativas
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            children: [
                              Text('⏱️ ', style: TextStyle(fontSize: 20)),
                              Text(
                                timeString,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text('🎯 ', style: TextStyle(fontSize: 20)),
                              Text(
                                '$attempts',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text('✅ ', style: TextStyle(fontSize: 20)),
                              Text(
                                '$matches/$totalPairs',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  )
                : Row(
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
                            '$matches/$totalPairs',
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
            
            // Grid de cartas
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
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
                                    style: TextStyle(fontSize: emojiSize),
                                  ),
                                  SizedBox(height: 4),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: Text(
                                      card.name,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: fontSize,
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
                                size: emojiSize * 0.8,
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
