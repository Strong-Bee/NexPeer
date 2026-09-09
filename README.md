# NexPeer

> **Private. Direct. Peer-to-Peer.**

NexPeer adalah aplikasi komunikasi **Peer-to-Peer (P2P)** berbasis Flutter yang dirancang untuk memungkinkan pengguna berkomunikasi secara langsung antar perangkat.

Aplikasi ini memiliki konsep seperti aplikasi messenger modern dengan fitur **Chat, Story, Calls, Profile**, serta koneksi perangkat melalui jaringan P2P.

---

## ✨ Features

### 💬 Chat

- Private P2P messaging
- Real-time message
- Send & receive messages
- Message timestamp
- Message delivery status
- Auto scroll ke pesan terbaru
- Search messages
- Copy message
- Reply message
- Delete message
- Clear chat
- Attachment menu
- Online/offline connection status

### 🟣 Story

- My Story
- Story dari peer
- Story viewer
- Story ring indicator
- Add Story
- Recent Stories
- Camera shortcut

### 📞 Calls

- Call history
- Incoming call
- Outgoing call
- Missed call
- Voice call
- Video call
- Call status

### 👤 Profile

- User profile
- Edit profile
- Username
- Profile photo
- Status
- Privacy settings
- Notification settings
- Application settings
- About NexPeer

### 📱 P2P Devices

- Discover nearby peers
- Connect to peer
- Disconnect peer
- Connection status
- Direct device-to-device communication

### 🔐 Privacy

NexPeer dirancang dengan prinsip:

> **Your device. Your connection. Your conversation.**

Komunikasi P2P ditujukan untuk mengurangi ketergantungan terhadap server pusat.

Untuk implementasi produksi, pesan harus menggunakan **authenticated encryption dan secure key exchange**, bukan sekadar hashing atau Base64.

---

# 🏗️ Architecture

NexPeer menggunakan arsitektur sederhana agar project mudah dikembangkan.

```text
┌───────────────────────────────┐
│           NexPeer             │
├───────────────────────────────┤
│                               │
│  Splash Screen                │
│          │                    │
│          ▼                    │
│  ┌─────────────────────────┐  │
│  │       Home Screen       │  │
│  └─────────────────────────┘  │
│       │    │    │    │        │
│       ▼    ▼    ▼    ▼        │
│     Chat Story Calls Profile  │
│       │                       │
│       ▼                       │
│   P2P Service                 │
│       │                       │
│       ▼                       │
│ flutter_p2p_connection       │
│       │                       │
│       ▼                       │
│    Peer Device                │
│                               │
└───────────────────────────────┘
```

---

# 📂 Project Structure

```text
nexpeer/
│
├── android/
├── ios/
├── web/
├── windows/
├── linux/
├── macos/
│
├── lib/
│   │
│   ├── main.dart
│   │
│   ├── models/
│   │   ├── peer.dart
│   │   └── message.dart
│   │
│   ├── services/
│   │   ├── p2p_service.dart
│   │   └── crypto_service.dart
│   │
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── home_screen.dart
│   │   ├── devices_screen.dart
│   │   ├── chat_screen.dart
│   │   ├── story_screen.dart
│   │   ├── call_screen.dart
│   │   └── profile_screen.dart
│   │
│   └── widgets/
│       ├── peer_card.dart
│       └── message_bubble.dart
│
├── test/
│
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

---

# 🛠️ Tech Stack

| Technology             | Purpose                      |
| ---------------------- | ---------------------------- |
| Flutter                | Mobile application framework |
| Dart                   | Programming language         |
| flutter_p2p_connection | P2P communication            |
| crypto                 | Cryptographic utilities      |
| Material 3             | UI design                    |
| Android                | Primary mobile platform      |
| iOS                    | Planned/Supported platform   |

---

# 📦 Dependencies

Current primary dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter

  flutter_p2p_connection: ^3.0.3
  crypto: ^3.0.7
```

Install dependencies:

```bash
flutter pub get
```

---

# 🚀 Getting Started

## Requirements

Make sure you have installed:

- Flutter SDK
- Dart SDK
- Android Studio
- Android SDK
- Android device or emulator
- Git

Check Flutter installation:

```bash
flutter doctor
```

Check connected devices:

```bash
flutter devices
```

---

# 📥 Installation

Clone repository:

```bash
git clone <YOUR_REPOSITORY_URL>
```

Enter project:

```bash
cd nexpeer
```

Install dependencies:

```bash
flutter pub get
```

---

# ▶️ Run Application

Run the application:

```bash
flutter run
```

Run specifically on Android:

```bash
flutter run -d android
```

Check available devices:

```bash
flutter devices
```

Then:

```bash
flutter run -d <device-id>
```

---

# 🧹 Clean Project

If Flutter encounters build or hot reload issues:

```bash
flutter clean
flutter pub get
flutter run
```

For changes involving widget/class structure, use **Hot Restart** instead of Hot Reload.

---

# 🔌 P2P Communication

NexPeer uses a P2P service layer:

```text
ChatScreen
     │
     ▼
P2PService
     │
     ▼
flutter_p2p_connection
     │
     ▼
Peer Device
```

The `P2PService` is responsible for:

- Peer discovery
- Connection management
- Connection state
- Sending messages
- Receiving messages
- Disconnecting peers

Example:

