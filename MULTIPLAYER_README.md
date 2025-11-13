# Sistema Multiplayer - JW Quiz

## 📋 Visão Geral

Sistema completo de partidas multiplayer online com sincronização em tempo real, suportando até 100 jogadores por sala (padrão: 20).

## ✅ Funcionalidades Implementadas

### 🏗️ Arquitetura
- **Models**: `Player`, `Room`, `GameState`
- **Services**: `ProfanityFilter`, `MockMultiplayerService`
- **Screens**: 7 telas completas (Menu, Criar, Entrar, Lobby, Quiz, Resultados Parciais, Resultados Finais)

### 🎮 Fluxo de Jogo

#### 1. Menu Multiplayer (`MultiplayerMenuScreen`)
- Seleção entre "Criar Sala" ou "Entrar em Sala"
- Informações sobre o modo multiplayer

#### 2. Criar Sala (`CreateRoomScreen`)
- Formulário de apelido (3-20 caracteres)
- Validação de profanidade com sugestões automáticas
- Configuração de perguntas (5, 10, 15, 20, 25, 30)
- Configuração de capacidade da sala (8 a 100 jogadores, padrão 20)
- ⚡ **Tempo calculado automaticamente**: (palavras ÷ 3) + 20 segundos
- Geração de código único de 6 dígitos

#### 3. Entrar em Sala (`JoinRoomScreen`)
- Input de código da sala (6 dígitos numéricos)
- Formulário de apelido com validação
- Verificação de disponibilidade da sala
- Atribuição automática de avatar emoji

#### 4. Lobby (`LobbyScreen`)
- Lista de jogadores em tempo real
- Indicadores visuais: avatar, apelido, badges (ANFITRIÃO/VOCÊ)
- Controles do anfitrião:
  - ✅ Iniciar Partida (mínimo 2 jogadores)
  - 🗑️ Remover jogador
  - ❌ Encerrar sala
- Não-anfitrião: aguarda início
- Botões de copiar/compartilhar código da sala
- Navegação automática quando jogo inicia

#### 5. Quiz Multiplayer (`MultiplayerQuizScreen`)
- ⚡ **Timer dinâmico**: calculado automaticamente baseado no tamanho da pergunta
  - Fórmula: (total de palavras ÷ 3) + 20 segundos para compensar latência
  - Mínimo: 15s, Máximo: 90s
  - Exibição em vermelho quando ≤5s
- Exibição da pergunta com dificuldade
- 4 alternativas (A/B/C/D) com feedback visual
- Submissão de resposta com cálculo de pontos:
  - **Base**: 10 (Fácil), 15 (Médio), 20 (Difícil)
  - **Bônus tempo**: 0.5 × segundos restantes
- Status de sincronização: "👥 2/4" (responderam/total)
- Estados visuais:
  - Cinza: padrão
  - Azul: selecionado
  - Verde: correto (após submissão)
  - Vermelho: errado (após submissão)
- Navegação automática para resultados quando todos respondem

#### 6. Resultados Parciais (`RoundResultScreen`)
- Indicador de acerto/erro para jogador atual
- Estatísticas: posição no ranking, pontos totais
- Ranking completo com:
  - Medalhas: 🥇🥈🥉 (top 3)
  - Avatar e apelido
  - Indicador de acerto/erro
  - Pontuação
- Anfitrião: botão "Próxima Pergunta"
- Não-anfitrião: aguarda anfitrião
- Navegação automática para próxima pergunta ou resultados finais

#### 7. Resultados Finais (`FinalResultScreen`)
- Animação de confete para o vencedor 🎉
- Pódio com top 3 jogadores:
  - Alturas diferentes (1º mais alto)
  - Cores: Ouro, Prata, Bronze
  - Medalhas: 🥇🥈🥉
- Lista completa de jogadores (4º em diante)
- Controles do anfitrião:
  - 🔁 Jogar Novamente (reinicia com novas perguntas)
  - ❌ Encerrar Sala
- Não-anfitrião: aguarda decisão

## 🛠️ Componentes Técnicos

### Models

#### `Player` (lib/models/multiplayer/player.dart)
```dart
class Player {
  final String id;
  final String nickname;
  final String avatar;          // Emoji (🎯, 🌟, etc)
  final int score;
  final bool isHost;
  final bool isReady;
  final bool hasAnswered;
  final int? lastAnswer;        // Índice da resposta (0-3)
  final bool lastAnswerCorrect;
  final DateTime joinedAt;
  final DateTime lastActivity;
  
  // Métodos: toMap(), fromMap(), copyWith(), resetRound()
}
```

