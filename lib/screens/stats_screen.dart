import 'package:flutter/material.dart';
import '../models/stats_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  // Dados de exemplo - posteriormente serão carregados do SharedPreferences
  int totalQuizzes = 0;
  int totalScore = 0;
  int totalQuestions = 0;
  int correctAnswers = 0;
  int bestScore = 0;
  int memoryGamesPlayed = 0;
  int bestMemoryTime = 0;

  double get accuracyRate {
    if (totalQuestions == 0) return 0;
    return (correctAnswers / totalQuestions) * 100;
  }

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  Future<void> loadStats() async {
    final stats = await StatsService.loadAllStats();
    setState(() {
      totalQuizzes = stats['totalQuizzes']!;
      totalScore = stats['totalScore']!;
      totalQuestions = stats['totalQuestions']!;
      correctAnswers = stats['correctAnswers']!;
      bestScore = stats['bestScore']!;
      memoryGamesPlayed = stats['memoryGamesPlayed']!;
      bestMemoryTime = stats['bestMemoryTime']!;
    });
  }

  Widget _buildStatCard({
    required String emoji,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF162447),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: TextStyle(fontSize: 36)),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar({
    required String label,
    required double percentage,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Color(0xFF23395D),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 12,
          ),
        ),
        SizedBox(height: 4),
        Text(
          '${percentage.toStringAsFixed(1)}%',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementBadge({
    required String emoji,
    required String title,
    required String description,
    required bool unlocked,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: unlocked ? Color(0xFF23395D) : Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: unlocked ? Color(0xFF3A5A8C) : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Text(
            emoji,
            style: TextStyle(
              fontSize: 32,
              color: unlocked ? null : Colors.white24,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: unlocked ? Colors.white : Colors.white38,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    color: unlocked ? Colors.white70 : Colors.white24,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (unlocked)
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 20,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF101A2C),
      appBar: AppBar(
        title: Text('Estatísticas'),
        backgroundColor: Color(0xFF162447),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seção de estatísticas principais
            Text(
              '📊 Desempenho Geral',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: [
                _buildStatCard(
                  emoji: '🧠',
                  title: 'Quizzes\nRealizados',
                  value: '$totalQuizzes',
                ),
                _buildStatCard(
                  emoji: '⭐',
                  title: 'Pontuação\nTotal',
                  value: '$totalScore',
                  valueColor: Colors.amber,
                ),
                _buildStatCard(
                  emoji: '🏆',
                  title: 'Melhor\nScore',
                  value: '$bestScore',
                  valueColor: Colors.orange,
                ),
                _buildStatCard(
                  emoji: '✅',
                  title: 'Taxa de\nAcerto',
                  value: '${accuracyRate.toStringAsFixed(1)}%',
                  valueColor: Colors.green,
                ),
              ],
            ),
            
            SizedBox(height: 24),
            
            // Seção de progresso
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF162447),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📈 Progresso',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildProgressBar(
                    label: 'Taxa de Acerto',
                    percentage: accuracyRate,
                    color: Colors.green,
                  ),
                  SizedBox(height: 16),
                  _buildProgressBar(
                    label: 'Questões Respondidas',
                    percentage: (totalQuestions / 1180) * 100,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // Estatísticas do Jogo da Memória
            Text(
              '🕹️ Jogo da Memória',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
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
                      Text('🎮', style: TextStyle(fontSize: 28)),
                      SizedBox(height: 8),
                      Text(
                        '$memoryGamesPlayed',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Jogos',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text('⏱️', style: TextStyle(fontSize: 28)),
                      SizedBox(height: 8),
                      Text(
                        bestMemoryTime > 0 
                            ? '${bestMemoryTime ~/ 60}:${(bestMemoryTime % 60).toString().padLeft(2, '0')}'
                            : '--:--',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Melhor Tempo',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // Seção de conquistas
            Text(
              '🏅 Conquistas',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            
            _buildAchievementBadge(
              emoji: '🎓',
              title: 'Primeiro Quiz',
              description: 'Complete seu primeiro quiz',
              unlocked: totalQuizzes >= 1,
            ),
            SizedBox(height: 8),
            _buildAchievementBadge(
              emoji: '🔥',
              title: 'Estudioso',
              description: 'Complete 10 quizzes',
              unlocked: totalQuizzes >= 10,
            ),
            SizedBox(height: 8),
            _buildAchievementBadge(
              emoji: '💯',
              title: 'Perfeito',
              description: 'Acerte 10 perguntas seguidas',
              unlocked: false, // Implementar lógica
            ),
            SizedBox(height: 8),
            _buildAchievementBadge(
              emoji: '⚡',
              title: 'Rápido como Raio',
              description: 'Complete um quiz em menos de 2 minutos',
              unlocked: false, // Implementar lógica
            ),
            SizedBox(height: 8),
            _buildAchievementBadge(
              emoji: '🧠',
              title: 'Mestre Bíblico',
              description: 'Alcance 1000 pontos totais',
              unlocked: totalScore >= 1000,
            ),
          ],
        ),
      ),
    );
  }
}