```dart
final p2pService = P2PService.instance;

await p2pService.sendMessage(
  'Hello from NexPeer',
);
```

---

# 🔐 Security

NexPeer is intended to provide private peer-to-peer communication.

However, **P2P does not automatically mean encrypted**.

For production deployment, the recommended security architecture is:

```text
Device A
   │
   │ Secure Key Exchange
   ▼
Session Key
   │
   │ Authenticated Encryption
   ▼
Encrypted Message
   │
   ▼
P2P Transport
   │
   ▼
Device B
   │
   ▼
Decrypt Message
```

Recommended security requirements:

- Secure key exchange
- Authenticated encryption
- Unique session keys
- Replay protection
- Message authentication
- Secure random number generation
- No plaintext sensitive data in logs

Do not use:

```text
Base64 = Encryption ❌
SHA-256 = Encryption ❌
MD5 = Secure Encryption ❌
SHA-1 = Secure Encryption ❌
```

Hashing and encoding are different from encryption.

---

# 🎨 UI

NexPeer uses a dark, modern interface.

Main navigation:

```text
┌─────────────────────────────┐
│           NexPeer            │
├─────────────────────────────┤
│                             │
│          CONTENT            │
│                             │
├─────────────────────────────┤
│ Chat │ Story │ Calls │ Me   │
└─────────────────────────────┘
```

Primary sections:

### Chat

```text
💬 Chat
├── Search
├── Conversations
├── Message
├── Attachment
└── P2P Status
```

### Story

```text
🟣 Story
├── My Story
├── Add Story
├── Recent Stories
└── Story Viewer
```

### Calls

```text
📞 Calls
├── Incoming
├── Outgoing
├── Missed
├── Voice Call
└── Video Call
```

### Profile

```text
👤 Profile
├── Account
├── Edit Profile
├── Privacy
├── Notifications
├── Settings
└── About
```

---

# 🧪 Development

Analyze the project:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

Format Dart code:

```bash
dart format lib/
```

Check dependencies:

```bash
flutter pub outdated
```

---

# 📱 Build Android APK

Build debug APK:

```bash
flutter build apk --debug
```

Build release APK:

```bash
flutter build apk --release
```

APK will be generated under:

```text
build/app/outputs/flutter-apk/
```

For a smaller architecture-specific APK:

```bash
flutter build apk --split-per-abi
```

---

# 🔧 Development Roadmap

## Phase 1 — UI

- [x] Splash Screen
- [x] Home Screen
- [x] Chat UI
- [x] Story UI
- [x] Call UI
- [x] Profile UI
- [x] Dark theme
- [x] Bottom navigation

## Phase 2 — P2P

- [ ] Device discovery
- [ ] Peer pairing
- [ ] P2P connection
- [ ] Send message
- [ ] Receive message
- [ ] Connection recovery
- [ ] Disconnect handling

## Phase 3 — Messaging

- [ ] Message persistence
- [ ] Message IDs
- [ ] Delivery status
- [ ] Read status
- [ ] Reply
- [ ] Delete
- [ ] Search
- [ ] Message synchronization

## Phase 4 — Security

- [ ] Secure key exchange
- [ ] Session encryption
- [ ] Message authentication
- [ ] Replay protection
- [ ] Secure local storage
- [ ] Device verification

## Phase 5 — Media

- [ ] Image sharing
- [ ] Video sharing
- [ ] File sharing
- [ ] Voice messages
- [ ] Location sharing

## Phase 6 — Calls

- [ ] Voice call
- [ ] Video call
- [ ] Incoming call UI
- [ ] Call accept/reject
- [ ] Call history
- [ ] Call duration
- [ ] Call disconnect

## Phase 7 — Story

- [ ] Upload image
- [ ] Upload video
- [ ] Story expiration
- [ ] Story viewer
- [ ] Story reactions
- [ ] Story privacy

---

# 🤝 Contributing

Contributions are welcome.

Create a fork:

```bash
git fork
```

Create a branch:

```bash
git checkout -b feature/my-feature
```

Make your changes:

```bash
git add .
git commit -m "feat: add my feature"
```

Push:

```bash
git push origin feature/my-feature
```

Then create a Pull Request.

---

# 🐛 Bug Reports

If you find a bug, provide:

1. Device model
2. Android/iOS version
3. Flutter version
4. Steps to reproduce
5. Error message
6. Screenshot or log if available

Example:

```text
Device:
Samsung Android

Flutter:
3.x.x

Problem:
Message cannot be sent after connecting to peer.

Steps:
1. Open NexPeer
2. Open Devices
3. Connect to peer
4. Open Chat
5. Send message

Error:
<error message>
```

---

# 📜 License

This project is currently under development.

License information will be added before public release.

---

# 👨‍💻 Developer

**Cyber Technology Project**

Project:

**NexPeer**

Tagline:

> Private. Direct. Peer-to-Peer.

---

# ⭐ Vision

NexPeer aims to become a modern communication platform where users can communicate directly between devices with a strong focus on:

```text
Privacy
   +
Security
   +
Direct Communication
   +
Simple UX
   =
NexPeer
```

---

## Status

🚧 **NexPeer is currently under active development.**

The UI foundation is available, while the P2P transport, secure messaging, media transfer, and real-time calling layers are being developed.
#   N e x P e e r  
 