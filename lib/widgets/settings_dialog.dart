import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/stats_screen.dart';
import '../services/audio_service.dart';
import 'dart:html' as html;

class SettingsDialog extends StatefulWidget {
  final Function(bool) onThemeChanged;
  
  const SettingsDialog({Key? key, required this.onThemeChanged}) : super(key: key);

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  final AudioService _audioService = AudioService();
  double _musicVolume = 0.5;
  double _sfxVolume = 0.5;
  bool _isDarkTheme = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _musicVolume = prefs.getDouble('musicVolume') ?? 0.5;
      _sfxVolume = prefs.getDouble('sfxVolume') ?? 0.5;
      _isDarkTheme = prefs.getBool('darkTheme') ?? true;
    });
    
    // Apply current volumes
    await _audioService.setMusicVolume(_musicVolume);
    await _audioService.setSfxVolume(_sfxVolume);
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('musicVolume', _musicVolume);
    await prefs.setDouble('sfxVolume', _sfxVolume);
    await prefs.setBool('darkTheme', _isDarkTheme);
  }

  void _openLegalPage() {
    // Open the legal/credits page in a new tab
    html.window.open('https://github.com/leniredenis-bit/JWQuizFlutter', '_blank');
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: _isDarkTheme ? Color(0xFF162447) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: BoxConstraints(maxWidth: 400, maxHeight: 600),
        padding: EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.settings,
                    color: _isDarkTheme ? Colors.white : Colors.black87,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Configurações',
                    style: TextStyle(
                      color: _isDarkTheme ? Colors.white : Colors.black87,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: _isDarkTheme ? Colors.white70 : Colors.black54,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              
              Divider(color: _isDarkTheme ? Colors.white24 : Colors.black12),
              SizedBox(height: 16),

              // Theme Toggle
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isDarkTheme ? Color(0xFF1F2D44) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isDarkTheme ? Icons.dark_mode : Icons.light_mode,
                      color: _isDarkTheme ? Colors.amber : Colors.orange,
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tema Escuro',
                        style: TextStyle(
                          color: _isDarkTheme ? Colors.white : Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Switch(
                      value: _isDarkTheme,
                      onChanged: (value) {
                        setState(() {
                          _isDarkTheme = value;
                        });
                        _saveSettings();
                        widget.onThemeChanged(value);
                      },
                      activeColor: Color(0xFF4A90E2),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Music Volume
              Text(
                '🎵 Volume da Música',
                style: TextStyle(
                  color: _isDarkTheme ? Colors.white : Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.volume_down,
                    color: _isDarkTheme ? Colors.white70 : Colors.black54,
                  ),
                  Expanded(
                    child: Slider(
                      value: _musicVolume,
                      min: 0.0,
                      max: 1.0,
                      divisions: 10,
                      label: '${(_musicVolume * 100).round()}%',
                      activeColor: Color(0xFF4A90E2),
                      onChanged: (value) async {
                        setState(() {
                          _musicVolume = value;
                        });
                        await _audioService.setMusicVolume(value);
                        await _saveSettings();
                      },
                    ),
                  ),
                  Icon(
                    Icons.volume_up,
                    color: _isDarkTheme ? Colors.white70 : Colors.black54,
                  ),
                ],
              ),

              SizedBox(height: 12),

              // SFX Volume
              Text(
                '🔊 Volume dos Efeitos',
                style: TextStyle(
                  color: _isDarkTheme ? Colors.white : Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.volume_down,
                    color: _isDarkTheme ? Colors.white70 : Colors.black54,
                  ),
                  Expanded(
                    child: Slider(
                      value: _sfxVolume,
                      min: 0.0,
                      max: 1.0,
                      divisions: 10,
                      label: '${(_sfxVolume * 100).round()}%',
                      activeColor: Color(0xFFE24A4A),
                      onChanged: (value) async {
                        setState(() {
                          _sfxVolume = value;
                        });
                        await _audioService.setSfxVolume(value);
                        await _saveSettings();
                        // Play test sound
                        _audioService.playClick();
                      },
                    ),
                  ),
                  Icon(
                    Icons.volume_up,
                    color: _isDarkTheme ? Colors.white70 : Colors.black54,
                  ),
                ],
              ),

              SizedBox(height: 24),
              Divider(color: _isDarkTheme ? Colors.white24 : Colors.black12),
              SizedBox(height: 16),

              // Statistics Button
              _buildMenuButton(
                icon: Icons.bar_chart,
                title: 'Estatísticas',
                subtitle: 'Veja seu desempenho',
                color: Color(0xFF50C878),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => StatsScreen()),
                  );
                },
              ),

              SizedBox(height: 12),

              // Legal Button
              _buildMenuButton(
                icon: Icons.info_outline,
                title: 'Legal',
                subtitle: 'Créditos e licenças',
                color: Color(0xFF9B59B6),
                onTap: _openLegalPage,
              ),

              SizedBox(height: 24),

              // Version Info
              Center(
                child: Text(
                  'JW Quiz v1.0.0',
                  style: TextStyle(
                    color: _isDarkTheme ? Colors.white38 : Colors.black38,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _isDarkTheme ? Color(0xFF1F2D44) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: _isDarkTheme ? Colors.white : Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: _isDarkTheme ? Colors.white60 : Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: _isDarkTheme ? Colors.white38 : Colors.black38,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
