# 🚀 NexPeer

### Private. Direct. Peer-to-Peer.

**NexPeer** is a modern, privacy-focused **peer-to-peer messaging application built with Flutter**. It is designed to enable direct communication between devices through a clean, modern interface with a strong focus on **privacy, security, and decentralized communication**.

> **Your conversations. Your devices. Your privacy.**

NexPeer aims to provide an alternative approach to conventional messaging applications by exploring **direct device-to-device communication**, secure messaging, private file sharing, stories, and real-time communication.

---

## ✨ Why NexPeer?

Most modern messaging applications depend heavily on centralized infrastructure.

**NexPeer takes a different approach.**

The project is designed around the concept of **peer-to-peer communication**, where devices can communicate directly whenever the underlying network and transport layer support it.

### Core Principles

* 🔐 **Privacy First**
* 📡 **Peer-to-Peer Communication**
* ⚡ **Fast & Lightweight**
* 📱 **Cross-Platform Flutter App**
* 🛡️ **Secure Communication**
* 🧩 **Modular Architecture**
* 🎨 **Modern User Interface**
* 🌐 **Decentralized Communication Research**

---

# 📱 Features

## 💬 Private Messaging

NexPeer provides a modern chat experience designed for direct communication.

### Messaging Features

* Real-time messaging architecture
* Message status
* Sending state
* Delivered state
* Read state
* Message timestamps
* Message reply
* Copy message
* Delete message
* Chat search
* Auto-scroll
* Empty chat state
* Connection status
* Multi-line message input

The messaging layer is designed to integrate with the NexPeer P2P transport service.

---

## 📡 Peer-to-Peer Device Communication

NexPeer is built around a **P2P communication architecture**.

The application is designed to discover and communicate with nearby peers without requiring every message to pass through a centralized messaging server.

### Potential Transport Technologies

* Wi-Fi Direct
* Local network communication
* Peer discovery
* Device-to-device connections
* P2P data streams

The current architecture keeps the transport layer independent from the user interface, making the system easier to extend and maintain.

---

## 🔐 Privacy & Security

Privacy is one of the main goals of NexPeer.

The project includes a dedicated cryptographic service layer for security-related functionality.

### Current Cryptographic Utilities

* SHA-256 hashing
* SHA-1 hashing
* MD5 hashing
* Base64 encoding/decoding

> ⚠️ **Security Notice**
>
> Hashing and Base64 encoding are **not encryption**.
>
> Production-grade private messaging should use authenticated encryption and a properly designed key-exchange protocol rather than custom cryptographic constructions.

### Planned Security Improvements

* 🔑 Public/private key identity
* 🤝 Secure key exchange
* 🔒 End-to-end authenticated encryption
* 🛡️ Message integrity verification
* 🔐 Secure session keys
* 🔄 Key rotation
* 🆔 Cryptographic peer identities

---

# 📖 Stories

NexPeer includes a modern story system inspired by temporary social content.

### Story Features

* My Story
* Add Story
* Story rings
* Recent stories
* Story viewer
* Story timestamps
* Camera integration architecture
* Temporary content architecture

### Planned Story Features

* 📷 Photo stories
* 🎥 Video stories
* 🔒 Private stories
* 👥 Selected audience
* ⏱️ Automatic expiration
* 📊 Story views
* ❤️ Story reactions

---

# 📞 Calls

NexPeer includes a dedicated calling interface for future real-time communication.

### Supported Call Concepts

* 📞 Incoming calls
* 📲 Outgoing calls
* ❌ Missed calls
* ⏱️ Call duration
* 👤 Contact information
* 🎙️ Voice calls
* 📹 Video calls

The calling architecture is intended to evolve toward a real-time **P2P media communication solution**.

### Potential Technologies

* WebRTC
* Native platform RTC APIs
* P2P media transport
* Audio/video streams

---

# 👥 Peer Management

NexPeer is designed to provide a dedicated device and peer management experience.

### Peer Information

* Device name
* Peer ID
* Connection status
* Last seen
* Online/offline state
* Connection type
* Trust status

Example:

```text
┌─────────────────────────────┐
│ 🟢 Alex's Phone             │
│                             │
│ Peer ID                     │
│ 7F82-A912-CC31              │
│                             │
│ ● Connected                 │
└─────────────────────────────┘
```

---

# 🎨 Modern UI/UX

NexPeer uses a modern dark interface designed specifically for communication applications.

### UI Characteristics

* Material 3
* Dark theme
* Modern navigation
* Smooth animations
* Rounded components
* Responsive layouts
* Clean typography
* Minimal visual clutter
* Blue/cyan visual identity

The application is designed to feel familiar while maintaining its own unique visual identity.

