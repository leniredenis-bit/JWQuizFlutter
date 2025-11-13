import 'package:flutter/material.dart';
import 'dart:async';
import '../models/question.dart';
import '../models/stats_service.dart';
import '../utils/timer_calculator.dart';

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
  int timeRemaining = 30;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    // Calcular tempo dinamicamente baseado na pergunta atual
    final currentQuestion = widget.questions[currentQuestionIndex];
    timeRemaining = TimerCalculator.calculateQuizTime(currentQuestion);
    
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (timeRemaining > 0) {
        setState(() {
          timeRemaining--;
        });
      } else {
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
      setState(() {
        score += calculatePoints();
        correctAnswersCount++;
      });
    }

    Future.delayed(Duration(seconds: 2), () {
      nextQuestion();
    });
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
    if (currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedAnswer = null;
        showResult = false;
      });
      startTimer();
    } else {
      // Quiz finalizado
      _timer?.cancel();
      showQuizResult();
    }
  }

  void showQuizResult() async {
    // Salvar estatísticas
    await StatsService.saveQuizStats(
      score: score,
      questionsAnswered: widget.questions.length,
      correctAnswers: correctAnswersCount,
    );
    
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF162447),
        title: Text(
          '🎉 Quiz Finalizado!',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pontuação Final',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              '$score',
              style: TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Você acertou ${widget.questions.where((q) => selectedAnswer == q.respostaCorreta).length} de ${widget.questions.length} perguntas!',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text('Voltar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[currentQuestionIndex];

    return Scaffold(
      backgroundColor: Color(0xFF101A2C),
      appBar: AppBar(
        title: Text('Quiz - Pergunta ${currentQuestionIndex + 1}/${widget.questions.length}'),
        backgroundColor: Color(0xFF162447),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                '⭐ $score',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Timer e Dificuldade
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(0xFF23395D),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '⏱️ ${timeRemaining}s',
                    style: TextStyle(
                      color: timeRemaining <= 10 ? Colors.red : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(
                  label: Text(question.getDificuldadeTexto()),
                  backgroundColor: Color(0xFF23395D),
                  labelStyle: TextStyle(color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 24),
            
            // ID e Pergunta
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF162447),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pergunta #${question.id}',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  SizedBox(height: 8),
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
            
            // Referência Bíblica (aparece após responder)
            if (showResult && question.referencia != null && question.referencia!.isNotEmpty)
              Container(
                padding: EdgeInsets.all(12),
                margin: EdgeInsets.only(top: 8, bottom: 8),
                decoration: BoxDecoration(
                  color: Color(0xFF162447),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.book, color: Colors.white70, size: 16),
                        SizedBox(width: 8),
                        Text(
                          question.referencia!,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    if (question.textoBiblico != null && question.textoBiblico!.isNotEmpty) ...[
                      SizedBox(height: 8),
                      Text(
                        question.textoBiblico!,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
