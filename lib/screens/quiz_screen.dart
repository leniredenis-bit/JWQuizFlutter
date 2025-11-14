import 'package:flutter/material.dart';
import 'dart:async';
import '../models/question.dart';
import '../models/stats_service.dart';
import '../utils/timer_calculator.dart';
import '../services/audio_service.dart';

class QuizScreen extends StatefulWidget {
  final List<Question> questions;

  const QuizScreen({Key? key, required this.questions}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestionIndex = 0;
  int score = 0;
  int correctAnswersCount = 0;
  int? selectedAnswer;
  bool showResult = false;
  Timer? _timer;
  Timer? _nextQuestionTimer;
  int timeRemaining = 30;
  int autoAdvanceTime = 10;
  bool showExplanation = false;

  @override
  void initState() {
    super.initState();
    // Inicia música de fundo do quiz
    AudioService().playBackgroundMusic('quiz');
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _nextQuestionTimer?.cancel();
    AudioService().stopBackgroundMusic();
    super.dispose();
  }

  void startTimer() {
    // Calcular tempo dinamicamente baseado na pergunta atual
    final currentQuestion = widget.questions[currentQuestionIndex];
    timeRemaining = TimerCalculator.calculateQuizTime(currentQuestion);
    
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (timeRemaining > 0 && !showExplanation) {
        setState(() {
          timeRemaining--;
        });
      } else if (timeRemaining <= 0 && !showExplanation && selectedAnswer == null) {
        // Tempo esgotado sem resposta - marcar a resposta certa
        setState(() {
          selectedAnswer = widget.questions[currentQuestionIndex].respostaCorreta;
          showResult = true;
        });
        _timer?.cancel();
        startAutoAdvanceTimer();
      }
    });
  }

  void startAutoAdvanceTimer() {
    autoAdvanceTime = 10;
    _nextQuestionTimer?.cancel();
    _nextQuestionTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!showExplanation && autoAdvanceTime > 0) {
        setState(() {
          autoAdvanceTime--;
        });
      } else if (autoAdvanceTime <= 0) {
        nextQuestion();
      }
    });
  }

  void selectAnswer(int index) {
    if (selectedAnswer != null) return;

    setState(() {
      selectedAnswer = index;
      showResult = true;
    });

    _timer?.cancel();

    if (index == widget.questions[currentQuestionIndex].respostaCorreta) {
      // Som de acerto!
      AudioService().playCorrectAnswer();
      setState(() {
        score += calculatePoints();
        correctAnswersCount++;
      });
    } else {
      // Som de erro (buzina)
      AudioService().playWrongAnswer();
    }

    // Inicia timer de auto-avanço (10s)
    startAutoAdvanceTimer();
  }

  int calculatePoints() {
    // Pontuação baseada no tempo restante e dificuldade
    final question = widget.questions[currentQuestionIndex];
    int basePoints = 10;
    
    if (question.dificuldade == 3) { // Difícil
      basePoints = 20;
    } else if (question.dificuldade == 2) { // Médio
      basePoints = 15;
    }
    
    int timeBonus = (timeRemaining * 0.5).round();
    return basePoints + timeBonus;
  }

  void nextQuestion() {
    _nextQuestionTimer?.cancel();
    
    if (currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedAnswer = null;
        showResult = false;
        showExplanation = false;
      });
      startTimer();
    } else {
      // Quiz finalizado
      _timer?.cancel();
      showQuizResult();
    }
  }

  void toggleExplanation() {
    setState(() {
      showExplanation = !showExplanation;
    });
  }

  void showQuizResult() async {
    // Salvar estatísticas
    await StatsService.saveQuizStats(
      score: score,
      questionsAnswered: widget.questions.length,
      correctAnswers: correctAnswersCount,
    );
    
    if (!mounted) return;
    
    // Calcular porcentagem de acertos
    final percentage = (correctAnswersCount / widget.questions.length * 100).round();
    
    // Escolher emoji e mensagem baseado no desempenho
    String emoji;
    String message;
    Color celebrationColor;
    
    if (percentage >= 90) {
      emoji = '🏆';
      message = 'Excelente!';
      celebrationColor = Colors.amber;
    } else if (percentage >= 70) {
      emoji = '🎉';
      message = 'Muito Bem!';
      celebrationColor = Colors.green;
    } else if (percentage >= 50) {
      emoji = '👏';
      message = 'Bom Trabalho!';
      celebrationColor = Colors.blue;
    } else {
      emoji = '💪';
      message = 'Continue Praticando!';
      celebrationColor = Colors.orange;
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _AnimatedResultDialog(
        emoji: emoji,
        message: message,
        score: score,
        correctAnswers: correctAnswersCount,
        totalQuestions: widget.questions.length,
        celebrationColor: celebrationColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[currentQuestionIndex];
    final hasExplanation = (question.referencia != null && question.referencia!.isNotEmpty) ||
                           (question.textoBiblico != null && question.textoBiblico!.isNotEmpty);

    return Scaffold(
      backgroundColor: Color(0xFF101A2C),
      appBar: AppBar(
        title: Text('Quiz - ${currentQuestionIndex + 1}/${widget.questions.length}', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF23395D), // Cor mais clara para legibilidade
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                '⭐ $score',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 8),
                
                // Balão da Pergunta com Timer no canto superior direito
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Color(0xFF162447),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Linha com ID, Dificuldade e Timer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // ID e Dificuldade
                          Row(
                            children: [
                              Text(
                                'Pergunta #${question.id}',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                question.getDificuldadeTexto(),
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          // Timer (só aparece se não está no modo estudo)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Color(0xFF23395D),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '⏱️ ${timeRemaining}s',
                              style: TextStyle(
                                color: timeRemaining <= 10 ? Colors.redAccent : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        question.pergunta,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
            
            // Alternativas
            Expanded(
              child: ListView.builder(
                itemCount: question.opcoes.length,
                itemBuilder: (context, index) {
                  final isSelected = selectedAnswer == index;
                  final isCorrect = index == question.respostaCorreta;
                  
                  Color buttonColor = Color(0xFF23395D);
                  if (showResult) {
                    if (isCorrect) {
                      buttonColor = Colors.green.shade700;
                    } else if (isSelected && !isCorrect) {
                      buttonColor = Colors.red.shade700;
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: EdgeInsets.all(16),
                        elevation: isSelected ? 4 : 2,
                      ),
                      onPressed: () => selectAnswer(index),
                      child: Text(
                        question.opcoes[index],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Botões de Explicação e Próxima (aparecem após responder)
            if (showResult)
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 8),
                child: Row(
                  children: [
                    // Botão Explicação
                    if (hasExplanation)
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF23395D),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: toggleExplanation,
                          child: Text(
                            '📖 Explicação',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    if (hasExplanation) SizedBox(width: 12),
                    // Botão Próxima
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: nextQuestion,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Próxima',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            // Timer de auto-avanço
            if (showResult && !showExplanation)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Center(
                  child: Text(
                    'Próxima pergunta em ${autoAdvanceTime}s...',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      
      // Balão de Explicação (Modal)
      if (showExplanation && hasExplanation)
        GestureDetector(
          onTap: toggleExplanation,
          child: Container(
            color: Colors.black54,
            child: Center(
              child: GestureDetector(
                onTap: () {}, // Não fecha ao clicar no balão
                child: Container(
                  margin: EdgeInsets.all(24),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Color(0xFF162447),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24, width: 2),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Cabeçalho com X para fechar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '📖 Explicação',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.white),
                            onPressed: toggleExplanation,
                          ),
                        ],
                      ),
                      Divider(color: Colors.white24),
                      SizedBox(height: 12),
                      
                      // Referência
                      if (question.referencia != null && question.referencia!.isNotEmpty)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.book, color: Colors.white70, size: 18),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                question.referencia!,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      
                      // Texto Bíblico
                      if (question.textoBiblico != null && question.textoBiblico!.isNotEmpty) ...[
                        SizedBox(height: 16),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Color(0xFF23395D),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            question.textoBiblico!,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                              fontStyle: FontStyle.italic,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                      
                      SizedBox(height: 20),
                      
                      // Botão Próxima (dentro do balão)
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          onPressed: () {
                            toggleExplanation();
                            nextQuestion();
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Próxima',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
    ],
  ),
    );
  }
}

// Widget de diálogo animado para resultados
class _AnimatedResultDialog extends StatefulWidget {
  final String emoji;
  final String message;
  final int score;
  final int correctAnswers;
  final int totalQuestions;
  final Color celebrationColor;

  const _AnimatedResultDialog({
    required this.emoji,
    required this.message,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.celebrationColor,
  });

  @override
  State<_AnimatedResultDialog> createState() => _AnimatedResultDialogState();
}

class _AnimatedResultDialogState extends State<_AnimatedResultDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotateController;
  late AnimationController _slideController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Animação de escala (emoji pulando)
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Animação de rotação (emoji girando)
    _rotateController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _rotateAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.easeInOut),
    );

    // Animação de slide (conteúdo deslizando)
    _slideController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    // Iniciar animações
    _scaleController.forward();
    Future.delayed(Duration(milliseconds: 200), () {
      if (mounted) _rotateController.forward();
    });
    Future.delayed(Duration(milliseconds: 400), () {
      if (mounted) _slideController.forward();
    });

    // Loop de rotação sutil
    _rotateController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _rotateController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _rotateController.forward();
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotateController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (widget.correctAnswers / widget.totalQuestions * 100).round();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Color(0xFF162447),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: widget.celebrationColor.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Emoji animado
            ScaleTransition(
              scale: _scaleAnimation,
              child: RotationTransition(
                turns: _rotateAnimation,
                child: Text(
                  widget.emoji,
                  style: TextStyle(fontSize: 80),
                ),
              ),
            ),
            SizedBox(height: 16),

            // Conteúdo deslizante
            SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  // Mensagem
                  Text(
                    widget.message,
                    style: TextStyle(
                      color: widget.celebrationColor,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Quiz Finalizado!',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 24),

                  // Pontuação
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFF23395D),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Pontuação',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 8),
                        TweenAnimationBuilder<int>(
                          tween: IntTween(begin: 0, end: widget.score),
                          duration: Duration(milliseconds: 1500),
                          builder: (context, value, child) {
                            return Text(
                              '$value',
                              style: TextStyle(
                                color: widget.celebrationColor,
                                fontSize: 56,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),

                  // Estatísticas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat('Acertos', '${widget.correctAnswers}/${widget.totalQuestions}', Colors.green),
                      _buildStat('Aproveitamento', '$percentage%', widget.celebrationColor),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Botão
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.celebrationColor,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Voltar ao Menu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