---

# 🏗️ Architecture

NexPeer uses a lightweight and modular Flutter architecture.

```text
                    ┌──────────────────┐
                    │      NexPeer     │
                    │    Flutter App   │
                    └────────┬─────────┘
                             │
             ┌───────────────┼───────────────┐
             │               │               │
             ▼               ▼               ▼
        ┌─────────┐     ┌─────────┐     ┌─────────┐
        │ Screens │     │ Widgets │     │ Models  │
        └────┬────┘     └─────────┘     └─────────┘
             │
             ▼
        ┌────────────────────────┐
        │        Services        │
        ├────────────────────────┤
        │ P2P Service            │
        │ Crypto Service         │
        └────────────┬───────────┘
                     │
                     ▼
          ┌─────────────────────┐
          │ P2P Transport Layer │
          └──────────┬──────────┘
                     │
             ┌───────┴────────┐
             ▼                ▼
        ┌─────────┐      ┌─────────┐
        │  Peer A │ ◄──► │  Peer B │
        └─────────┘      └─────────┘
```

---

# 📂 Project Structure

The project intentionally keeps the `lib` directory simple, modular, and maintainable.

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
│   │   ├── splash/
│   │   │   └── splash_screen.dart
│   │   ├── home_screen.dart
│   │   ├── devices_screen.dart
│   │   ├── chat/
│   │   │   └── chat_screen.dart
│   │   ├── story/
│   │   │   └── story_screen.dart
│   │   ├── call/
│   │   │   └── call_screen.dart
│   │   └── profile/
│   │       └── profile_screen.dart
│   │
│   └── widgets/
│       ├── peer_card.dart
│       └── message_bubble.dart
│
├── test/
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

---

# 🛠️ Technology Stack

NexPeer is built using modern Flutter and Dart technologies.

| Technology                 | Purpose                              |
| -------------------------- | ------------------------------------ |
| **Flutter**                | Cross-platform application framework |
| **Dart**                   | Application programming language     |
| **Material 3**             | Modern UI system                     |
| **flutter_p2p_connection** | P2P communication layer              |
| **crypto**                 | Cryptographic hashing utilities      |
| **Git**                    | Version control                      |
| **GitHub**                 | Source code hosting                  |

### Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter

  flutter_p2p_connection: ^3.0.3
  crypto: ^3.0.7
```

---

# 🚀 Getting Started

## Requirements

Before running NexPeer, make sure you have:

* Flutter SDK
* Dart SDK
* Android Studio or Android SDK
* VS Code or Android Studio
* Git
* Android device or emulator

Verify your Flutter installation:

```bash
flutter doctor
```

---

## 📥 Clone Repository

```bash
git clone https://github.com/Strong-Bee/NexPeer.git
```

Enter the project directory:

```bash
cd NexPeer
```

Install dependencies:

```bash
flutter pub get
```

---

# ▶️ Run NexPeer

Run the application on a connected device:

```bash
flutter run
```

List available devices:

```bash
flutter devices
```

Run specifically on Android:

```bash
flutter run -d android
```

---

# 🧹 Clean Project

If Flutter reports build, dependency, or cache-related issues:

```bash
flutter clean
flutter pub get
flutter run
```

For structural Dart changes that cannot be handled by Hot Reload, perform a **Hot Restart** or restart the application completely.

---

# 📦 Build APK

Build a release APK:

```bash
flutter build apk --release
```

The generated APK will be available at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

For architecture-specific APKs:

```bash
flutter build apk --split-per-abi
```

---

# 🔄 Development Roadmap

NexPeer is actively being developed as a modular **P2P communication platform**.

## Phase 1 — UI Foundation

* [x] Splash screen
* [x] Home screen
* [x] Chat interface
* [x] Story interface
* [x] Call interface
* [x] Profile interface
* [x] Navigation
* [x] Dark theme

## Phase 2 — P2P Connectivity

* [ ] Peer discovery
* [ ] Device pairing
* [ ] Connection management
* [ ] P2P data channel
* [ ] Connection recovery
* [ ] Online/offline detection

## Phase 3 — Messaging

* [ ] Real P2P message transport
* [ ] Message persistence
* [ ] Message synchronization
* [ ] Message delivery confirmation
* [ ] Read receipts
* [ ] Offline message queue

## Phase 4 — Security

* [ ] Cryptographic peer identity
* [ ] Key exchange
* [ ] Secure session establishment
* [ ] Authenticated encryption
* [ ] Message integrity
* [ ] Key rotation

## Phase 5 — Media Sharing

* [ ] Image transfer
* [ ] Video transfer
* [ ] Audio transfer
* [ ] Document transfer
* [ ] File transfer progress
* [ ] Resumable transfers

## Phase 6 — Real-Time Calls

* [ ] Voice calling
* [ ] Video calling
* [ ] Call signaling
* [ ] Microphone controls
* [ ] Camera controls
* [ ] Speaker controls
* [ ] Call history

## Phase 7 — Stories

* [ ] Photo stories
* [ ] Video stories
* [ ] Story expiration
* [ ] Story privacy
* [ ] Story views
* [ ] Story reactions

---

# 🔒 Security Philosophy

NexPeer follows a simple principle:

> **Privacy should be designed into the architecture, not added later.**

The long-term architecture aims to minimize unnecessary centralized dependencies while protecting communication through modern cryptographic protocols.

A production implementation should avoid:

```text
Custom Encryption
       ❌
