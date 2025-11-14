# 📖 JW Quiz Flutter

> Quiz Bíblico interativo desenvolvido em Flutter com múltiplos modos de jogo, minigames educativos e sistema multiplayer.

![Flutter](https://img.shields.io/badge/Flutter-3.35.3-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-blue?logo=dart)
![License](https://img.shields.io/badge/license-MIT-green)

## 🎯 Sobre o Projeto

**JW Quiz Flutter** é um aplicativo educativo de perguntas e respostas sobre temas bíblicos, oferecendo uma experiência interativa e divertida para aprender mais sobre a Bíblia. O app conta com:

- 🧠 **Quiz Clássico** com sistema de pontuação e timer dinâmico
- 🌐 **Modo Multiplayer** para até 100 jogadores simultâneos
- 🎮 **7 Minigames** educativos (Jogo da Velha, Forca, Memória, etc.)
- 📊 **Sistema de Estatísticas** e conquistas
- 🎵 **Músicas de fundo** e efeitos sonoros
- 🎨 **Interface moderna** com temas personalizáveis

---

## ✨ Funcionalidades Principais

### 📚 Quiz Clássico
- **Banco de perguntas** extenso com referências bíblicas
- **Filtros** por dificuldade (Fácil, Médio, Difícil) e categorias (Gênesis, Êxodo, Profetas, etc.)
- **Timer dinâmico** que se ajusta ao tamanho da pergunta
- **Sistema de pontuação** com bônus por tempo
- **Feedback visual** imediato (verde = correto, vermelho = errado)

### 🌐 Modo Multiplayer
- **Criar ou entrar em salas** com código de 6 dígitos
- **Suporte para até 100 jogadores** por sala
- **Validação de profanidade** com sugestões de apelidos alternativos
- **Sincronização em tempo real** entre todos os jogadores
- **Sistema de ranking** com pódio (🥇🥈🥉)
- **Controles do anfitrião**: iniciar partida, remover jogadores, encerrar sala

### 🎮 7 Minigames Educativos

1. **🎯 Jogo da Velha**
   - 2 jogadores ou vs IA (Fácil/Impossível com Minimax)
   - Placar persistente
   
2. **🔤 Jogo da Forca**
   - 20 palavras bíblicas
   - Teclado A-Z interativo
   - Visual do boneco

3. **🧠 Sequência Rápida** (Simon Says)
   - Memorize padrões de cores
   - Níveis progressivos
   - Tracking de recorde

4. **🧩 Labirinto**
   - Navegação com setas do teclado ou botões
   - Grade 10x10
   - Contador de movimentos

5. **🔍 Caça-Palavras**
   - Grade 12x12 com 10 palavras bíblicas
   - Drag-to-select
   - Direções: horizontal, vertical, diagonal

6. **🧩 Quebra-Cabeça**
   - Puzzle deslizante 3x3 (8 peças)
   - Embaralhamento válido garantido
   - Contador de movimentos

7. **🕹️ Jogo da Memória**
   - Pares de cartas com temas bíblicos
   - Animações de flip
   - Sistema de pontuação

### 🎵 Sistema de Áudio
- **Músicas de fundo** aleatórias por tela (Home, Quiz, Memory Game, etc.)
- **Efeitos sonoros** para interações (acertos, erros, cliques, vitórias)
- **Controles de volume** e liga/desliga global

### 📊 Estatísticas e Conquistas
- Total de quizzes completados
- Taxa de acertos geral
- Melhor pontuação
- Histórico de partidas
- Sistema de achievements (em desenvolvimento)

---

## 🚀 Como Executar

### Pré-requisitos

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (versão 3.35.3 ou superior)
- [Dart SDK](https://dart.dev/get-dart) (incluído no Flutter)
- Android Studio (para emulador Android) ou Chrome (para web)

### Instalação

```bash
# Clone o repositório
git clone https://github.com/leniredenis-bit/JWQuizFlutter.git
cd jw_quiz_flutter

# Instale as dependências
flutter pub get

# Execute no Chrome (Web)
flutter run -d chrome

# Ou execute no Android
flutter run -d <device_id>
```

### Build para Produção

```bash
# Web
flutter build web

# Android APK
flutter build apk --release

# iOS (requer macOS)
flutter build ios --release
```

---

## 📁 Estrutura do Projeto

```
lib/
├── main.dart                    # Ponto de entrada do app
├── models/                      # Modelos de dados
│   ├── question.dart            # Modelo de pergunta
│   ├── quiz_service.dart        # Serviço de quiz
│   ├── multiplayer/             # Modelos multiplayer
│   │   ├── player.dart
│   │   ├── room.dart
│   │   └── game_state.dart
├── screens/                     # Telas do app
│   ├── welcome_screen.dart      # Tela de boas-vindas
│   ├── home_screen.dart         # Menu principal
│   ├── quiz_screen.dart         # Quiz clássico
│   ├── memory_game_screen.dart  # Jogo da memória
│   ├── stats_screen.dart        # Estatísticas
│   ├── minigames/               # Minigames
│   │   ├── tic_tac_toe_game.dart
│   │   ├── hangman_game.dart
│   │   ├── sequence_game.dart
│   │   ├── maze_game.dart
│   │   ├── word_search_game.dart
│   │   └── puzzle_game.dart
│   └── multiplayer/             # Telas multiplayer
│       ├── multiplayer_menu_screen.dart
│       ├── create_room_screen.dart
│       ├── join_room_screen.dart
│       ├── lobby_screen.dart
│       ├── multiplayer_quiz_screen.dart
│       ├── round_result_screen.dart
│       └── final_result_screen.dart
├── services/                    # Serviços
│   ├── audio_service.dart       # Gerenciamento de áudio
│   └── multiplayer/
│       ├── mock_multiplayer_service.dart
│       └── profanity_filter.dart
└── utils/                       # Utilitários
    └── timer_calculator.dart    # Cálculo de timer dinâmico

assets/
├── audio/                       # Músicas e efeitos sonoros
│   ├── home.mp3
│   ├── quiz.mp3
│   ├── memory-game.mp3
│   └── sfx/                     # Efeitos sonoros (opcional)
└── data/
    └── perguntas_atualizado.json  # Banco de perguntas (854 KB)
```

---

## 🛠️ Tecnologias Utilizadas

- **[Flutter](https://flutter.dev/)** - Framework UI multiplataforma
- **[Dart](https://dart.dev/)** - Linguagem de programação
- **[audioplayers](https://pub.dev/packages/audioplayers)** - Reprodução de áudio
- **Material Design** - Design system do Google

---

## 📖 Documentação Adicional

- 📘 [Como Testar](COMO_TESTAR.md) - Guia completo de testes
- 🎮 [Sistema Multiplayer](MULTIPLAYER_README.md) - Documentação do modo multiplayer
- ⏱️ [Sistema de Timer](TIMER_SYSTEM.md) - Timer dinâmico
- 🎵 [Sistema de Áudio](SISTEMA_AUDIO.md) - Músicas e efeitos sonoros
- ✅ [Checklist Final](CHECKLIST_FINAL.md) - Status de funcionalidades

---

## 🎯 Roadmap

### ✅ Concluído
- [x] Quiz clássico com timer e pontuação
- [x] Sistema de filtros (dificuldade e tags)
- [x] Modo multiplayer completo
- [x] 7 minigames funcionais
- [x] Sistema de áudio
- [x] Tela de estatísticas
- [x] Jogo da memória

### 🚧 Em Desenvolvimento
- [ ] Sistema de conquistas (achievements)
- [ ] Modo estudo (sem timer, com explicações)
- [ ] Temas dark/light
- [ ] Gráficos e estatísticas avançadas

### 📅 Futuro
- [ ] Backend real (Firebase)
- [ ] Chat no multiplayer
- [ ] Modo combate local (2 jogadores)
- [ ] Admin panel para editar perguntas
- [ ] Publicação na Play Store / App Store

---

## 🤝 Como Contribuir

Contribuições são bem-vindas! Veja o guia [CONTRIBUTING.md](CONTRIBUTING.md) para mais detalhes.

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

---

## 📝 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

## 👨‍💻 Autor

**Lenire Denis**

- GitHub: [@leniredenis-bit](https://github.com/leniredenis-bit)
- Repositório: [JWQuizFlutter](https://github.com/leniredenis-bit/JWQuizFlutter)

---

## 🙏 Agradecimentos

- Comunidade Flutter e Dart
- Todos os testadores e contribuidores
- Fontes de perguntas bíblicas

---

<div align="center">

**Feito com ❤️ e Flutter**

⭐ Se você gostou do projeto, considere dar uma estrela!

</div>