#### `Room` (lib/models/multiplayer/room.dart)
```dart
enum RoomStatus { 
  waiting,    // Aguardando jogadores
  starting,   // Iniciando (3s de countdown)
  playing,    // Jogando pergunta atual
  roundEnd,   // Fim de rodada (exibindo resultados)
  finished,   // Jogo finalizado
  closed      // Sala encerrada
}

class Room {
  final String id;                      // Código de 6 dígitos
  final String hostId;
  final Map<String, Player> players;    // Map<playerId, Player>
  final RoomStatus status;
  final DateTime createdAt;
  final DateTime lastActivity;
  final int currentQuestionIndex;
  final int totalQuestions;
  final List<int> questionIds;          // IDs das perguntas selecionadas
  final int roundTimeLimit;             // Segundos por pergunta
  final DateTime? roundStartTime;
  
  // Computed properties:
  List<Player> get rankedPlayers;       // Ordenado por score DESC
  bool get allPlayersAnswered;
  bool get isFull;                      // >= 8 jogadores
  bool get isExpired;                   // > 1 hora
  bool get shouldShowExpirationWarning; // > 55 minutos
  int get minutesUntilExpiration;
  
  // Métodos: addPlayer(), removePlayer(), updatePlayer(), 
  //          transferHost(), resetRound(), toMap(), fromMap()
}
```

#### `GameState` (lib/models/multiplayer/game_state.dart)
```dart
class GameState {
  final Room? currentRoom;
  final String? currentPlayerId;
  final List<Question> questions;
  final Question? currentQuestion;
  final bool isLoading;
  final String? error;
  final int timeRemaining;
  
  // Helpers:
  Player? get currentPlayer;
  bool get isHost;
  bool get allPlayersAnswered;
}
```

### Services

#### `ProfanityFilter` (lib/services/multiplayer/profanity_filter.dart)
- **Palavras banidas**: ~30 termos (idiota, burro, fdp, demônio, etc)
- **Sugestões**: Discípulo, Pescador, Benção, Fiel, Servo, etc
- **Métodos**:
  - `validateNickname(String nickname)` → `ValidationResult`
  - `generateAlternativeNickname()` → String (ex: "Discípulo123✨")
  - `_normalize(String text)` → Remove acentos para comparação

#### `MockMultiplayerService` (lib/services/multiplayer/mock_multiplayer_service.dart)
Simula backend Firebase com armazenamento em memória e Streams.

**Dados em Memória**:
```dart
static final Map<String, Room> _rooms = {};
static final Map<String, StreamController<Room>> _roomControllers = {};
```

**Métodos Principais**:

| Método | Parâmetros | Retorno | Descrição |
|--------|-----------|---------|-----------|
| `createRoom` | hostId, hostNickname, totalQuestions, roundTimeLimit | `Future<Room>` | Cria sala com código único, seleciona perguntas aleatórias |
| `joinRoom` | roomCode, playerId, nickname | `Future<void>` | Adiciona jogador, atribui avatar |
| `removePlayer` | roomCode, playerId | `Future<void>` | Remove jogador, transfere host se necessário |
| `startGame` | roomCode | `Future<void>` | Valida 2+ players, waiting→starting→playing |
| `submitAnswer` | roomCode, playerId, answerIndex, isCorrect, points | `Future<void>` | Registra resposta, atualiza score |
| `nextQuestion` | roomCode | `Future<void>` | Avança para próxima ou finaliza |
| `restartGame` | roomCode | `Future<void>` | Reseleciona perguntas, reseta scores |
| `closeRoom` | roomCode | `Future<void>` | Marca closed, limpa streams |
| `roomStream` | roomCode | `Stream<Room>` | Stream de atualizações em tempo real |
| `getRoom` | roomCode | `Room?` | Acesso direto ao estado |

**Recursos**:
- ✅ Geração de código único (100000-999999)
- ✅ Seleção aleatória de perguntas
- ✅ Avatars aleatórios: 🎯, 🌟, 🏆, 🎮, 🎨, 🎭, 🎪, 🎬
- ✅ Transferência automática de host
- ✅ Limpeza de salas expiradas (Timer.periodic)
- ✅ Broadcast de atualizações via StreamController

## 📊 Estados e Transições

```
waiting → starting (3s) → playing → roundEnd → playing → ... → finished
   ↓                                     ↑                        ↓
closed ←─────────────────────────────────┴────────────────────→ waiting (restart)
```

## 🎯 Pontuação

### Fórmula
```dart
int basePoints = 10;  // Fácil (dificuldade 1)
if (dificuldade == 2) basePoints = 15;  // Médio
if (dificuldade == 3) basePoints = 20;  // Difícil

int timeBonus = (timeRemaining * 0.5).round();
int totalPoints = basePoints + timeBonus;
```

### Exemplos
- **Fácil, 10s restantes**: 10 + 5 = **15 pontos**
- **Médio, 15s restantes**: 15 + 7 = **22 pontos**
- **Difícil, 20s restantes**: 20 + 10 = **30 pontos**
- **Timeout (0s)**: Base apenas = **10/15/20 pontos**

## 🔒 Validações

### Apelido
- ✅ Mínimo 3 caracteres
- ✅ Máximo 20 caracteres
- ✅ Sem palavras ofensivas
- ✅ Sugestão automática se rejeitado