```

and instead follow a security architecture such as:

```text
Secure Key Exchange
        ↓
Authenticated Encryption
        ↓
Integrity Verification
        ↓
Secure P2P Transport
```

Security-critical implementations should be reviewed, tested, and independently audited before production deployment.

---

# 🌐 SEO Keywords

NexPeer is a Flutter-based **peer-to-peer messaging application** focused on private, secure, and decentralized communication.

Relevant search keywords include:

```text
Flutter P2P Chat
Flutter Peer to Peer Messaging
P2P Messaging App
Private Messaging App
Secure Chat Application
Decentralized Messaging
Peer to Peer Communication
Flutter Chat App
Flutter Messaging App
Secure Messaging
Private Chat
P2P Communication
Device to Device Messaging
Flutter P2P
Dart Messaging Application
Open Source P2P Chat
Privacy Focused Messaging
Secure Peer Communication
Android P2P Chat
Cross Platform Messaging App
Peer to Peer Chat Application
Private Chat Application
Flutter P2P Communication
Secure Flutter App
Decentralized Chat Application
```

---

# 🎯 Project Goals

NexPeer aims to become a modern communication platform focused on:

```text
Privacy
   +
Peer-to-Peer
   +
Security
   +
Simplicity
   +
Modern UX
```

The long-term goal is to provide users with greater control over how their conversations and data are transmitted.

---

# 🤝 Contributing

Contributions are welcome.

You can contribute by:

* Reporting bugs
* Improving documentation
* Improving UI/UX
* Implementing P2P functionality
* Improving security architecture
* Adding automated tests
* Optimizing performance
* Improving accessibility
* Suggesting new features

### Development Workflow

```bash
git checkout -b feature/my-feature

git add .

git commit -m "feat: add my feature"

git push origin feature/my-feature
```

Then create a Pull Request on GitHub.

---

# 🐛 Bug Reports

If you discover a bug, please provide:

1. Device/platform
2. Flutter version
3. Dart version
4. Steps to reproduce
5. Expected behavior
6. Actual behavior
7. Error logs
8. Screenshots when applicable

Example:

```text
Platform:
Android 16

Flutter:
3.x.x

Issue:
Messages are not delivered after reconnecting to a peer.

Steps:
1. Connect to peer
2. Disconnect Wi-Fi
3. Reconnect
4. Send message

Expected:
Message should be delivered.

Actual:
Message remains in sending state.
```

---

# 📊 Project Status

**Current Status: 🚧 Active Development**

| Component               | Status            |
| ----------------------- | ----------------- |
| Flutter UI              | 🟢 Available      |
| Navigation              | 🟢 Available      |
| Chat UI                 | 🟢 Available      |
| Story UI                | 🟢 Available      |
| Call UI                 | 🟢 Available      |
| Profile UI              | 🟢 Available      |
| P2P Architecture        | 🟡 In Development |
| Real P2P Transport      | 🟡 In Development |
| Secure Messaging        | 🟡 Planned        |
| File Transfer           | 🟡 Planned        |
| Voice Calls             | 🟡 Planned        |
| Video Calls             | 🟡 Planned        |
| Story Backend/Transport | 🟡 Planned        |

---

# 🏆 Vision

NexPeer is more than another chat interface.

It is an exploration of what communication could look like when applications prioritize:

**Privacy.**

**Direct communication.**

**Security.**

**User ownership.**

**Minimal dependency on centralized infrastructure.**

The vision is to build a communication platform where privacy, direct connectivity, and user control are fundamental parts of the architecture.

---

# 👨‍💻 Developer

**Cyber Technology Project**

Building software, automation, AI, and privacy-focused technology.

---

# 📄 License

License information will be added as the project reaches its public release stage.

---

<div align="center">

# 🚀 NexPeer

### Private. Direct. Peer-to-Peer.

Built with ❤️ using **Flutter & Dart**.

**Cyber Technology Project**

</div>
