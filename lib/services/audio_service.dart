import 'package:audioplayers/audioplayers.dart';
import 'dart:math';

/// Serviço centralizado para gerenciar música de fundo e efeitos sonoros
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  // Players separados para música e efeitos sonoros
  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _isMusicEnabled = true;
  bool _isSfxEnabled = true;
  String? _currentMusic;

  // Músicas disponíveis por tela
  static const Map<String, List<String>> _backgroundMusic = {
    'home': ['assets/audio/home.mp3', 'assets/audio/Life of Riley.mp3'],
    'quiz': ['assets/audio/quiz.mp3', 'assets/audio/quiz-home.mp3'],
    'memory': ['assets/audio/memory-game.mp3', 'assets/audio/memory-home.mp3'],
    'pie': ['assets/audio/Pixel Peeker Polka - faster.mp3'],
  };

  // Efeitos sonoros (vamos criar arquivos simples ou usar beeps)
  static const String _soundCardFlip = 'assets/audio/sfx/card_flip.mp3';
  static const String _soundMatch = 'assets/audio/sfx/match.mp3';
  static const String _soundMismatch = 'assets/audio/sfx/mismatch.mp3';
  static const String _soundCorrect = 'assets/audio/sfx/correct.mp3';
  static const String _soundWrong = 'assets/audio/sfx/wrong.mp3';
  static const String _soundClick = 'assets/audio/sfx/click.mp3';
  static const String _soundGameOver = 'assets/audio/sfx/game_over.mp3';
  static const String _soundVictory = 'assets/audio/sfx/victory.mp3';

  /// Inicializa o serviço de áudio
  Future<void> initialize() async {
    // Configura o player de música para loop
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.setVolume(0.4); // Volume mais baixo para música de fundo
    
    // Configura o player de efeitos sonoros
    await _sfxPlayer.setReleaseMode(ReleaseMode.stop);
    await _sfxPlayer.setVolume(0.7);
  }

  /// Toca música de fundo para uma tela específica (escolhe aleatoriamente)
  Future<void> playBackgroundMusic(String screen) async {
    if (!_isMusicEnabled) return;

    final musicList = _backgroundMusic[screen];
    if (musicList == null || musicList.isEmpty) return;

    // Escolhe música aleatória da lista
    final randomMusic = musicList[Random().nextInt(musicList.length)];
    
    // Se já está tocando a mesma música, não reinicia
    if (_currentMusic == randomMusic) return;

    _currentMusic = randomMusic;
    
    try {
      await _musicPlayer.stop();
      await _musicPlayer.play(AssetSource(randomMusic.replaceFirst('assets/', '')));
    } catch (e) {
      print('Erro ao tocar música: $e');
    }
  }

  /// Para a música de fundo
  Future<void> stopBackgroundMusic() async {
    await _musicPlayer.stop();
    _currentMusic = null;
  }

  /// Pausa a música de fundo
  Future<void> pauseBackgroundMusic() async {
    await _musicPlayer.pause();
  }

  /// Retoma a música de fundo
  Future<void> resumeBackgroundMusic() async {
    if (!_isMusicEnabled) return;
    await _musicPlayer.resume();
  }

  // ==================== EFEITOS SONOROS ====================

  /// Toca efeito sonoro genérico
  Future<void> _playSfx(String assetPath) async {
    if (!_isSfxEnabled) return;
    
    try {
      await _sfxPlayer.stop(); // Para o som anterior
      await _sfxPlayer.play(AssetSource(assetPath.replaceFirst('assets/', '')));
    } catch (e) {
      // Se o arquivo não existe, ignora silenciosamente
      print('SFX não encontrado: $assetPath');
    }
  }

  /// Som ao virar carta no jogo da memória
  Future<void> playCardFlip() async {
    await _playSfx(_soundCardFlip);
  }

  /// Som ao fazer par correto no jogo da memória
  Future<void> playMatch() async {
    await _playSfx(_soundMatch);
  }

  /// Som ao errar par no jogo da memória
  Future<void> playMismatch() async {
    await _playSfx(_soundMismatch);
  }

  /// Som ao acertar resposta no quiz
  Future<void> playCorrectAnswer() async {
    await _playSfx(_soundCorrect);
  }

  /// Som ao errar resposta no quiz (buzina)
  Future<void> playWrongAnswer() async {
    await _playSfx(_soundWrong);
  }

  /// Som ao clicar em botão
  Future<void> playClick() async {
    await _playSfx(_soundClick);
  }

  /// Som de game over
  Future<void> playGameOver() async {
    await _playSfx(_soundGameOver);
  }

  /// Som de vitória
  Future<void> playVictory() async {
    await _playSfx(_soundVictory);
  }

  // ==================== CONTROLES ====================

  /// Ativa/desativa música de fundo
  void setMusicEnabled(bool enabled) {
    _isMusicEnabled = enabled;
    if (!enabled) {
      stopBackgroundMusic();
    }
  }

  /// Ativa/desativa efeitos sonoros
  void setSfxEnabled(bool enabled) {
    _isSfxEnabled = enabled;
  }

  /// Verifica se música está habilitada
  bool get isMusicEnabled => _isMusicEnabled;

  /// Verifica se efeitos sonoros estão habilitados
  bool get isSfxEnabled => _isSfxEnabled;

  /// Ajusta volume da música (0.0 a 1.0)
  Future<void> setMusicVolume(double volume) async {
    await _musicPlayer.setVolume(volume.clamp(0.0, 1.0));
  }

  /// Ajusta volume dos efeitos sonoros (0.0 a 1.0)
  Future<void> setSfxVolume(double volume) async {
    await _sfxPlayer.setVolume(volume.clamp(0.0, 1.0));
  }

  /// Libera recursos
  Future<void> dispose() async {
    await _musicPlayer.dispose();
    await _sfxPlayer.dispose();
  }
}