### Sala
- ✅ Código único de 6 dígitos
- ✅ Máximo 8 jogadores
- ✅ Mínimo 2 jogadores para iniciar
- ✅ Apenas anfitrião pode iniciar/encerrar
- ✅ Status deve ser `waiting` para entrar
- ✅ Expiração após 1 hora de inatividade

### Jogo
- ✅ Timer sincronizado (server-side)
- ✅ Submissão única por rodada
- ✅ Todos devem responder para avançar
- ✅ Validação de índice de resposta (0-3)

## 🚀 Como Usar

### 1. Inicializar Serviço (Recomendado no main.dart)
```dart
void main() {
  MockMultiplayerService.initialize();
  runApp(MyApp());
}
```

### 2. Adicionar ao Home
Já integrado! Botão "🌐 Partida Online" no `HomeScreen`.

### 3. Criar Sala
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => MultiplayerMenuScreen()),
);
```

### 4. Cleanup (Opcional)
```dart
@override
void dispose() {
  MockMultiplayerService.dispose();
  super.dispose();
}
```

## 🔄 Migração para Firebase

### Passo 1: Adicionar Dependências
```yaml
# pubspec.yaml
dependencies:
  firebase_core: ^2.24.0
  firebase_database: ^10.4.0
```

### Passo 2: Configurar Firebase
```dart
// main.dart
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}
```

### Passo 3: Criar FirebaseMultiplayerService
Criar `lib/services/multiplayer/firebase_multiplayer_service.dart`:
- Implementar mesma interface do `MockMultiplayerService`
- Usar `FirebaseDatabase.instance.ref()`
- Substituir `_rooms` por `ref('rooms')`
- Substituir `StreamController` por `ref.onValue.listen()`

### Passo 4: Alternar Serviço
```dart
// Substitua MockMultiplayerService por FirebaseMultiplayerService
// em todas as telas multiplayer

// Antes:
await MockMultiplayerService.createRoom(...);

// Depois:
await FirebaseMultiplayerService.createRoom(...);
```

### Estrutura no Firebase
```
rooms/
  ├─ 123456/
  │   ├─ id: "123456"
  │   ├─ hostId: "host123"
  │   ├─ status: "playing"
  │   ├─ players/
  │   │   ├─ player1/
  │   │   │   ├─ nickname: "Discípulo"
  │   │   │   ├─ score: 45
  │   │   │   └─ ...
  │   │   └─ player2/...
  │   └─ ...
  └─ 789012/...
```

## 📝 TODOs Futuros

### Alta Prioridade
- [ ] Implementar aviso de timeout aos 55 minutos
- [ ] Adicionar botão "Sair da Sala" na tela de quiz

### Média Prioridade
- [ ] Adicionar chat entre jogadores no lobby
- [ ] Estatísticas por partida (% acerto, tempo médio)
- [ ] Modo espectador (visualizar sem jogar)
- [ ] Replay de perguntas respondidas

### Baixa Prioridade
- [ ] Salas privadas (senha)
- [ ] Torneios com múltiplas salas
- [ ] Rankings globais
- [ ] Conquistas multiplayer

## 🐛 Casos de Teste

### Cenário 1: Jogo Completo
1. ✅ Criar sala com 10 perguntas, 15s cada
2. ✅ 3 jogadores entram
3. ✅ Anfitrião inicia
4. ✅ Todos respondem 10 perguntas
5. ✅ Ver pódio com ranking
6. ✅ Anfitrião reinicia
7. ✅ Voltar para lobby

### Cenário 2: Saída do Anfitrião
1. ✅ Anfitrião cria sala
2. ✅ 2 jogadores entram
3. ✅ Anfitrião sai
4. ✅ Segundo jogador promovido a anfitrião
5. ✅ Novo anfitrião inicia jogo

### Cenário 3: Timeout
1. ✅ Criar sala
2. ✅ Aguardar 1 segundo sem atividade
3. ✅ Sala deve ser marcada como expirada
4. ⚠️ Aviso aos 55 minutos (não implementado)

### Cenário 4: Profanidade
1. ✅ Tentar entrar com apelido ofensivo
2. ✅ Ver mensagem de erro
3. ✅ Receber sugestão alternativa
4. ✅ Aceitar sugestão e entrar

## 📚 Recursos Adicionais

- **Documentação completa**: Ver este arquivo
- **Exemplos de uso**: Telas já implementadas
- **Mock service**: Pronto para testes offline
- **Escalabilidade**: Suporta até 8 jogadores por sala
- **Performance**: Atualizações em tempo real via Streams

## 📞 Suporte

Para dúvidas ou problemas:
1. Verificar logs do MockMultiplayerService
2. Inspecionar estado da sala com `getRoom(roomCode)`
3. Conferir status de streams com `roomStream(roomCode).listen(...)`

---

**Status**: ✅ Sistema completo e funcional (offline com mock service)  
**Última atualização**: 2024  
**Desenvolvido para**: JW Quiz Flutter
