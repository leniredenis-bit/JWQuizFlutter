# 🚀 Início Rápido - Sistema Multiplayer

## Testar Localmente (2 dispositivos/emuladores)

### Preparação
1. **Iniciar o app em 2 dispositivos** (físicos ou emuladores)
2. Ambos devem estar na tela inicial do JW Quiz

### Fluxo de Teste

#### 📱 **Dispositivo 1 (Anfitrião)**
1. Clique em **"🌐 Partida Online"**
2. Clique em **"Criar Sala"**
3. Digite seu apelido: `Discipulo1`
4. Configure:
   - Perguntas: **10**
   - Tempo: **15 segundos**
5. Clique em **"Criar Sala"**
6. ✅ **Anote o código de 6 dígitos** (ex: `123456`)
7. Aguarde outros jogadores...

#### 📱 **Dispositivo 2 (Jogador)**
1. Clique em **"🌐 Partida Online"**
2. Clique em **"Entrar em Sala"**
3. Digite o código: `123456`
4. Digite seu apelido: `Pescador2`
5. Clique em **"Entrar na Sala"**
6. ✅ Você está no lobby! Aguarde o anfitrião iniciar

#### 🎮 **Jogar**
**No Dispositivo 1:**
1. Veja que `Pescador2` entrou na sala
2. Clique em **"Iniciar Partida"**
3. Countdown 3... 2... 1...

**Em ambos os dispositivos:**
1. ⏱️ Responda a pergunta antes do tempo acabar
2. Veja o status: "👥 1/2" → "👥 2/2"
3. ✅ Veja os resultados parciais
4. **Anfitrião**: Clique em **"Próxima Pergunta"**
5. Repita até finalizar as 10 perguntas
6. 🏆 Veja o pódio com ranking final
7. **Anfitrião**: Escolha "Jogar Novamente" ou "Encerrar Sala"

## 🎯 Recursos para Testar

### ✅ Funcionalidades Principais
- [ ] Criar sala com diferentes configurações
- [ ] Entrar com 2-8 jogadores
- [ ] Remover jogador (anfitrião)
- [ ] Transferência de host (anfitrião sai)
- [ ] Timer sincronizado
- [ ] Pontuação correta (base + tempo)
- [ ] Resultados parciais após cada pergunta
- [ ] Pódio com animação de confete
- [ ] Reiniciar partida
- [ ] Encerrar sala

### 🧪 Cenários de Teste

#### 1. **Jogo Normal (3 jogadores)**
```
Dispositivo 1: Criar sala → Aguardar
Dispositivo 2: Entrar (código) → Aguardar
Dispositivo 3: Entrar (código) → Aguardar
Dispositivo 1: Iniciar Partida
Todos: Responder 10 perguntas
Ver ranking final
```

#### 2. **Anfitrião Sai**
```
Dispositivo 1: Criar sala
Dispositivo 2: Entrar
Dispositivo 1: Sair da sala (botão voltar)
Dispositivo 2: Verificar que se tornou anfitrião (👑)
Dispositivo 2: Iniciar partida sozinho (deve bloquear - mínimo 2)
```

#### 3. **Timeout de Resposta**
```
Criar sala com 10s por pergunta
Entrar com 2 jogadores
Iniciar partida
NÃO responder (deixar timer zerar)
Verificar: resposta automática (null) registrada
```

#### 4. **Profanidade no Apelido**
```
Entrar em sala
Digitar apelido: "idiota" ou "burro"
Ver mensagem de erro
Ver sugestão: "Discípulo123✨"
Aceitar sugestão ou digitar outro
```

#### 5. **Sala Cheia (8 jogadores)**
```
Criar sala
Entrar com 7 jogadores adicionais
Tentar entrar com 9º jogador
Ver erro: "Sala está cheia (máximo 8 jogadores)"
```

## 🔍 Verificar Sincronização

### Lobby
- ✅ Novo jogador aparece imediatamente
- ✅ Jogador removido desaparece
- ✅ Contador de jogadores atualiza
- ✅ Badges (ANFITRIÃO/VOCÊ) corretos

### Quiz
- ✅ Pergunta igual em todos os dispositivos
- ✅ Timer sincronizado (±1s aceitável)
- ✅ Status "👥 X/Y" atualiza ao responder
- ✅ Avanço automático quando todos respondem

### Resultados
- ✅ Ranking igual em todos os dispositivos
- ✅ Pontuações corretas
- ✅ Posição (1º/2º/3º) correta
- ✅ Indicadores de acerto/erro corretos

## 🐛 Debug

### Ver Estado da Sala
No código, adicione temporariamente:
```dart
// Em qualquer tela multiplayer
final room = MockMultiplayerService.getRoom(widget.roomCode);
print('Estado da sala: ${room?.toMap()}');
```

### Ver Logs do Serviço
```dart
// Em mock_multiplayer_service.dart
// Os logs já estão implementados, verifique o console:
print('🎮 Sala $roomCode criada');
print('👤 Jogador $playerId entrou na sala $roomCode');
print('🚀 Partida iniciada na sala $roomCode');
```

### Inspecionar Stream
```dart
MockMultiplayerService.roomStream(roomCode).listen((room) {
  print('📡 Atualização: ${room.status}, jogadores: ${room.players.length}');
});
```

## ⚡ Comandos Úteis

### Rodar em 2 Emuladores
```bash
# Terminal 1
flutter run -d emulator-5554

# Terminal 2
flutter run -d emulator-5556
```

### Rodar em 1 Emulador + 1 Físico
```bash
# Ver dispositivos
flutter devices

# Rodar no emulador
flutter run -d emulator-5554

# Rodar no celular
flutter run -d <device-id>
```

### Hot Reload
Pressione `r` no terminal para recarregar rapidamente.

## 📊 Checklist de Qualidade

### Interface
- [ ] Cores consistentes (azul/verde/vermelho)
- [ ] Fontes legíveis
- [ ] Botões responsivos ao toque
- [ ] Animações suaves
- [ ] Feedback visual claro

### Funcionalidade
- [ ] Não trava ao responder
- [ ] Não desconecta ao minimizar app
- [ ] Navegação não quebra
- [ ] Botão voltar funciona corretamente
- [ ] Tratamento de erros adequado

### Multiplayer
- [ ] Sincronização em <2s
- [ ] Sem perda de dados
- [ ] Transferência de host funciona
- [ ] Sala fecha corretamente
- [ ] Reiniciar mantém jogadores

## 🎓 Próximos Passos

Após testar localmente:
1. ✅ Sistema está funcionando? → Prosseguir para Firebase
2. ⚠️ Bugs encontrados? → Ver seção Debug acima
3. 💡 Ideias de melhoria? → Adicionar em MULTIPLAYER_README.md

## 📞 Problemas Comuns

### "Sala não encontrada"
- Verificar código digitado (6 dígitos)
- Confirmar que sala não expirou (1h)
- Reiniciar o app anfitrião

### "Sala está em andamento"
- Sala já começou, não pode mais entrar
- Criar nova sala ou aguardar finalizar

### Timer não sincroniza
- **Normal**: diferença de ±1-2s devido ao mock
- **Firebase**: Resolve com server timestamp

### Jogadores não aparecem
- Verificar logs no console
- Confirmar que MockMultiplayerService.initialize() foi chamado
- Reiniciar ambos os apps

---

**Pronto para testar?** 🚀  
Abra o app em 2 dispositivos e siga o fluxo acima!
