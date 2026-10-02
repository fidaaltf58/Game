# 🌱 صديق البيئة: Sadik Bi2a (Friend of the Environment)

**Sadik Bi2a** is a cross-platform educational game built with **Flutter**. It teaches children and teenagers (8–18) about sustainability through mini-games, with a focus on environmental issues in **Tunisia**. The interface is in **Arabic** and includes an AI eco-assistant chatbot.

---

## 🎯 Goals

- Raise environmental awareness in an engaging, age-appropriate way
- Build sustainable habits through games and challenges
- Teach about local Tunisian issues: beaches, forests, biodiversity, and natural resources
- Use AI to answer questions and give eco-advice

## 🧩 Features

### Mini-games
| Game | Arabic title | Theme |
|---|---|---|
| ♻️ Recycling | إعادة التدوير | Sort waste into the right bins |
| 🌱 Tree planting | زراعة الأشجار | Plant trees and restore the forest |
| 🌊 Ocean cleanup | تنظيف المحيطات | Clean rubbish out of the sea |
| ⚡ Clean energy | الطاقة النظيفة | Learn about renewable energy |

Each game has timed **levels** and a **score**. Scores for the recycling, planting, and cleanup games are saved per level for each user.

### 🤖 Eco-assistant chatbot
- Chat screen that streams answers from an LLM server
- Sends `POST /generate` with `{ "prompt", "max_tokens", "stream": true }`
- The server URL defaults to `http://127.0.0.1:8000` and can be changed in the app (saved with `shared_preferences`)

### 👤 Accounts and progress
- Local register/login (stored on the device with `shared_preferences`)
- Splash screen → login → home with game cards
- **Cairo** font for clean Arabic typography

## 🛠️ Tech stack

| | |
|---|---|
| Framework | Flutter (Dart SDK ^3.9) |
| Platforms | Android, iOS, Web, Windows, macOS, Linux |
| Packages | `http`, `shared_preferences`, `cupertino_icons` |
| AI backend | Any HTTP server that exposes a streaming `/generate` endpoint |

## 📁 Project structure

```
lib/
├── main.dart                     # App entry, theme, routes
├── chat/
│   └── eco_assistant_chatbot.dart
├── models/
│   └── user.dart
├── screens/
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── home_screen.dart
│   └── games/
│       ├── recycle_game_screen.dart
│       ├── plant_game_screen.dart
│       ├── clean_game_screen.dart
│       └── energy_game_screen.dart
├── services/
│   ├── auth_service.dart         # Local users + scores
│   └── storage_service.dart      # shared_preferences wrapper
└── widgets/
    └── game_card.dart
Assets/fonts/                     # Cairo Regular / Bold
```

## 🚀 Getting started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart 3.9+)
- An emulator, a device, or Chrome

### Run

```bash
git clone https://github.com/fidaaltf58/Game.git
cd Game
flutter pub get
flutter run                 # choose a device
# flutter run -d chrome     # web
```

### Chatbot server (optional)

The chatbot needs an LLM server on `http://127.0.0.1:8000` with a streaming `POST /generate` endpoint, for example a small FastAPI wrapper around a local model. On the Android emulator, use `http://10.0.2.2:8000` to reach your computer's localhost. The URL can be changed from the chatbot screen.

### Tests

```bash
flutter test
```

## 🗺️ Roadmap

- [ ] Drag-and-drop and image-based quizzes
- [ ] Eco-points, badges, and achievement levels
- [ ] French language support
- [ ] Cloud accounts (Firebase Auth / Firestore)
- [ ] Community eco-challenges and AR experiences
- [ ] Partnerships with schools and NGOs in Tunisia

## 📄 Status

🚧 **Work in progress.** Ideas and contributions are welcome.

## Author

**Fidaa Letaief** · [@fidaaltf58](https://github.com/fidaaltf58)
