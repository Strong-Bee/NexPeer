# NexPeer SQLite API

SQLite stores NexPeer profiles and contacts. Firebase Authentication is used only to verify ID tokens; Firestore is not used.

## Requirements
- Node.js 22+
- Persistent writable volume mounted at /data
- Firebase Admin credentials that can verify Firebase Authentication ID tokens

## Run
```bash
cd server
npm install
cp .env.example .env
npm start
```

Set GOOGLE_APPLICATION_CREDENTIALS to the service-account JSON path. Never commit service-account credentials.

## Deployment
Build with the Dockerfile and mount persistent storage at /data. Do not put SQLite on an ephemeral serverless filesystem. Back up the database regularly.

## Flutter
```bash
flutter pub get
flutter run --dart-define=NEXPEER_API_URL=https://your-api.example.com
```

The app keeps a local SQLite cache; the API database is the shared cross-device directory.