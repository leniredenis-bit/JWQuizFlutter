import 'package:flutter/material.dart';
import '../models/quiz_service.dart';
import '../models/question.dart';
import 'quiz_screen.dart';
import 'memory_game_screen.dart';
import 'stats_screen.dart';
import 'multiplayer/multiplayer_menu_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> difficulties = ['Fácil', 'Médio', 'Difícil'];
  List<String> allTags = [];
  List<String> displayedTags = [];
  bool isLoadingTags = true;
  bool showAllTags = false;
  final int initialTagsCount = 7;
  final List<Map<String, String>> modes = [
    {'emoji': '🧠', 'title': 'Quiz Clássico', 'desc': 'Responda perguntas e marque pontos!'},
    {'emoji': '🌐', 'title': 'Partida Online', 'desc': 'Jogue com amigos em tempo real!'},
    {'emoji': '🕹️', 'title': 'Jogo da Memória', 'desc': 'Encontre pares bíblicos!'},
    {'emoji': '📊', 'title': 'Estatísticas', 'desc': 'Veja seu desempenho e conquistas!'},
  ];

  String? selectedDifficulty;
  String? selectedTag;

  @override
  void initState() {
    super.initState();
    loadTags();
  }

  Future<void> loadTags() async {
    try {
      final popularTags = await QuizService.getPopularTags();
      setState(() {
        allTags = popularTags.map((entry) => entry.key).toList();
        displayedTags = allTags.take(initialTagsCount).toList();
        isLoadingTags = false;
      });
    } catch (e) {
      setState(() {
        isLoadingTags = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar categorias: $e')),
        );
      }
    }
  }

  void toggleShowAllTags() {
    setState(() {
      showAllTags = !showAllTags;
      displayedTags = showAllTags ? allTags : allTags.take(initialTagsCount).toList();
    });
  }

  void startQuiz() async {
    try {
      List<Question> questions = await QuizService.loadQuestions();
      
      // Aplicar filtros
      if (selectedDifficulty != null) {
        // Converter dificuldade de String para int (1=Fácil, 2=Médio, 3=Difícil)
        int difficultyLevel = difficulties.indexOf(selectedDifficulty!) + 1;
        questions = QuizService.filterByDifficulty(questions, difficultyLevel);
      }
      
      if (selectedTag != null) {
        questions = QuizService.filterByTag(questions, selectedTag!);
      }
      
      // Pegar 10 perguntas aleatórias
      questions = QuizService.getRandomQuestions(questions, 10);
      
      if (questions.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nenhuma pergunta encontrada com esses filtros!')),
        );
        return;
      }
      
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizScreen(questions: questions),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar perguntas: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF101A2C),
      appBar: AppBar(
        title: Text('JW Quiz'),
        backgroundColor: Color(0xFF162447),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filtros de dificuldade
            Text('Dificuldade', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Row(
              children: difficulties.map((dif) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(dif),
                  selected: selectedDifficulty == dif,
                  backgroundColor: Color(0xFF23395D),
                  selectedColor: Color(0xFF3A5A8C),
                  labelStyle: TextStyle(color: Colors.white),
                  onSelected: (selected) {
                    setState(() {
                      selectedDifficulty = selected ? dif : null;
                    });
                  },
                ),
              )).toList(),
            ),
            SizedBox(height: 16),
            // Tags de categorias
            Text('Categorias', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            isLoadingTags 
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(color: Color(0xFF3A5A8C)),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: displayedTags.map((tag) => FilterChip(
                        label: Text(tag),
                        selected: selectedTag == tag,
                        backgroundColor: Color(0xFF23395D),
                        selectedColor: Color(0xFF3A5A8C),
                        labelStyle: TextStyle(color: Colors.white),
                        onSelected: (selected) {
                          setState(() {
                            selectedTag = selected ? tag : null;
                          });
                        },
                      )).toList(),
                    ),
                    if (allTags.length > initialTagsCount)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: TextButton.icon(
                          onPressed: toggleShowAllTags,
                          icon: Icon(
                            showAllTags ? Icons.expand_less : Icons.expand_more,
                            color: Color(0xFF3A5A8C),
                          ),
                          label: Text(
                            showAllTags ? 'Ver menos' : 'Ver mais (${allTags.length - initialTagsCount}+)',
                            style: TextStyle(color: Color(0xFF3A5A8C)),
                          ),
                        ),
                      ),
                  ],
                ),
            SizedBox(height: 24),
            // Botões compactos de modo de jogo
            ...modes.asMap().entries.map((entry) {
              final index = entry.key;
              final mode = entry.value;
              
              VoidCallback? onPressed;
              if (index == 0) {
                onPressed = startQuiz;
              } else if (index == 1) {
                onPressed = () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MultiplayerMenuScreen()),
                  );
                };
              } else if (index == 2) {
                onPressed = () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MemoryGameScreen()),
                  );
                };
              } else if (index == 3) {
                onPressed = () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => StatsScreen()),
                  );
                };
              }
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF23395D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    elevation: 2,
                  ),
                  onPressed: onPressed,
                  child: Row(
                    children: [
                      Text(mode['emoji']!, style: TextStyle(fontSize: 28)),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(mode['title']!, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(mode['desc']!, style: TextStyle(color: Colors.white70, fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}