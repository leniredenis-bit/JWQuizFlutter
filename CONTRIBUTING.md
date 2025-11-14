# 🤝 Guia de Contribuição - JW Quiz Flutter

Obrigado por considerar contribuir para o **JW Quiz Flutter**! Este documento fornece diretrizes para ajudá-lo a contribuir de forma eficaz.

---

## 📋 Tabela de Conteúdos

- [Código de Conduta](#código-de-conduta)
- [Como Posso Contribuir?](#como-posso-contribuir)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Padrões de Código](#padrões-de-código)
- [Processo de Pull Request](#processo-de-pull-request)
- [Reportar Bugs](#reportar-bugs)
- [Sugerir Melhorias](#sugerir-melhorias)

---

## 📜 Código de Conduta

Este projeto segue o [Código de Conduta do Contributor Covenant](https://www.contributor-covenant.org/). Ao participar, você concorda em manter um ambiente respeitoso e inclusivo.

---

## 💡 Como Posso Contribuir?

### 1. **Reportar Bugs**
- Use a aba [Issues](https://github.com/leniredenis-bit/JWQuizFlutter/issues)
- Verifique se o bug já foi reportado
- Use o template de bug report
- Inclua prints/vídeos se possível

### 2. **Sugerir Features**
- Crie uma Issue com label `enhancement`
- Descreva a funcionalidade desejada
- Explique o caso de uso
- Discuta antes de implementar

### 3. **Melhorar Documentação**
- Correções de typos
- Tradução de documentos
- Adicionar exemplos
- Melhorar clareza

### 4. **Contribuir com Código**
- Corrigi bugs
- Implementar features
- Melhorar performance
- Adicionar testes

---

## 📁 Estrutura do Projeto

```
lib/
├── main.dart              # Entry point
├── models/                # Data models
│   ├── question.dart
│   ├── quiz_service.dart
│   └── multiplayer/       # Multiplayer models
├── screens/               # UI screens
│   ├── home_screen.dart
│   ├── quiz_screen.dart
│   ├── minigames/         # Minigame screens
│   └── multiplayer/       # Multiplayer screens
├── services/              # Business logic
│   ├── audio_service.dart
│   └── multiplayer/
├── utils/                 # Helper functions
│   └── timer_calculator.dart
└── widgets/               # Reusable widgets

docs/                      # Documentation
assets/                    # Images, audio, data
test/                      # Unit and widget tests
```

---

## 🎨 Padrões de Código

### **Dart Style Guide**

Seguimos o [Dart Style Guide](https://dart.dev/guides/language/effective-dart) oficial.

#### **Formatação**
```bash
# Formatar código automaticamente
flutter format .
```

#### **Análise Estática**
```bash
# Verificar problemas de código
flutter analyze
```

#### **Naming Conventions**

```dart
// Classes: PascalCase
class QuizScreen extends StatefulWidget {}

// Variáveis e métodos: camelCase
String playerName = "John";
void startGame() {}

// Constantes: lowerCamelCase
const int maxPlayers = 100;

// Arquivos: snake_case
// quiz_screen.dart
// multiplayer_service.dart
```

### **Comentários**

```dart
/// Documentação de classe/método público
/// Use /// para gerar documentação
class AudioService {
  /// Toca música de fundo
  /// 
  /// [track] - Nome do arquivo MP3
  /// Returns: Future que completa quando música inicia
  Future<void> playBackgroundMusic(String track) async {
    // Comentários internos usam //
    // ...
  }
}
```

### **Imports**

```dart
// 1. Dart SDK
import 'dart:async';

// 2. Packages externos
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

// 3. Arquivos do projeto (ordem alfabética)
import '../models/question.dart';
import '../services/audio_service.dart';
```

### **State Management**

- Use `StatefulWidget` para telas com estado mutável
- Sempre chame `setState()` para atualizar UI
- Dispose de controllers e streams em `dispose()`

```dart
@override
void dispose() {
  _timer?.cancel();
  _audioPlayer.dispose();
  super.dispose();
}
```

---

## 🔄 Processo de Pull Request

### **1. Fork e Clone**

```bash
# Fork no GitHub, depois:
git clone https://github.com/SEU-USUARIO/JWQuizFlutter.git
cd jw_quiz_flutter
```

### **2. Crie uma Branch**

```bash
# Padrão: tipo/descricao-curta
git checkout -b feature/add-dark-theme
git checkout -b fix/timer-bug
git checkout -b docs/improve-readme
```

Tipos:
- `feature/` - Nova funcionalidade
- `fix/` - Correção de bug
- `docs/` - Documentação
- `refactor/` - Refatoração
- `test/` - Testes
- `style/` - Formatação/estilo

### **3. Faça suas Alterações**

```bash
# Adicione commits com mensagens claras
git add .
git commit -m "feat: adiciona tema dark mode

- Criado ThemeManager
- Adicionadas variáveis de tema
- Implementado toggle no settings
"
```

**Formato de Commit:**
```
tipo: descrição curta (máx 50 chars)

Corpo explicativo opcional (máx 72 chars por linha)
- Detalhe 1
- Detalhe 2

Closes #123
```

Tipos:
- `feat`: Nova feature
- `fix`: Bug fix
- `docs`: Documentação
- `style`: Formatação
- `refactor`: Refatoração
- `test`: Testes
- `chore`: Manutenção

### **4. Teste Suas Alterações**

```bash
# Executar testes
flutter test

# Verificar análise estática
flutter analyze

# Testar no emulador/browser
flutter run -d chrome
```

### **5. Push e Pull Request**

```bash
git push origin feature/add-dark-theme
```

No GitHub:
1. Abra um Pull Request
2. Preencha o template
3. Referencie issues relacionadas
4. Aguarde review

---

## 🐛 Reportar Bugs

### **Template de Bug Report**

```markdown
**Descrição do Bug**
Uma descrição clara do problema.

**Como Reproduzir**
1. Vá para '...'
2. Clique em '...'
3. Role até '...'
4. Veja o erro

**Comportamento Esperado**
O que deveria acontecer.

**Screenshots**
Se aplicável, adicione screenshots.

**Ambiente:**
 - Device: [e.g. iPhone 13, Pixel 6]
 - OS: [e.g. iOS 15, Android 12]
 - Flutter Version: [e.g. 3.35.3]

**Informações Adicionais**
Qualquer outro contexto relevante.
```

---

## 💡 Sugerir Melhorias

### **Template de Feature Request**

```markdown
**Descrição da Feature**
Uma descrição clara da funcionalidade desejada.

**Problema que Resolve**
Qual problema essa feature resolve?

**Solução Proposta**
Como você imagina que funcione?

**Alternativas Consideradas**
Outras abordagens possíveis.

**Contexto Adicional**
Screenshots, mockups, exemplos de outros apps.
```

---

## ✅ Checklist para Contribuições

Antes de submeter seu PR, verifique:

- [ ] Código segue o style guide do Dart
- [ ] Executei `flutter format .`
- [ ] Executei `flutter analyze` sem erros
- [ ] Testei as alterações localmente
- [ ] Adicionei comentários para código complexo
- [ ] Atualizei a documentação relevante
- [ ] Commit messages seguem o padrão
- [ ] PR descreve claramente as mudanças

---

## 📚 Recursos Úteis

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Material Design Guidelines](https://material.io/design)

---

## 🎓 Boas Práticas

### **Performance**

- Evite `setState()` desnecessário
- Use `const` sempre que possível
- Dispose de recursos (timers, controllers)
- Evite reconstruções desnecessárias de widgets

### **Acessibilidade**

- Adicione `Semantics` labels
- Suporte para screen readers
- Contraste adequado de cores
- Tamanho mínimo de touch targets (48x48)

### **Internacionalização**

- Textos em inglês por padrão
- Use `Localizations` para i18n futuro
- Evite strings hardcoded em widgets

---

## 📞 Precisa de Ajuda?

- 💬 Abra uma **Discussion** para perguntas gerais
- 🐛 Abra uma **Issue** para bugs/features
- 📧 Contate o maintainer: [@leniredenis-bit](https://github.com/leniredenis-bit)

---

## 🙏 Agradecimentos

Obrigado por contribuir! Toda ajuda é bem-vinda, seja código, documentação, testes ou ideias.

---

**Feliz Coding! 🚀**
