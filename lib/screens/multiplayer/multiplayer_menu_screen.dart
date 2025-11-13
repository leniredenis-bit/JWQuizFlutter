import 'package:flutter/material.dart';
import 'create_room_screen.dart';
import 'join_room_screen.dart';

/// Menu de seleção: Criar Sala ou Entrar em Sala
class MultiplayerMenuScreen extends StatelessWidget {
  const MultiplayerMenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF101A2C),
      appBar: AppBar(
        title: Text('Partida Online'),
        backgroundColor: Color(0xFF162447),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 40),
              
              // Ícone principal
              Icon(
                Icons.online_prediction,
                size: 80,
                color: Color(0xFF3A5A8C),
              ),
              
              SizedBox(height: 24),
              
              Text(
                'Modo Multiplayer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 12),
              
              Text(
                'Jogue com seus amigos em tempo real!',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 60),
              
              // Botão Criar Sala
              _buildMenuButton(
                context: context,
                icon: Icons.add_circle,
                title: 'Criar Sala',
                subtitle: 'Seja o anfitrião e convide amigos',
                gradient: LinearGradient(
                  colors: [Color(0xFF3A5A8C), Color(0xFF5A7AA8)],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateRoomScreen(),
                    ),
                  );
                },
              ),
              
              SizedBox(height: 20),
              
              // Botão Entrar em Sala
              _buildMenuButton(
                context: context,
                icon: Icons.login,
                title: 'Entrar em Sala',
                subtitle: 'Digite o código da sala',
                gradient: LinearGradient(
                  colors: [Color(0xFF5A8C3A), Color(0xFF7AA85A)],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JoinRoomScreen(),
                    ),
                  );
                },
              ),
              
              Spacer(),
              
              // Informações
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF162447),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.amber, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Como funciona?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    _buildInfoRow('• Até 8 jogadores por sala'),
                    _buildInfoRow('• Perguntas simultâneas'),
                    _buildInfoRow('• Pontuação por velocidade'),
                    _buildInfoRow('• Ranking em tempo real'),
                  ],
                ),
              ),
              
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 32, color: Colors.white),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(color: Colors.white70, fontSize: 14),
      ),
    );
  }
}
